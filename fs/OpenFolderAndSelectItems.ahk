/*
    Opens a Windows Explorer window with specified items in a particular folder selected.
    Parámetros:
        DirName:
            The name of the folder to be opened. If this directory does not exist, the function fails and returns zero.
        FileList:
            An array of file names, each of which is an item to select in the target folder referenced by «DirName».
            This parameter can be a string with a single filename. The function fails if there are no items to select.
            Files that do not exist in «DirName» will be omitted, but at least one file must exist or the function fails.
        Flags:
            The optional flags. The following flags are defined.
            0x0001  OFASI_EDIT           Select an item and put its name in edit mode. This flag can only be used when a single item is being selected. For multiple item selections, it is ignored.
            0x0002  OFASI_OPENDESKTOP    Select the item or items on the desktop rather than in a Windows Explorer window. Note that if the desktop is obscured behind open windows, it will not be made visible.
    Return value:
        If the function succeeds, the return value is the number of selected items.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel (HRESULT error code).
        If the function returns zero and ErrorLevel is -1, it is because there are no existing items to select.
    A_LastError:
        It is set in the number of existing items that were supposed (in case the function fails) to be selected.
*/
OpenFolderAndSelectItems(DirName, FileList, Flags := 0)
{
    local

    DirName  := RTrim(DirName,"\") . "\"
    FileList := IsObject(FileList) ? FileList : FileList == "" ? [] : [FileList]

    if ErrorLevel := DllCall("Shell32.dll\SHParseDisplayName", "Ptr", &DirName, "Ptr", 0, "PtrP", DirPIDL:=0, "UInt", 0, "Ptr", 0, "UInt")
        return A_LastError := 0

    ; ITEMIDLIST structure.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shtypes/ns-shtypes-_itemidlist.
    ITEMIDLIST := BufferAlloc(FileList.Length() * A_PtrSize)
    ItemCount  := 0
    for i, FileName in FileList
        if !DllCall("Shell32.dll\SHParseDisplayName", "Str", DirName . FileName, "Ptr", 0, "PtrP", PIDL:=0, "UInt", 0, "Ptr", 0)
            ItemCount += !!NumPut("Ptr", PIDL, ITEMIDLIST, (A_Index-1)*A_PtrSize)

    if (ItemCount)  ; Do nothing if there are no files to be selected (SHOpenFolderAndSelectItems behaves weird in that case).
        ErrorLevel := DllCall("Shell32.dll\SHOpenFolderAndSelectItems", "Ptr", DirPIDL, "UInt", ItemCount, "Ptr", ITEMIDLIST, "UInt", Flags, "UInt")
    else
        ErrorLevel := -1
    
    DllCall("Ole32.dll\CoTaskMemFree", "Ptr", DirPIDL)
    Loop (ItemCount)
        DllCall("Ole32.dll\CoTaskMemFree", "Ptr", NumGet(ITEMIDLIST,(A_Index-1)*A_PtrSize,"Ptr"))

    A_LastError := ItemCount
    return ErrorLevel ? 0 : ItemCount
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-shopenfolderandselectitems





;MsgBox(OpenFolderAndSelectItems(A_WinDir,["hh.exe","explorer.exe","regedit.exe",2]))
