/*
    Displays the Open With dialog box. You can only use this dialog to open a single file.
    Parameters:
        Owner:
            The handle of the owner window. This value can be zero.
        FileName:
            A string with a file name.
        FileTypeDesc:
            A string with the file type description. Set this parameter to an empty string to use the file name extension of «FileName».
        Flags:
            The characteristics of the dialog box. Can be one or more of the following values.
            0x00000002  OAIF_REGISTER_EXT    Do the registration after the user hits the OK button.
            0x00000004  OAIF_EXEC            Execute file after registering. The user will receive a dialog that informs them that they can change the default programs used to open file extensions in their Settings.
            0x00000040  OAIF_URL_PROTOCOL    The value for the extension that is passed is actually a protocol, so the dialog should show applications that are registered as capable of handling that protocol.
            0x00000080  OAIF_FILE_IS_URI     (WIN_8+) The location pointed to by the «FileName» parameter is given as a URI.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
    Remarks:
        Starting in Windows 10, the dialog can no longer be used to change the default program used to open a file extension.
*/
OpenWith(Owner, FileName, FileTypeDesc := "", Flags := 0x00000004)
{
    if (!FileExist(FileName) || DirExist(FileName))
        return !(ErrorLevel := 0x80110424)

    local OPENASINFO    := BufferAlloc(3*A_PtrSize)
    local pFileTypeDesc := FileTypeDesc == "" ? 0 : &(FileTypeDesc:=String(FileTypeDesc))
    NumPut("Ptr", &FileName, "Ptr", pFileTypeDesc, "UInt", Flags|1, OPENASINFO)

    ErrorLevel := DllCall("Shell32.dll\SHOpenWithDialog", "Ptr", Owner, "Ptr", OPENASINFO, "UInt")
    return ErrorLevel ? 0 : FileName
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-shopenwithdialog





;MsgBox(OpenWith(0,FileSelect()))
