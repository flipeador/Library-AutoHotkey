DllCall("Ole32.dll\CLSIDFromString", "Str", "{43826D1E-E718-42EE-BC55-A1E261C37BFE}", "Ptr", IFileOperation.IID_IShellItem)





/*
    Exposes methods to copy, move, rename, create, and delete Shell items as well as methods to provide progress and error dialogs.
*/
class IFileOperation
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static IID_IShellItem := BufferAlloc(16)


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        local

        this.Ptr := ComObjCreate("{3AD05575-8857-4850-9277-11B85BDB8E09}", "{947AAB5F-0A5C-4C13-B4D6-4BF7836FC9F8}")
        if (!this.Ptr)
            throw Exception("IFileOperation class.", -1)

        for Each, Method in ["Advise","Unadvise","SetOperationFlags","SetProgressMessage","SetProgressDialog","SetProperties","SetOwnerWindow","ApplyPropertiesToItem","ApplyPropertiesToItems","RenameItem", "RenameItems","MoveItem","MoveItems","CopyItem","CopyItems","DeleteItem","DeleteItems","NewItem","PerformOperations","GetAnyOperationsAborted"]
            this.p%Method% := NumGet(NumGet(this.Ptr)+(2+A_Index)*A_PtrSize)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775771(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.Ptr)
    }


    ; ===================================================================================================================
    ; PRIVATE NESTED CLASSES
    ; ===================================================================================================================
    class ItemFromName
    {
        __New(Name)
        {
            local R, IShellItem := 0
            R := DllCall("Shell32.dll\SHCreateItemFromParsingName", "Ptr", &Name, "Ptr", 0, "Ptr", IFileOperation.IID_IShellItem, "PtrP", IShellItem, "UInt")
            return (this.Ptr:=IShellItem) ? this : R
        } ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-shcreateitemfromparsingname
        __Delete()
        {
            try ObjRelease(this.Ptr)
        }
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Sets parameters for the current operation.
        Parameters:
            Flags:
                Flags that control the file operation.
        Return value:
            If this method succeeds, it returns zero. Otherwise, it returns an HRESULT error code.
    */
    SetOperationFlags(Flags)
    {
        return DllCall(this.pSetOperationFlags, "Ptr", this.Ptr, "UInt", Flags, "UInt")
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifileoperation-setoperationflags

    /*
        Executes all selected operations.
        Return value:
            Returns zero if successful, or an error value otherwise (HRESULT).
            Note that if the operation was canceled by the user, this method can still return a success code. Use the GetAnyOperationsAborted method to determine if this was the case.
    */
    PerformOperations()
    {
        return DllCall(this.pPerformOperations, "Ptr", this.Ptr, "UInt")
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifileoperation-performoperations

    /*
        Gets a value that states whether any file operations initiated by a call to the PerformOperations method were stopped before they were complete.
        The operations could be stopped either by user action or silently by the system.
        Return value:
            If this method succeeds: it returns -1 if any file operations were aborted before they were complete; otherwise, zero.
            Otherwise: it returns an HRESULT error code.
    */
    GetAnyOperationsAborted()
    {
        local bool := 0
        return DllCall(this.pGetAnyOperationsAborted, "Ptr", this.Ptr, "IntP", bool, "UInt") || (bool ? -1 : 0)
    }

    /*
        Declares a single item that is to be copied to a specified destination.
        Parameters:
            FileName:
                Specifies the name of a single file to copy.
            DestName:
                Specifies the destination folder to contain the copy of the item.
            CopyName:
                A new name for the item after it has been copied.
                This parameter can be a string or a pointer to a null-terminated string.
                If zero, the name of the destination item is the same as the source.
        Return value:
            If this method succeeds, it returns zero. Otherwise, it returns an HRESULT error code.
    */
    CopyItem(FileName, DestName, CopyName := 0)
    {
        if !IsObject(Item:=new IFileOperation.ItemFromName(FileName)) || !IsObject(Dest:=new IFileOperation.ItemFromName(DestName))
            return IsObject(Item) ? Dest : Item
        return DllCall(this.pCopyItem, "UPtr", this.Ptr
                                     , "UPtr", Item.Ptr
                                     , "UPtr", Dest.Ptr
                                     , "UPtr", Type(CopyName) == "String" ? &CopyName : CopyName
                                     , "UPtr", 0
                                     , "UInt")
    }
}





/*
f := new IFileOperation()
MsgBox(Format("CopyItem:`s{}`nPerformOperations:`s{}`nGetAnyOperationsAborted:`s{}"
    , f.CopyItem(A_ComSpec, A_Desktop, "copyofcmd.exe")
    , f.PerformOperations()
    , f.GetAnyOperationsAborted())
      )
*/
