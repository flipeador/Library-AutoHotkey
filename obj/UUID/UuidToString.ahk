/*
    Converts a universally unique identifier (UUID) into a string of printable characters.
    Parameters:
        Uuid:
            Specifies the binary-format UUID to convert.
    Return value:
        If the function succeeds, the return value is a string in the form "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}".
        If the function fails, the return value is zero.
*/
UuidToString(Uuid)
{
    local Buffer := BufferAlloc(2*38+2)
    if ! DllCall("Ole32.dll\StringFromGUID2", "Ptr", Uuid, "Ptr", Buffer, "Int", Buffer.Size//2)
        return 0

    return StrGet(Buffer, 38, "UTF-16")
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/wdm/nf-wdm-rtlstringfromguid
