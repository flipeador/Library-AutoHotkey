/*
    Initializes, shows, and gets results from a common file dialog that allows the user to save a file.
    Parameters:
        Owner:
            The Gui object or handle to the owner window. This parameter can be zero.
        Title:
            Sets the title of the dialog.
            This parameter can be a string or a pointer to a null-terminated string.
            If a NULL pointer is specified, the default title will be used: "Save as".
        FileName:
            The file name that appears in the File name edit box when that dialog box is opened.
            To specify a directory, this string must end with a backslash.
            If the directory does not exist, parent directories are searched.
        Filter:
            Sets the file types that the dialog can save. If omitted, the filter defaults to All Files (*.*). 
            This parameter should be a string with the format: "Images:*.jpg;*.bmp;*.png|*Audio:*.wav;*.mp3\mp3".
            The asterisk at the beginning of the description indicates the filter selected by default. If not set, the first one is shown.
            In the last filter, the '\' character must be followed by the name of the default extension to be added to file names.
        CustomPlaces:
            Adds folders to the list of places available for the user to save items.
            This parameter should be an array of paths to a directory. Non-existent directories are omitted.
        Flags:
            Sets flags to control the behavior of the dialog.
            0x00000002  FOS_OVERWRITEPROMPT     Prompt before overwriting an existing file of the same name.
            0x00000004  FOS_STRICTFILETYPES     Only allow the user to choose a file that has one of the file name extensions specified through the filter.
            0x00040000  FOS_HIDEPINNEDPLACES    Hide all of the standard namespace locations shown in the navigation pane.
            0x10000000  FOS_FORCESHOWHIDDEN     Include hidden and system items.
            0x02000000  FOS_DONTADDTORECENT     Do not add the item being saved to the recent documents list (SHAddToRecentDocs).
            Reference: https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/ne-shobjidl_core-_fileopendialogoptions.
            The default flags ​​are: FOS_OVERWRITEPROMPT y FOS_STRICTFILETYPES.
    Return:
        Returns an object with the following keys.
        Result             Receive a string with the chosen file. It is set to an empty string if there was an error.
        FileName           Receives the text currently entered in the dialog's File name edit box.
        FileTypeIndex      Receives the index of the selected file type in the filter.
    ErrorLevel:
        If the function succeeds, it receives 0 (S_OK). Otherwise, it receives an HRESULT error code, including the following.
        0x04C7  ERROR_CANCELLED      The user closed the window by cancelling the operation.
    Example:
        R := SaveFile(0,, A_ComSpec, "Images:*.jpg;*.bmp;*.png|*Audio:*.wav;*.mp3\mp3", [A_Desktop,A_Temp])
        MsgBox("Result:`n" . R.Result . "`n`nFileName:`n" . R.FileName . "`n`nFileTypeIndex:`n" . R.FileTypeIndex . "`n`nErrorLevel:`n" . ErrorLevel)
*/
SaveFile(Owner, Title := 0, FileName := "", Filter := "All files:*.*", CustomPlaces := "", Flags := 6)
{
    local


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileSaveDialog interface.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ifilesavedialog.
    ; --------------------------------------------------------------------------------------------------------------------
    IFileSaveDialog := ComObjCreate("{C0B4E2F3-BA21-4773-8DBA-335EC946EB8B}", "{84BCCD23-5FDE-4CDB-AEA4-AF64B83D78AB}")
    vt              := (n) => NumGet(NumGet(IFileSaveDialog,"Ptr")+n*A_PtrSize, "Ptr")


    ; --------------------------------------------------------------------------------------------------------------------
    ; Initialize variables.
    ; --------------------------------------------------------------------------------------------------------------------
    Resources := { }  ; Stores certain data and resources to be freed at the end of the function.


    ; --------------------------------------------------------------------------------------------------------------------
    ; Check the parameters.
    ; --------------------------------------------------------------------------------------------------------------------
    Owner := Type(Owner) == "Gui" ? Owner.hWnd : Owner
    if Type(Owner) !== "Integer"
        throw Exception("SaveFile function: invalid parameter #1.", -1, "Invalid data type.")
    if Owner && !WinExist("ahk_id" . Owner)
        throw Exception("SaveFile function: invalid parameter #1.", -1, "The specified window does not exist.")

    if !(Type(Title) ~= "^(Integer|String)$")
        throw Exception("SaveFile function: invalid parameter #2.", -1, "Invalid data type.")
    Title := Type(Title) == "Integer" ? Title : Trim(Title~="^\s*$"?A_ScriptName:Title,"`s`t`r`n")

    if Type(FileName) !== "String"
        throw Exception("SaveFile function: invalid parameter #3.", -1, "Invalid data type.")
    FileName := Trim(FileName, "`s`t`r`n")

    if Type(Filter) !== "String"
        throw Exception("SaveFile function: invalid parameter #4.", -1, "Invalid value.")

    if !(Type(CustomPlaces) ~= "^(Object|String)$")
        throw Exception("SaveFile function: invalid parameter #5.", -1, "Invalid value.")
    CustomPlaces := CustomPlaces == "" ? [] : IsObject(CustomPlaces) ? CustomPlaces : [CustomPlaces]

    if Type(Flags) !== "Integer"
        throw Exception("SaveFile function: invalid parameter #6.", -1, "Invalid data type.")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetTitle method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-settitle.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(17), "Ptr", IFileSaveDialog
                  , "Ptr", Type(Title) == "Integer" ? Title : &Title
           , "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; Sets the file name that appears in the File name edit box when that dialog box is opened.
    ; --------------------------------------------------------------------------------------------------------------------
    if FileName !== ""
    {
        Directory := FileName

        if InStr(FileName, "\")
        {
            if !(FileName ~= "\\$")
            {
                SplitPath(FileName, File, Directory)
                ; IFileDialog::SetFileName.
                ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfilename.
                DllCall(vt.call(15), "Ptr", IFileSaveDialog, "Ptr", &File, "UInt")
            }
            
            while InStr(Directory,"\") && !DirExist(Directory)
                Directory := SubStr(Directory, 1, InStr(Directory,"\",,-1)-1)
            if DirExist(Directory)
            {
                DllCall("Shell32.dll\SHParseDisplayName", "Ptr", &Directory, "Ptr", 0, "PtrP", PIDL:=0, "UInt", 0, "UInt", 0, "UInt")
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "Ptr", PIDL, "PtrP", IShellItem:=0, "UInt")
                Resources[IShellItem] := PIDL

                ; IFileDialog::SetFolder method.
                ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfolder.
                DllCall(vt.call(12), "Ptr", IFileSaveDialog, "UPtr", IShellItem, "UInt")
            }
        }
        else
            DllCall(vt.call(15), "Ptr", IFileSaveDialog, "Ptr", &FileName, "UInt")
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; COMDLG_FILTERSPEC structure
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shtypes/ns-shtypes-_comdlg_filterspec.
    ; --------------------------------------------------------------------------------------------------------------------
    FileTypes     := 0  ; The number of valid elements in the filter.
    FileTypeIndex := 1  ; The index of the file type that appears as selected in the dialog.
    Escape        := 0

    Resources.SetCapacity("COMDLG_FILTERSPEC", StrSplit(Filter,"|").Length() * 2*A_PtrSize)
    loop parse, Filter, "|"
    {
        if !InStr(A_LoopField, ":")
            continue

        ++FileTypes
        desc   := StrSplit(A_LoopField,":")[1]
        types  := StrSplit(StrSplit(A_LoopField,"\")[1], ":")[2]
        defext := InStr(A_LoopField,"\") ? StrSplit(A_LoopField,"\")[2] : ""
        
        if desc ~= "^\*"
        {
            FileTypeIndex := A_Index
            desc := SubStr(desc, 2)
        }

        if defext !== ""
            ; IFileDialog::SetDefaultExtension method.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setdefaultextension.
            DllCall(vt.call(22), "Ptr", IFileSaveDialog, "Ptr", &defext, "UInt")

        Resources["#" . FileTypes] := desc
        Resources["@" . FileTypes] := types

        NumPut(Resources.GetAddress("#" . A_Index), Resources.GetAddress("COMDLG_FILTERSPEC") + A_PtrSize * 2*(FileTypes-1), "Ptr")      ; COMDLG_FILTERSPEC.pszName.
        NumPut(Resources.GetAddress("@" . A_Index), Resources.GetAddress("COMDLG_FILTERSPEC") + A_PtrSize * (2*(FileTypes-1)+1), "Ptr")  ; COMDLG_FILTERSPEC.pszSpec.
    }
    

    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetFileTypes method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setfiletypes.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(4), "Ptr", IFileSaveDialog, "UInt", FileTypes, "Ptr", Resources.GetAddress("COMDLG_FILTERSPEC"), "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetFileTypeIndex method.
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775978(v=vs.85).aspx.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(5), "Ptr", IFileSaveDialog, "UInt", FileTypeIndex, "UInt")


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
            DllCall(vt.call(21), "Ptr", IFileSaveDialog, "Ptr", IShellItem, "UInt", 0, "UInt")
        }
    }


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::SetOptions method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-setoptions.
    ; --------------------------------------------------------------------------------------------------------------------
    DllCall(vt.call(9), "Ptr", IFileSaveDialog, "UInt", Flags, "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IModalWindow::Show method.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shobjidl_core/nf-shobjidl_core-imodalwindow-show.
    ; --------------------------------------------------------------------------------------------------------------------
    R := { Result:"" , FileName:"" , FileTypeIndex:0 }
    ErrorLevel := DllCall(vt.call(3), "Ptr", IFileSaveDialog, "Ptr", Owner, "UInt")


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::GetFileTypeIndex method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-getfiletypeindex.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(6), "Ptr", IFileSaveDialog, "UIntP", FileTypeIndex, "UInt")
        R.FileTypeIndex := FileTypeIndex


    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::GetFileName method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-getfilename.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(16), "Ptr", IFileSaveDialog, "PtrP", pBuffer:=0, "UInt")
    {
        R.FileName := StrGet(pBuffer, "UTF-16")
        DllCall("Ole32.dll\CoTaskMemFree", "Ptr", pBuffer, "Int")
    }

    ; --------------------------------------------------------------------------------------------------------------------
    ; IFileDialog::GetResult method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifiledialog-getresult.
    ; --------------------------------------------------------------------------------------------------------------------
    if !DllCall(vt.call(20), "Ptr", IFileSaveDialog, "PtrP", IShellItem:=0, "UInt")
    {
        R.SetCapacity("Result", 2*32767)
        DllCall("Shell32.dll\SHGetIDListFromObject", "Ptr", IShellItem, "PtrP", PIDL:=0, "UInt")
        DllCall("Shell32.dll\SHGetPathFromIDListEx", "Ptr", PIDL, "Ptr", R.GetAddress("Result"), "UInt", 32767, "UInt", 0, "UInt")
        Resources[IShellItem] := PIDL
        R.Result := StrGet(R.GetAddress("Result"), "UTF-16")
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
    ObjRelease(IFileSaveDialog)

    return R
}
