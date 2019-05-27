/*
    Truncates a path to fit within a certain number of characters by replacing path components with ellipses.
    Parameters:
        Path:
            A string that contains the path to be altered.
        CharMax:
            The maximum number of characters to be contained in the new string.
    Return value:
        Returns the string that has been altered.
*/
PathCompact(Path, CharMax)
{
    local Buffer := BufferAlloc(2*CharMax+2)  ; Number of characters to be contained in the new string, including the terminating null character.
    DllCall("Shlwapi.dll\PathCompactPathExW", "Ptr", Buffer, "Ptr", &Path, "UInt", CharMax+1, "UInt", 0)
    return StrGet(Buffer, "UTF-16")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-pathcompactpathexw





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
        Returns a string that contains the modified path.
*/
PathCompactDC(hDC, Path, Width)
{
    return DllCall("Shlwapi.dll\PathCompactPathW", "Ptr", hDC, "Str", Path, "UInt", Width)
         ? Path : ""
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-pathcompactpathw
