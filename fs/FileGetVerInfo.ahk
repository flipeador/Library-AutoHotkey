/*
    Recupera la información de versión del archivo especificado.
    Parámetros:
        Filename:
            El nombre del archivo a consultar.
        Props:
            Las propiedades a consultar separadas por "|". La propiedad solo se incluirá en la lista si existe.
        LangCP:
            El identificador de idioma de las propiedades que se van a recuperar. Si es una cadena utiliza el primer idioma encontrado.
            Este parámetro puede ser de tipo entero, por ejemplo: 0x0C0A. La cadena "0C0A" o "0C0A04B0" también es válido.
    Return:
        Si tuvo éxito devuelve un objeto, o cero en caso contrario.
        El objeto posee la siguiente estructura:
            _Buffer            = Representa a la estructura VS_VERSIONINFO.
            VS_VERSIONINFO     = Un objeto con las claves «ptr» y «size» que contiene un puntero y el tamaño de la estructura VS_VERSIONINFO, respectivamente.
            VS_FIXEDFILEINFO   = Un objeto con las claves «ptr» y «size» que contiene un puntero y el tamaño de la estructura VS_FIXEDFILEINFO, respectivamente.
            _FileVersion       = La versión binaria del archivo en el formato "0.0.0.0".
            _ProductVersion    = La versión binaria del producto en el formato "0.0.0.0".
            _LangCP            = El identificador de idioma de las propiedades.
            [nombre propiedad] = Valor.
    Ejemplo:
        VerInfo := FileGetVerInfo(A_ComSpec, "FileDescription|FileVersion")
        MsgBox "LangCP: " . VerInfo._LangCP . "`nFileDescription: " . VerInfo.FileDescription . "`nFileVersion: " . VerInfo.FileVersion
*/
FileGetVerInfo(File, Props := "", LangCP := "")    ; WIN_V+
{
    ; GetFileVersionInfoSizeEx function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winver/nf-winver-getfileversioninfosizeexa
    local Size := DllCall("Version.dll\GetFileVersionInfoSizeExW", "UInt", 1, "UPtr", &File, "Ptr", 0, "UInt")    ; FILE_VER_GET_LOCALISED = 1
    if (!Size)
        return FALSE
    
    local VerInfo := {_Buffer: ""}
    VerInfo.SetCapacity("_Buffer", Size)
    local Address := VerInfo.GetAddress("_Buffer")    ; VS_VERSIONINFO
    VerInfo.VS_VERSIONINFO := { ptr: Address, size: Size }

    ; GetFileVersionInfoEx function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winver/nf-winver-getfileversioninfoexa
    if !DllCall("Version.dll\GetFileVersionInfoExW", "UInt", 1, "UPtr", &File, "UInt", 0, "UInt", Size, "UPtr", Address)    ; FILE_VER_GET_LOCALISED = 1
        return FALSE

    ; VerQueryValue function
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winver/nf-winver-verqueryvaluea
    local VS_FIXEDFILEINFO := 0, Length := 0, pData := 0
    DllCall("Version.dll\VerQueryValueW", "UPtr", Address, "Str", "\", "UPtrP", VS_FIXEDFILEINFO, "UIntP", Length)

    ; https://docs.microsoft.com/es-es/windows/desktop/api/verrsrc/ns-verrsrc-tagvs_fixedfileinfo
    VerInfo.VS_FIXEDFILEINFO := { ptr: VS_FIXEDFILEINFO, size: Length }    ; VS_VERSIONINFO.VS_FIXEDFILEINFO

    VerInfo._FileVersion := [NumGet(VS_FIXEDFILEINFO+8, "UInt"), NumGet(VS_FIXEDFILEINFO+12, "UInt")]
    VerInfo._FileVersion := ((VerInfo._FileVersion[1] >> 16) & 0xFFFF) . "." . (VerInfo._FileVersion[1] & 0xFFFF) . "."   ; VS_FIXEDFILEINFO.dwFileVersionMS
                          . ((VerInfo._FileVersion[2] >> 16) & 0xFFFF) . "." . (VerInfo._FileVersion[2] & 0xFFFF)         ; VS_FIXEDFILEINFO.dwFileVersionLS

    VerInfo._ProductVersion := [NumGet(VS_FIXEDFILEINFO+16, "UInt"), NumGet(VS_FIXEDFILEINFO+20, "UInt")]
    VerInfo._ProductVersion := ((VerInfo._ProductVersion[1] >> 16) & 0xFFFF) . "." . (VerInfo._ProductVersion[1] & 0xFFFF) . "."   ; VS_FIXEDFILEINFO.dwFileVersionMS
                             . ((VerInfo._ProductVersion[2] >> 16) & 0xFFFF) . "." . (VerInfo._ProductVersion[2] & 0xFFFF)         ; VS_FIXEDFILEINFO.dwFileVersionLS

    if (LangCP == "")
    {
        ; Retrieves a pointer to an array of language and code page identifiers («Value» member of «Var» structure)
        DllCall("Version.dll\VerQueryValueW", "UPtr", Address, "Str", "\VarFileInfo\Translation", "UPtrP", pData, "UIntP", Length)
        if (pData > 3)    ; pData = [ "00000000" , "00000000" , .. ]        |      Loop ( pData // 4 )
        {
            VerInfo._LangCP := Format("{:04X}{:04X}", NumGet(pData, "UShort"), NumGet(pData+2, "UShort"))
            Loop Parse, Props, "|"
                if DllCall("Version.dll\VerQueryValueW", "UPtr", Address, "Str", "\StringFileInfo\" . VerInfo._LangCP . "\" . A_LoopField, "UPtrP", pData, "UIntP", Length)
                    VerInfo[A_LoopField] := StrGet(pData, Length, "UTF-16")
        }
    }
    else
    {
        VerInfo._LangCP := Type(LangCP) == "Integer" ? Format("{:04X}",LangCP) . "04B0" : ( StrLen(LangCP) < 8 ? SubStr(LangCP,1,4) . "04B0" : SubStr(LangCP,1,8) )
        if ( !("0x" . SubStr(VerInfo._LangCP,1,4) is "integer") || !("0x" . SubStr(VerInfo._LangCP,-4) is "integer") )
            throw Exception("Function " . A_ThisFunc . " invalid parameter #3", -1, "Invalid language")
        Loop Parse, Props, "|"
            if DllCall("Version.dll\VerQueryValueW", "UPtr", Address, "Str", "\StringFileInfo\" . VerInfo._LangCP . "\" . A_LoopField, "UPtrP", pData, "UIntP", Length)
                VerInfo[A_LoopField] := StrGet(pData, Length, "UTF-16")
    }

    return VerInfo
}
