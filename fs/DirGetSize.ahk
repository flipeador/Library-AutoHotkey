/*
    Gets the size, in bytes, of all files and subfolders contained in the specified folder.
    Parameters:
        DirName:
            The path (absolute or relative) to a specific folder.
    Return value:
        If the function succeeds, the return value is the size, in bytes, of the specified folder.
        If the function not succeeds, the return value is -1.
*/
DirGetSize(DirName)
{
    global G_FileSystemObject
    local

    if (!IsObject(G_FileSystemObject))
    {
        ; FileSystemObject object.
        ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object
        G_FileSystemObject := ComObjCreate("Scripting.FileSystemObject")
    }

    ; FileSystemObject::GetFolder method.
    ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getfolder-method.
    try Folder := G_FileSystemObject.GetFolder(DirName) 

    ; Folder object.
    ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/folder-object.

    ; Folder::Size property.
    ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/size-property-filesystemobject-object.
    return IsObject(Folder) ? Folder.Size : -1
}





; MsgBox(Format("Folder: {2}`nSize: {1} Bytes; {3} MB",S:=DirGetSize(F:=DirSelect()),F,Round(S//1024**2,2)))
