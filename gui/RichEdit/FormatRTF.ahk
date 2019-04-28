/*
    Transforms a unicode string to be used as literal text in RTF.
*/
RE_FormatRTF(ByRef RTF)
{
    local RTF2 := ""
    loop parse, StrReplace(RTF, "\", "\\")
        RTF2 .= "\u" . Ord(A_LoopField) . "?"  ; \u0000?
    return RTF2
} ; https://es.wikipedia.org/wiki/Rich_Text_Format
