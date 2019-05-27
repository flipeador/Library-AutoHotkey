/*
    Compares two versions and determines which is greater or lesser, or if they are the same.
    Parameters:
        Version1:
            The first version.
        Version2:
            The second version.
    Return value:
       -1     Version1 < Version2.
        0     Version1 = Version2.
        1     Version1 > Version2.
*/
VersionCompare(Version1, Version2)
{
    Version1 := StrSplit(RegExReplace(Version1,"[^\w\.]-?.*"), ".")
    Version2 := StrSplit(RegExReplace(Version2,"[^\w\.]-?.*"), ".")
    
    loop (Version1.MaxIndex() > Version2.MaxIndex() ? Version1.MaxIndex() : Version2.MaxIndex())
    {
        if (Version1.MaxIndex() < A_Index)
            Version1[A_Index] := 0
        if (Version2.MaxIndex() < A_Index)
            Version2[A_Index] := 0
        if (Version1[A_Index] > Version2[A_Index])
            return 1
        if (Version2[A_Index] > Version1[A_Index])
            return -1
    }

    return 0
}





/*
MsgBox(VersionCompare("1.0.1","1.0.2"))  ; -1
MsgBox(VersionCompare("1.0.2","1.0.2"))  ; 0
MsgBox(VersionCompare("1.0.3","1.0.2"))  ; 2
*/
