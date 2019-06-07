StrRepeat(ByRef String, Count)
{
    return StrReplace(Format("{:" . Count . "}", ""), A_Space, String)
}
