/*
    Determines whether a specified path is valid or not.
    Parameters:
        Path:
            A string that contains the path to be tested.
    Return value:
        0  ERROR_PATH_NOT_FOUND   The system cannot find the path specified.
        1  ERROR_DIRECTORY        The path is a file.
        2  DIRECTORY_EMPTY        The path is an empty directory.
        3  DIRECTORY_NON_EMPTY    The path is a directory and contains at least one file.
*/
PathQuery(Path)
{
    A_LastError := 0
    return DllCall("Shlwapi.dll\PathIsDirectoryEmptyW", "Ptr", &Path)
         ?                             2                                   ; DIRECTORY_EMPTY.
         : A_LastError == 0x00000003 ? 0                                   ; ERROR_PATH_NOT_FOUND.
         : A_LastError == 0x0000010B ? 1                                   ; ERROR_DIRECTORY.
         : A_LastError == 0x00000000 ? 3                                   ; DIRECTORY_NON_EMPTY.
         : 0                                                               ; ERROR?.
} ; https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectoryemptyw





/*
EmptyDir := A_Temp . "\temp"  ; Warning! this directory will be completely deleted.
DirDelete(EmptyDir, TRUE)
DirCreate(EmptyDir)

MsgBox(PathQuery("z:\xxx.xxx"))  ; 0 (ERROR_PATH_NOT_FOUND)
MsgBox(PathQuery(A_ComSpec))     ; 1 (ERROR_DIRECTORY)
MsgBox(PathQuery(EmptyDir))      ; 2 (DIRECTORY-EMPTY)
MsgBox(PathQuery(A_WinDir))      ; 3 (DIRECTORY-NON_EMPTY)
*/
