/*
    Empties the Recycle Bin on the specified drive.
    Parameters:
        RootPath:
            The string that contains the path of the root drive on which the Recycle Bin is located.
            This parameter can contain a string formatted with the drive, folder, and subfolder names.
            If this value is an empty string or zero, all Recycle Bins on all drives will be emptied.
        Owner:
            A handle to the parent window of any dialog boxes that might be displayed during the operation.
            If this parameter can be NULL.
        Flags:
            0x00000001   No dialog box confirming the deletion of the objects will be displayed.
            0x00000002   No dialog box indicating the progress will be displayed.
            0x00000004   No sound will be played when the operation is complete.
    Return:
        If this function succeeds, the return valur is TRUE.
        If the function fails, the return value is FALSE. To get extended error information, check A_LastError.
*/
EmptyRecycleBin(RootPath := 0, Owner := 0, Flags := 0)
{
    RootPath := StrLen(RootPath) == 1 ? RootPath . ":" : RootPath

    A_LastError := DllCall("Shell32.dll\SHEmptyRecycleBinW", "UPtr", Owner ? WinExist("ahk_id" . Owner) ? Owner : 0 : Owner
                                                           , "UPtr", Type(RootPath) == "String" ? &RootPath : RootPath
                                                           , "UInt", Flags
                                                           , "UInt")

    return A_LastError == 0
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shemptyrecyclebina
