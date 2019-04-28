/*
    Busca por los directorios superiores al directorio especificado por su existencia. Si ningún directorio existe, devuelve una cadena vacía.
    Ejemplo:
        MsgBox DirGetExist(A_WinDir . "\XXXXXXXXXXXXXX")    ; A_WinDir (ej. "C:\Windows")
        MsgBox DirGetExist("C:\")    ; "C:"
        MsgBox DirGetExist("C")    ; "C:"
        MsgBox DirGetExist("X")    ; ""
*/
DirGetExist(DirName)
{
    While (StrLen(DirName:=Trim(DirName)) > 3 && !DirExist(DirName))
        DirName := SubStr(DirName, 1, InStr(RTrim(DirName, "\"), "\",, -1) - 1)
    DirName := RTrim(StrLen(DirName) > 3 ? DirName : SubStr(DirName, 1, 1) . ":", "\")
    Return DirExist(DirName) ? DirName : ""
}
