/*
    Abre un directorio en el Explorador de Archivos de Windows y selecciona los elementos especificados.
    Parámetros:
        DirName:
            El nombre del directorio que se va a abrir.
        Files:
            Un Array con el nombre de los archivos o carpetas a seleccionar. Los archivos que no existan son omitidos.
            Si especifica una cadena vacía o un Array vacío utiliza la función Run para abrir el directorio especificado.
        Flags:
            0x0001 = Seleccione un elemento y pone su nombre en el modo de edición. sólo se puede utilizar cuando se especifica un solo elemento.
            0x0002 = Seleccione el elemento o los elementos en el escritorio en lugar de en una ventana de Explorador de Windows. si el escritorio está detrás de las ventanas abiertas, no se hará visible.
    Return:
        Devuelve un valor distinto de cero si tuvo éxito, o cero en caso contrario.
    Ejemplo:
        OpenFolderAndSelectItems(A_WinDir, ["explorer.exe", "hh.exe", "system32"])
*/
OpenFolderAndSelectItems(DirName, Files := "", Flags := 0)
{
    If (Files != "" && !IsObject(Files))
        Throw Exception("Function OpenFolderAndSelectItems invalid parameter 2", -1)

    If (!DirExist(DirName := RTrim(DirName, "\")))
        Return FALSE

    If (Files == "" || !ObjLength(Files))
    {
        Run("`"" . DirName . "`"")
        Return TRUE
    }

    ; _ITEMIDLIST structure
    ; https://docs.microsoft.com/es-es/windows/desktop/api/shtypes/ns-shtypes-_itemidlist
    Local ITEMLIST := ""
    VarSetCapacity(ITEMLIST, ObjLength(Files) * A_PtrSize)

    Local Each := "", File := "", PIDL := 0, Count := 0
    For Each, File In Files
    {
        ; SHParseDisplayName function
        ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-shparsedisplayname
        If (!DllCall("Shell32.dll\SHParseDisplayName", "Str", DirName . "\" . File, "UPtr", 0, "UPtrP", PIDL, "UInt", 0, "UPtr", 0))
            NumPut(PIDL, &ITEMLIST + (A_Index - 1) * A_PtrSize, "UPtr"), ++Count
    }
    If (!Count)
        Return FALSE

    ; SHOpenFolderAndSelectItems function
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-shopenfolderandselectitems
    DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &DirName, "UPtr", 0, "UPtrP", PIDL, "UInt", 0, "UPtr", 0)
    Local R := DllCall("Shell32.dll\SHOpenFolderAndSelectItems", "UPtr", PIDL, "UInt", Count, "UPtr", &ITEMLIST, "UInt", Flags)
    
    ; CoTaskMemFree function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/combaseapi/nf-combaseapi-cotaskmemfree
    If (PIDL)
        DllCall("Ole32.dll\CoTaskMemFree", "UPtr", PIDL)
    Loop (Count)
        DllCall("Ole32.dll\CoTaskMemFree", "UPtr", NumGet(&ITEMLIST + (A_Index - 1) * A_PtrSize, "UPtr"))

    Return !R
}
