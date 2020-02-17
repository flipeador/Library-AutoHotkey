/*
    Expands enviroment variables in the specified string.
    Parameters:
        Path:
            A string in which to perform the operation.
    Return value:
        Return the formatted string.
*/
PathExpandVar(Path)
{
    local

    Pos    := 1
    Needle := "%(\w*)%"

    while (Pos := RegExMatch(Path, Needle, R, Pos))
    {
        if (Len := StrLen(Text:=EnvGet(Trim(R[0],"%"))))
            Path := RegExReplace(Path, Needle, Text,, 1, Pos)
        Pos += Len || StrLen(R[0])
    }

    return Path
}
