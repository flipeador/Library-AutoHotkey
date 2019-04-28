/*
    https://autohotkey.com/boards/viewtopic.php?f=13&t=28247&p=132936#p132929
*/


"".base.Length := Func("StrLen")    ; R := Var.Length()
"".base.base := { __Get: Func("__DBOG")
                , __Set: Func("__DBOS") }

__DBOG(Var, Param*)
{
    If (!ObjLength(Param))    ; R := Var[]
        Return Var

    If (Param[1] = "Length")    ; R := Var.Length
        Return StrLen(Var)

    Return Param[2] == "" ? Param[3] == "" ? SubStr(Var, Param[1], 1)    ; R := Var[n]
                                           : SubStr(Var, Param[1], Param[3] - Param[1] + 1)    ; R := Var[n,, n]
                          : SubStr(Var, Param[1], Param[2])    ; R := Str[n, n]
}

__DBOS(ByRef Var, Param*) {
    If (ObjLength(Param) == 1)    ; Var[] := X
        Var := Param[1]
    
    Else If (ObjLength(Param) == 2)    ; Var[n] := X
        Var := SubStr(Var, 1, Param[1] - 1) . Param[2] . SubStr(Var, Param[1] + 1)
    
    Else If (ObjLength(Param) == 3)    ; Var[n, n] := X
        Var := SubStr(Var, 1, Param[1] - 1) . Param[3] . SubStr(Var, Param[1] + Param[2])
    
    Return 0
}
