DirGetSize(DirName)
{
    static fso := 0

    if ( !fso )
        ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object
        fso := ComObjCreate("Scripting.FileSystemObject")

    ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getfolder-method
    ; https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/size-property-filesystemobject-object
    try return fso.GetFolder(DirName).Size
    catch
        return -1
}
