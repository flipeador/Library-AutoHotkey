/*
    Retrieves the parent directory for the specified path.
    Parameters:
        Path:
            A string containing the path to a directory or file.
            The function does not check for the path existence.
        ParentCount:
            By default the first parent directory is retrieved, to retrieve parent of parent use 2 and so on.
    Return value:
        Returns a string containing the parent directory.
        The returned directory never ends with a backslash ("\").
        Root directories end with a colon (":").
*/
PathGetParent(Path, ParentCount := 1)
{
    if (!(ParentCount is "Number") || ((ParentCount:=Integer(ParentCount)) < 0))
        throw Exception("PathGetParent function - invalid parameter #2.", -1)

    local Pos
    Path := Trim(Path, "\`s`t")

    while ((ParentCount--) && (Pos:=InStr(Path,"\",,-1)))
        Path := SubStr(Path, 1, Pos-1)

    return Path . (StrLen(Path)==1?":":"")
}





/*
    Retrieves the first existing directory of the specified path.
    Parameters:
        Path:
            A string containing the path to a directory or file.
    Return value:
        Returns a string with the first existing directory found.
        If no directory exists, it returns the top parent directory.
        The returned directory never ends with a backslash ("\").
        Root directories end with a colon (":").
*/
PathGetParent2(Path)
{
    Path := Trim(Path, "\`s`t")
    while (InStr(Path,"\") && !DirExist(Path))
        Path := SubStr(Path, 1, InStr(Path,"\",,-1)-1)
    return Path . (StrLen(Path)==1?":":"")
}





/*
MsgBox PathGetParent("X")              ; X:
MsgBox PathGetParent("X:")             ; X:
MsgBox PathGetParent("X:\")            ; X:
MsgBox PathGetParent("X:\A")           ; X:
MsgBox PathGetParent("X:\A\B\",2)      ; X:
MsgBox PathGetParent("X:\A\B\")        ; X:\A
MsgBox PathGetParent("XXXXXXXXX")      ; XXXXXXXXX
MsgBox PathGetParent("\123\456\789\")  ; 123\456
MsgBox PathGetParent(A_ComSpec)        ; %A_WinDir%\System32
*/
