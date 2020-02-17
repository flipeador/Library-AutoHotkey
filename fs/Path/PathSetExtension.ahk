/*
    Adds, replaces or removes the extension of the specified path.
    Parameters:
        FileName:
            A string containing the path in which to replace the extension.
        Ext:
            A string that contains the new extension.
            Set this value to an empty string to remove the extension, this is the default.
        RemoveInvalid:
            Specifies whether to remove invalid characters from the extension.
    Return value:
        Returns the formated path.
*/
PathSetExtension(Path, Ext := "", RemoveInvalid := false)
{
    Ext := RemoveInvalid ? RegExReplace(Ext,"[/\\:\*\?`"<>\|\.]") : Ext
    return RegExReplace(Path,"(^.*)\..*","$1") . (Ext==""?"":"." . Ext)
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-pathrenameextensionw
