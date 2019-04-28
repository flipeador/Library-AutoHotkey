/*
    Compara dos cadenas codificadas en UTF-16LE.
    Parámetros:
        s1:
            Primera cadena
        s2:
            Segunda cadena.
        count:
            La cantidad de caracteres a comparar. Si es una cadena vacía compara todos los caracteres.
            Especificar cero para una comparación no sensible a minúsculas y mayúsculas.
    Return:
        < 0  = s1 es menor que s2. -1 si se utilizó memcmp o -2 si se utilizó StrLen.
          0  = s1 es identica a s2. Utiliza memcmp.
        > 0  = s1 es mayor que s2. 1 si se utilizó memcmp o 2 si se utilizó StrLen.
    Ejemplo:
        MsgBox "StrCompare(`"a`",`"aa`")    `t= "   . StrCompare("a","aa")    . "`n"    ; -2
             . "StrCompare(`"a`",`"b`")     `t= "   . StrCompare("a","b")     . "`n"    ; -1
             . "StrCompare(`"a`",`"a`")     `t=  "  . StrCompare("a","a")     . "`n"    ;  0
             . "StrCompare(`"b`",`"a`",-1)  `t=  "  . StrCompare("b","a")     . "`n"    ;  1
             . "StrCompare(`"aa`",`"a`",-1) `t=  "  . StrCompare("aa","a")    . "`n"    ;  2
             . "StrCompare(`"a`",`"b`",-1)  `t=  "  . StrCompare("a","b",0)   . "`n"    ;  3
*/
StrCompare(ByRef s1, ByRef s2, count := "")
{
    Local l1 := StrLen(s1), l2 := StrLen(s2)
    Return l1 > l2 ? 2 : l1 < l2 ? -2 : count == 0 ? (s1 = s2 ? 0 : 3) : DllCall("msvcrt.dll\memcmp", "UPtr", &s1, "UPtr", &s2, "UPtr", count == "" ? l1 * 2 : Count, "CDecl")
}
