StrLineFormat(Text, LineLength, LeadingSpaces := 0, Prefix1 := "", Prefix2 := "", Suffix := "")
{
    local N := 0 - LineLength + 1, Str := ""
    loop Ceil( StrLen(Text) / LineLength )
        Str .= Format("{3}{1:" . LeadingSpaces . "s}{4}{2}{5}`n"
                   ,, SubStr(Text,N+=LineLength,LineLength), Prefix1, Prefix2, Suffix)
    return SubStr(Str, 1, -1)
} ; https://www.autohotkey.com/boards/viewtopic.php?t=35964





; MsgBox(StrLineFormat("Hello World!",6,4,"_","-","-"))
