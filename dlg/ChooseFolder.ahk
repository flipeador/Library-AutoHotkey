/*
    Initializes, shows, and gets results from a common file dialog that allows the user to choose a folder(s).
    Parameters:
        Owner:
            The Gui object or handle to the owner window. This parameter can be zero.
        Title:
            Sets the title of the dialog.
            This parameter can be a string or a pointer to a null-terminated string.
            If a NULL pointer is specified, the default title will be used.
        StartingFolder:
            A folder that is always selected when the dialog is opened, regardless of previous user action.
            If the directory does not exist, parent directories are searched.
        CustomPlaces:
            Adds folders to the list of places available for the user to open items.
            This parameter should be an array of paths to a directory. Non-existent directories are omitted.
        Flags:
            Sets flags to control the behavior of the dialog.
            0x00040000  FOS_HIDEPINNEDPLACES    Hide all of the standard namespace locations shown in the navigation pane.
            0x00000200  FOS_ALLOWMULTISELECT    Enables the user to select multiple items in the open dialog.
            0x10000000  FOS_FORCESHOWHIDDEN     Include hidden and system items.
            0x02000000  FOS_DONTADDTORECENT     Do not add the item being opened to the recent documents list (SHAddToRecentDocs).
            Reference: https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/ne-shobjidl_core-_fileopendialogoptions.
    Return:
        Returns a string with te chosen folder, or an array if the FOS_ALLOWMULTISELECT flag was specified.
        Returns an empty string if there was an error.
    ErrorLevel:
        If the function succeeds, it receives 0 (S_OK). Otherwise, it receives an HRESULT error code, including the following.
        0x04C7  ERROR_CANCELLED      The user closed the window by cancelling the operation.
    Example:
        R := ChooseFolder(0,, A_StartMenu, [A_Desktop,A_Temp])
        MsgBox("Result:`n" . R . "`n`nErrorLevel:`n" . ErrorLevel)   
*/   
ChooseFolder(Owner, Title := 0, StartingFolder := "", CustomPlaces := "", Flags := 0)
{
    local


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileOpenDialog interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ifileopendialog.
    ; --------------------------------------------------------------------------------------------------------------------
    local IFileOpenDialog := ComObjCreate("{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}", "{D57C7288-D4AD-4768-BE02-9D969532D960}")
    vt              := (n) => NumGet(NumGet(IFileOpenDialog,"Ptr")+n*A_PtrSize, "Ptr")


    ; --------------------------------------------------------------------------------------------------------------------
    ; Initialize variables.
    ; --------------------------------------------------------------------------------------------------------------------
    Resources := { }  ; Stores certain data and resources to be freed at the end of the function.


    ; --------------------------------------------------------------------------------------------------------------------
    ; Check the parameters.
    ; --------------------------------------------------------------------------------------------------------------------
    Owner := Type(Owner) == "Gui" ? Owner.hWnd : Owner
    if Type(Owner) !== "Integer"
        throw Exception("ChooseFolder function: invalid parameter #1.", -1, "Invalid data type.")
    if Owner && !WinExist("ahk_id" . Owner)
        throw Exception("ChooseFolder function: invalid parameter #1.", -1, "The specified window does not exist.")

    if !(Type(Title) ~= "^(Integer|String)$")
        throw Exception("ChooseFolder function: invalid parameter #2.", -1, "Invalid data type.")
    Title := Type(Title) == "Integer" ? Title : Trim(Title~="^\s*$"?A_ScriptName:Title,"`s`t`r`n")

    if Type(StartingFolder) !== "String"
        throw Exception("ChooseFolder function: invalid parameter #3.", -1, "Invalid data type.")
    StartingFolder := Trim(StartingFolder, "`s`t`r`n")

    if !(Type(CustomPlaces) ~= "^(Object|String)$")
        throw Exception("ChooseFolder function: invalid parameter #5.", -1, "Invalid value.")
    CustomPlaces := CustomPlaces == "" ? [] : IsObject(CustomPlaces) ? CustomPlaces : [CustomPlaces]

    if Type(Flags) !== "Integer"
        throw Exception("ChooseFolder function: invalid parameter #6.", -1, "Invalid data type.")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetTitle method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-settitle.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(17), "Ptr", IFileOpenDialog
                  , "Ptr", Type(Title) == "Integer" ? Title : &Title
           , "UInt")
    

    ; --------------------------------------------------------------------------------------------------------------------
    ; Sets a folder that is always selected when the dialog is opened, regardless of previous user action.
    ; --------------------------------------------------------------------------------------------------------------------
    while InStr(StartingFolder,"\") && !DirExist(StartingFolder)
        StartingFolder := SubStr(StartingFolder, 1, InStr(StartingFolder,"\",,-1)-1)
    if DirExist(StartingFolder)
    {
        DllCall("Shell32.dll\SHParseDisplayName", "Ptr", &StartingFolder, "Ptr", 0, "PtrP", PIDL:=0, "UInt", 0, "UInt", 0, "UInt")
        DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "Ptr", PIDL, "PtrP", IShellItem:=0, "UInt")
        Resources[IShellItem] := PIDL

        ; IFileDialog::SetFolder method.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfolder.
        DllCall(vt.call(12), "Ptr", IFileOpenDialog, "UPtr", IShellItem, "UInt")
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; Adds folders to the list of places available for the user to open or save items.
    ; --------------------------------------------------------------------------------------------------------------------
    loop CustomPlaces.Length()
    {
        if DirExist(CustomPlaces[A_Index])
        {
            DllCall("Shell32.dll\SHParseDisplayName", "Ptr", CustomPlaces.GetAddress(A_Index), "Ptr", 0, "PtrP", PIDL:=0, "UInt", 0, "UInt", 0, "UInt")
            DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "Ptr", PIDL, "PtrP", IShellItem:=0, "UInt")
            Resources[IShellItem] := PIDL

            ; IFileDialog::AddPlace method.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-addplace.
            DllCall(vt.call(21), "Ptr", IFileOpenDialog, "Ptr", IShellItem, "UInt", 0, "UInt")
        }
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetOptions method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setoptions.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(9), "Ptr", IFileOpenDialog, "UInt", Flags|0x20, "UInt")  ; FOS_PICKFOLDERS = 0x20.


    ; --------------------------------------------------------------------------------------------------------------------
    ; IModalWindow::Show method.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-imodalwindow-show.
    ; --------------------------------------------------------------------------------------------------------------------
    Result := []
    ErrorLevel := DllCall(vt.call(3), "Ptr", IFileOpenDialog, "Ptr", Owner, "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileOpenDialog::GetResults method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifileopendialog-getresults.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(27), "Ptr", IFileOpenDialog, "PtrP", IShellItemArray:=0, "UInt")
    {
        ; IShellItemArray::GetCount method.
        ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitemarray-getcount.
        DllCall(NumGet(NumGet(IShellItemArray,"Ptr")+7*A_PtrSize,"Ptr"), "Ptr", IShellItemArray, "UIntP", Count, "UInt")

        Result.SetCapacity(Count)
        VarSetCapacity(Buffer, 32767 * 2)
        loop Count
        {
            ; IShellItemArray::GetItemAt method.
            ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitemarray-getitemat.
            DllCall(NumGet(NumGet(IShellItemArray,"Ptr")+8*A_PtrSize,"Ptr"), "Ptr", IShellItemArray, "UInt", A_Index-1, "PtrP", IShellItem:=0, "UInt")

            DllCall("Shell32.dll\SHGetIDListFromObject", "Ptr", IShellItem, "PtrP", PIDL:=0, "UInt")
            DllCall("Shell32.dll\SHGetPathFromIDListEx", "Ptr", PIDL, "Str", Buffer, "UInt", 32767, "UInt", 0, "UInt")
            Resources[IShellItem] := PIDL
            Result.Push(Buffer)
        } 

        ObjRelease(IShellItemArray)
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; Free resources and return.
    ; --------------------------------------------------------------------------------------------------------------------
    for IShellItem, PIDL in Resources
    {
        if Type(IShellItem) == "Integer"
        {
            ObjRelease(IShellItem)
            DllCall("Ole32.dll\CoTaskMemFree", "Ptr", PIDL, "Int")
        }
    }
    ObjRelease(IFileOpenDialog)

    if Result.Length() && !(Flags & 0x00000200)
        Result := Result[1]

    return Result
}
