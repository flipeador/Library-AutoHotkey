/*
    Truncates a path to fit within a certain number of characters by replacing path components with ellipses.
    Parameters:
        Path:
            A string that contains the path to be altered.
        CharMax:
            The maximum number of characters to be contained in the new string.
    Return value:
        If the function succeeds, the return value is a string that has been altered.
        If the function fails, the return value is zero.
*/
PathCompact(Path, CharMax)
{
    local Buffer := BufferAlloc(2*CharMax+2)
    return DllCall("Shlwapi.dll\PathCompactPathExW",  "Ptr", Buffer
                                                   , "UPtr", &Path
                                                   , "UInt", Buffer.Size//2
                                                   , "UInt", 0)
         ? StrGet(Buffer)  ; Ok.
         : 0               ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathcompactpathexw





/*
    Truncates a file path to fit within a given pixel width by replacing path components with ellipses.
    Parameters:
        hDC:
            A handle to the device context used for font metrics. This value can be NULL.
        Path:
            A string that contains the path to be modified.
        Width:
            The width, in pixels, in which the string must fit.
    Return value:
        If the function succeeds, the return value is a string that contains the modified path.
        If the function fails, the return value is zero.
*/
PathCompactDC(hDC, Path, Width)
{
    return DllCall("Shlwapi.dll\PathCompactPathW", "Ptr", hDC, "Str", Path, "UInt", Width)
         ? Path  ; Ok.
         : 0     ; Error.
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-pathcompactpathw
