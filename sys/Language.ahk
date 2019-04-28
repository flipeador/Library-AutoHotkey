/*
    Recupera la descripción para el idioma asociado con un identificador de idioma Microsoft.
    LangID: https://msdn.microsoft.com/en-us/library/windows/desktop/dd318693%28v=vs.85%29.aspx
    MsgBox VerLanguageName("0x" . A_Language)
*/
VerLanguageName(LangID, Flag := 0)
{
    If (!(LangID is "Integer"))
        Throw Exception("Function VerLanguageName invalid parameter #1.", -1, LangID)

    Local Lang := ""
    VarSetCapacity(Lang, 200)
    DllCall("Version.dll\VerLanguageNameW", "UInt", LangID, "Str", Lang, "UInt", 100, "UInt")
    Return Lang
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms647463(v=vs.85).aspx





/*
    Convierte un identificador de configuración regional a un nombre de configuración regional.
    LangID: https://msdn.microsoft.com/en-us/library/windows/desktop/dd318693%28v=vs.85%29.aspx
*/
LCIDToLocaleName(LangID, Flags := 0)    ; LOCALE_ALLOW_NEUTRAL_NAMES = 0x08000000
{
    If (!(LangID is "Integer"))
        Throw Exception("Function LCIDToLocaleName invalid parameter #1.", -1, LangID)

    VarSetCapacity(Name, 200)
    DllCall("Kernel32.dll\LCIDToLocaleName", "UInt", LangID, "Str", Name, "Int", 100, "UInt", Flags)
    Return Name == "" ? FALSE : Name
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318698(v=vs.85).aspx
