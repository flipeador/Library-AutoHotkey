/*
    Retrieves the full path and file name of the specified file.
    Parameters:
        Path:
            A short (the 8.3 form) or long file name. This string can also be a share or volume name.
        WorkingDir:
            The drive and directory to determine the full path and file name of the specified path.
            If the specified directory does not exist, the function uses the current working directory.
    Return value:
        If the function succeeds, the return value is the string for the drive and path.
        If the function fails, the return value is zero.
*/
GetFullPathName(Path, WorkingDir := "")
{
    local

    RestoreWD := ""
    if DirExist(WorkingDir)
    {
        RestoreWD    := A_WorkingDir
        A_WorkingDir := WorkingDir
    }

    Length := DllCall("Kernel32.dll\GetFullPathNameW", "Ptr", &Path, "UInt", 0, "Ptr", 0, "Ptr", 0, "UInt")
    VarSetCapacity(Buffer, 2*Length)
    Length := DllCall("Kernel32.dll\GetFullPathNameW", "Ptr", &Path, "UInt", Length, "Str", Buffer, "Ptr", 0, "UInt")

    if DirExist(RestoreWD)
        A_WorkingDir := RestoreWD

    Return Length ? Buffer : 0
} ; https://docs.microsoft.com/es-es/windows/desktop/api/fileapi/nf-fileapi-getfullpathnamew
