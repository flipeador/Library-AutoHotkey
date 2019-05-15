/*
    Converts a numeric value into a string that represents the number in bytes, kilobytes, megabytes, or gigabytes, depending on the size.
    Parameters:
        Number:
            The numeric value to be converted.
        Flags:
            1 SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT      Round to the nearest displayed digit.
            2 SFBS_FLAGS_TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS   Discard undisplayed digits.
    Remarks:
        In Windows 10, size is reported in base 10 rather than base 2. For example, 1 KB is 1000 bytes rather than 1024.
*/
StrFormatByteSize(Number, Flags := 1)
{
    local

    VarSetCapacity(Buffer, 30 * 2, 0)

    ; StrFormatByteSizeEx function.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-strformatbytesizeex.
    DllCall("Shlwapi.dll\StrFormatByteSizeEx", "Int64", Number, "Int", Flags, "Str", Buffer, "UInt", 30)
    
    return Buffer
}


; MsgBox(StrFormatByteSize(1024 ** 2 * 67.7))  ; 67.7 MB
