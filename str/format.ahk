/*
    Creates an Ascii progress bar.
*/
StrProgressBar(Current, Max := 100, Length := 100, Char := "|")
{
    local Percent := (Current / Max) * 100, Progress := ""
    Percent := Percent > 100 ? 100 : Percent < 0 ? 0 : percent
    loop (Round(((Percent / 100) * Length)))
        Progress .= Char
    loop (Length - Round(((Percent / 100) * Length)))
        Progress .= A_Space
    return { Progress:Progress , Percent:Percent }
} ; https://autohotkey.com/boards/viewtopic.php?f=6&t=100





/*
    Example:
        MsgBox(StrLineFormat("Hello World!",6,4,"_","-","-"))
*/
StrLineFormat(Text, LineLength, LeadingSpaces := 0, Prefix1 := "", Prefix2 := "", Suffix := "")
{
    local N := 0 - LineLength + 1, Str := ""
    loop Ceil(StrLen(Text) / LineLength)
        Str .= Format("{3}{1:" . LeadingSpaces . "s}{4}{2}{5}`n"
            ,, SubStr(Text,N+=LineLength,LineLength), Prefix1, Prefix2, Suffix)
    return SubStr(Str, 1, -1)
} ; https://www.autohotkey.com/boards/viewtopic.php?t=35964





/*
    Converts a numeric value into a string that represents the number in bytes, kilobytes, megabytes, or gigabytes, depending on the size.
    Parameters:
        Number:
            The numeric value to be converted.
        Flags:
            One of the following values that specifies whether to round or truncate undisplayed digits.
            ┌───────┬────────────────────────────────────────────────┬───────────────────────────────────────┐
            │ Value │ Constant                                       │ Meaning                               │
            ├───────┼────────────────────────────────────────────────┼───────────────────────────────────────┤
            │ 1     │ SFBS_FLAGS_ROUND_TO_NEAREST_DISPLAYED_DIGIT    │ Round to the nearest displayed digit. │
            │ 2     │ SFBS_FLAGS_TRUNCATE_UNDISPLAYED_DECIMAL_DIGITS │ Discard undisplayed digits.           │
            └───────┴────────────────────────────────────────────────┴───────────────────────────────────────┘
    Return value:
        If this function succeeds, the return value is the converted string.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        In Windows 10, size is reported in base 10 rather than base 2. For example, 1 KB is 1000 bytes rather than 1024.
    Example:
        MsgBox(StrFormatByteSize((1024**2)*67.7))  ; 67.7 MB
*/
StrFormatByteSize(Number, Flags := 1)
{
    local Buffer := BufferAlloc(2*(30+1))  ; Buffer that receives the converted string.
    DllCall("Shlwapi.dll\StrFormatByteSizeEx", "Int64", Number          ; ULONGLONG  ull.
                                             ,   "Int", Flags           ; SFBS_FLAGS flags.
                                             ,   "Ptr", Buffer          ; PWSTR      pszBuf.
                                             ,  "UInt", Buffer.Size//2  ; UINT       cchBuf.
                                             , "HRESULT")               ; HRESULT    ReturnValue.
    return StrGet(Buffer)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strformatbytesizeex





StrFormatCmdLn(CmdLn, EscapeChr := "")
{
    local param, cmd := ""
    for param in (IsObject(CmdLn) ? CmdLn : Map())
        param := Trim(String(param)), cmd .= (param~="^\s*$")||(param==EscapeChr)
        ? "":(((param~="\s+")&&((EscapeChr=="")||(!(SubStr(param,1,StrLen(EscapeChr))==EscapeChr))))
        ? "`"" . Trim(param) . "`"":Trim(LTrim(param,"*"))) . A_Space
    return IsObject(CmdLn) ? Trim(cmd) : Trim(String(CmdLn))
}
