#Include ..\MCode.ahk


/*
    Recupera la longitud de una cadea, en caracteres UTF-32.
    Parámetros:
        String: La cadena UTF-16LE.
    Return:
        Devuelve el número de caracteres enteros en la cadena especificada en String.
    Ejemplo:
        MsgBox("StrLen: " . StrLen(Chr(128064)) . "`nStrLen2: " . StrLen2(Chr(128064)))
*/
StrLenU4(String)
{
    Static pUTF8Len := 0
    Local Buffer := "", Size := 0

    VarSetCapacity(Buffer, Size := StrPut(String, "UTF-8") - 1)
    StrPut(String, &Buffer, "UTF-8")

    If (!pUTF8Len)
        pUTF8Len := MCode("2,x86:i0wkBA+2EYTSdCSDwQExwIHiwAAAAIPCgA+VwoPBAQ+20gHQD7ZR/4TSdeTCBAAxwMIEAJCQkJCQkJCQkJCQkA==,x64:D7YRhNJ0KUiDwQExwA8fAIHiwAAAAIPCgA+VwkiDwQEPttIB0A+2Uf+E0nXjw2aQMcDDkJCQkJCQkJCQkJCQkA==")
    
    Return (DllCall(pUTF8Len, "UPtr", &Buffer))

    /* CON AHK (mucho mas lento)
    Length := 0
    Loop (Size)
        If ((NumGet(Buffer, A_Index - 1, "UChar") & 0xC0) != 0x80)
            ++Length

    Return (Length)
    */
}





/*
    Esta es una versión sin DllCall, pero mucho más lenta que la anterior.
*/
StrLenUnicode(data)
{
    Local i := 0
    RegExReplace(data, "s).", "", i)
    Return i
} ; https://autohotkey.com/boards/viewtopic.php?t=22036#p106284
