/*
    Adds, replaces or removes the extension of the specified file name.
    Parameters:
        FileName:
            A string in which to replace the extension.
        Ext:
            A string that contains the new extension. Invalid characters are automatically removed.
            Set this value to an empty string to remove the extension, this is the default.
    Return value:
        Returns the new string with the specified extension.
*/
PathSetExtension(FileName, Ext := "")
{
    Ext := RegExReplace(Ext,"[/\\:\*\?`"<>\|\.]")  ; Removes invalid characters.
    return RegExReplace(FileName,"(^.*)\..*","$1") . (Ext == "" ? "" : "." . Ext)
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-pathrenameextensionw
