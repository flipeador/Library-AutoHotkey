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

    Needle := "%(\w*)%", Pos := 1
    while Pos := RegExMatch(Path, Needle, Output, Pos)
    {
        if ((VarText:=EnvGet(Trim(Output[0],"%"))) !== "")
            Path := RegExReplace(Path, Needle, VarText,, 1, Pos)
        Pos += StrLen(VarText == "" ? Output[0] : VarText)
    }

    return Path
}





;MsgBox(PathExpandVar("%SystemRoot%"))
