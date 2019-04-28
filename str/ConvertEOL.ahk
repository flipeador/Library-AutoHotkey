/*
    Convierte los caracteres usados como fin de línea en la cadena especificada.
    Parámetros:
        Str:
            La cadena de caracteres a convertir.
        EOL:
            0 = no eol | 1 = `r`n | 2 = `n | 3 = `r
    Ejemplo:
        MsgBox QueryEOL(ConvertEOL("a`nb")) . "`n" . QueryEOL(ConvertEOL("a`rb",1)) . "`n" . QueryEOL(ConvertEOL("a`r`nb",2)) . "`n" . QueryEOL(ConvertEOL("a`r`rb",3))
*/
ConvertEOL(Str, EOL := 0)
{
    Str := StrReplace(StrReplace(Str, "`r`n", "`n"), "`r", "`n")
    Return EOL == 2 ? Str : StrReplace(Str, "`n", EOL == 3 ? "`r" : EOL == 1 ? "`r`n" : "")
}





/*
    Detecta el caracter de fin de línea en la cadena especificada.
        Str:
            La cadena de caracteres a consultar.
    Return:
        0 = no eol | 1 = `r`n | 2 = `n | 3 = `r
*/
QueryEOL(Str)
{
    Return InStr(Str, "`r`n") ? 1 : InStr(Str, "`n") ? 2 : InStr(Str, "`r") ? 3 : 0
}
