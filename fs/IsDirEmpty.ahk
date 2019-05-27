/*
    Determines whether a specified path is an empty directory.
    Parameters:
        Path:
            A string that contains the path to be tested.
    Return value:
        TRUE     The path is an empty directory.
        FALSE    The path is not a directory, contains at least one file or does not exist.
    A_LastError:
        0x00000003  ERROR_PATH_NOT_FOUND    The system cannot find the path specified.
        0x0000010B  ERROR_DIRECTORY         The path is not a directory.
*/ 
IsDirEmpty(Path)
{
    A_LastError := 0
    return DllCall("Shlwapi.dll\PathIsDirectoryEmptyW", "Ptr", &Path)
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-pathisdirectoryemptyw
