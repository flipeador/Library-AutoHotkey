/*
    Converts a string-format UUID into a binary-format UUID.
    Parameters:
        sUuid:
            The string representation of the UUID.
    Return value:
        If the function succeeds, the return value is a Buffer object.
        If the function fails, the return value is zero.
*/
UuidFromString(sUuid)
{
    local Buffer := BufferAlloc(16)  ; sizeof(UUID) = 16.
    if DllCall("Ole32.dll\CLSIDFromString", "Str", sUuid, "Ptr", Buffer)
        return 0

    return Buffer
} ; https://docs.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-clsidfromstring
