/*
    Shuffles the characters in the specified string.
*/
Shuffle(String, Delimiter := "")
{
    local

    Flag      := Delimiter == "" ? TRUE : FALSE
    Delimiter := Flag            ? "`n" : Delimiter

    String := Sort(RegExReplace(String, ".", "$0" . Delimiter)
                 , "Random D" . Delimiter)

    return Flag ? StrReplace(String,Delimiter)
                : SubStr(String, 1, -StrLen(Delimiter))
} ; https://autohotkey.com/board/topic/64450-help-with-scrambling/





/*
Scramble(Word, Delimiter := "")
{
    local

    StrW := ""
    Word := StrSplit(Word)  ; Array of characters.

    loop Word.Length()
    {
        Rand := Random(1, Word.Length())
        StrW .= Word[Rand] . Delimiter
        Word.RemoveAt(Rand)
    }

    return RTrim(StrW, Delimiter)
}
*/
