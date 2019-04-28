/*
    ==================================================================================================================
    Ejemplo #1: Pide que seleccione dos archivos al usuario y luego los copia al escritorio.
    ==================================================================================================================
    FileOp := new IFileOperation
    MsgBox 'CopyItem #1: '       . (FileOp.CopyItem(FileSelect(), A_Desktop) ? 'ERROR' : 'OK!')
    MsgBox 'CopyItem #2: '       . (FileOp.CopyItem(FileSelect(), A_Desktop) ? 'ERROR' : 'OK!')
    MsgBox 'PerformOperations: ' . (FileOp.PerformOperations()               ? 'ERROR' : 'OK!')
*/
Class IFileOperation
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    ptr := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        ComObjError(FALSE)
        If (!(this.ptr := ComObjCreate('{3AD05575-8857-4850-9277-11B85BDB8E09}', '{947AAB5F-0A5C-4C13-B4D6-4BF7836FC9F8}')))
            Return FALSE

        For Each, Method in ['Advise','Unadvise','SetOperationFlags','SetProgressMessage','SetProgressDialog','SetProperties','SetOwnerWindow','ApplyPropertiesToItem','ApplyPropertiesToItems','RenameItem', 'RenameItems','MoveItem','MoveItems','CopyItem','CopyItems','DeleteItem','DeleteItems','NewItem','PerformOperations','GetAnyOperationsAborted']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775771(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ptr)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    ShellItem(Item)
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb762236(v=vs.85).aspx
        Local PIDL
        If (DllCall('Shell32.dll\SHParseDisplayName', 'UPtr', &Item, 'Ptr', 0, 'UPtrP', PIDL, 'UInt', 0, 'UInt', 0))
            Return 0

        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680589(v=vs.85).aspx
        Local GUID
        VarSetCapacity(GUID, 16)
        DllCall('Ole32.dll\CLSIDFromString', 'Str', '{43826D1E-E718-42EE-BC55-A1E261C37BFE}', 'UPtr', &GUID)    ; IID_IShellItem

        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb762133(v=vs.85).aspx
        Local IShellItem
        DllCall('Shell32.dll\SHCreateItemFromIDList', 'UPtr', PIDL, 'UPtr', &GUID, 'UPtrP', IShellItem, 'UInt')

        Return IShellItem    ; ObjRelease(IShellItem)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    CopyItem(Item, DestinationFolder, CopyName := '', ProgressStatus := 0)
    {
        Local ShellItem1 := 0, ShellItem2 := 0
        Item              := Item              is 'Integer' ? Item              : ShellItem1 := this.ShellItem(Item)
        DestinationFolder := DestinationFolder is 'Integer' ? DestinationFolder : ShellItem2 := this.ShellItem(DestinationFolder)
        Local R := DllCall(this.pCopyItem, 'UPtr', this.ptr, 'UPtr', Item, 'UPtr', DestinationFolder, 'UPtr', CopyName == '' ? 0 : &CopyName, 'UPtr', ProgressStatus, 'UInt')
        ShellItem1 := ShellItem1 ? ObjRelease(ShellItem1) : 0, ShellItem2 := ShellItem2 ? ObjRelease(ShellItem2) : 0
        Return R
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775761(v=vs.85).aspx

    SetOperationFlags(OperationFlags)
    {
        Return DllCall(this.pSetOperationFlags, 'UPtr', this.ptr, 'UInt', OperationFlags, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775807(v=vs.85).aspx

    PerformOperations()
    {
        Return DllCall(this.pPerformOperations, 'UPtr', this.ptr, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775780(v=vs.85).aspx
}
