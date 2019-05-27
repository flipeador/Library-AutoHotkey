/*
    Retrieve parent directory for a file or folder.
    Parameters:
        Path:
            Path to a directory or File. The function does not check for the path existence.
        ParentCount:
            By default the first parent directory is retrieved, to retrieve parent of parent use 2 and so on.
    Return value:
        Returns the parent directory.
    Remarks:
        If there is no parent directory, the drive letter will be returned.
*/
DirGetParent(Path, ParentCount := 1)
{
    local

    if (Type(ParentCount) !== "Integer" || ParentCount < 0)
        throw Exception("DirGetParent function: invalid parameter #2.", -1)

    Path := Trim(Path, "\`s`t")

    while (ParentCount--)
    {
        if (pos := InStr(Path, "\",, -1))
        {
            Path := SubStr(Path, 1, pos-1)
        }
    }

    return StrLen(Path) == 1 ? Path . ":" : Path
}





/*
MsgBox DirGetParent("X")              ; X:
MsgBox DirGetParent("X:")             ; X:
MsgBox DirGetParent("X:\")            ; X:
MsgBox DirGetParent("X:\A")           ; X:
MsgBox DirGetParent("X:\A\B\",2)      ; X:
MsgBox DirGetParent("X:\A\B\")        ; X:\A
MsgBox DirGetParent("XXXXXXXXX")      ; XXXXXXXXX
MsgBox DirGetParent("\123\456\789\")  ; 123\456
MsgBox DirGetParent(A_ComSpec)        ; %A_WinDir%\System32
*/
