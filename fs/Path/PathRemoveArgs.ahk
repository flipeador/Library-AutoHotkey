/*
    Removes any arguments from a given path.
    Parameters:
        A string that contains the path from which to remove arguments.
*/
PathRemoveArgs(Path)
{
    DllCall("Shlwapi.dll\PathRemoveArgsW", "Str", Path)
    return Path
} ; https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathremoveargsw
