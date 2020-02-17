/*
    Retrieves a description string for the language associated with a specified binary Microsoft language identifier.
    Parameters:
        LangID:
            The binary language identifier. For a complete list of the language identifiers, see Language Identifiers.
            If the identifier is unknown, the return valeu is a default string ("Language Neutral").
    Return value:
        If the function succeeds, the return value is a string.
        If the function fails, the return value is zero. Unknown language identifiers do not produce errors.
    Language Identifiers:
        https://msdn.microsoft.com/076e2a43-256a-4646-a5c8-1d48ab08ce1a
*/
LangGetName(LangID)
{
    local Buffer := BufferAlloc(100)
    return DllCall("Version.dll\VerLanguageNameW", "UInt", LangID, "Ptr", Buffer, "UInt", Buffer.Size//2)
         ? StrGet(Buffer)  ; Ok.
         : 0               ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/winver/nf-winver-verlanguagenamew





/*
    Retrieves the language identifier associated with a specified language description string.
    Parameters:
        LangName:
            The language description string.
    Return value:
        If the function succeeds, the return value is a language identifier.
        If the function fails, the return value is zero.
*/
LangGetID(LangName)
{
    loop (0x500A)
        if (LangGetName(A_Index) = LangName)
            return A_Index
    return 0
}





/*
    Converts a locale identifier to a locale name.
    Parameters:
        LocaleID:
            The locale identifier to translate. You can use the MAKELANGID function to create a locale identifier.
        Flags:
            0x08000000  LOCALE_ALLOW_NEUTRAL_NAMES    Allow the return of a neutral locale name.
    Return value:
        If the function succeeds, the return value is a string.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    A_LastError:
        If the function fails, it is set to one of the following error codes.
        0x0000007A  ERROR_INSUFFICIENT_BUFFER    A supplied buffer size was not large enough, or it was incorrectly set to zero.
        0x00000057  ERROR_INVALID_PARAMETER      Any of the parameter values was invalid.
    Note:
        For custom locales, including those created by Microsoft, your applications should prefer locale names over locale identifiers.
*/
LangGetLocaleName(LocaleID, Flags := 0)
{
    local Buffer := BufferAlloc(2*85)  ; LOCALE_NAME_MAX_LENGTH.
    return DllCall("Kernel32.dll\LCIDToLocaleName", "UInt", LocaleID, "Ptr", Buffer, "Int", Buffer.Size//2, "UInt", Flags)
         ? StrGet(Buffer)  ; Ok.
         : 0               ; Error.
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winnls/nf-winnls-lcidtolocalename





/*
    Converts a locale name to a locale identifier.
    Parameters:
        LocaleName:
            A string representing a locale name, or one of the following predefined values.
            0                        LOCALE_NAME_USER_DEFAULT      Name of the current user locale, matching the preference set in the regional and language options portion of Control Panel. This locale can be different from the locale for the current user interface language.
            ""                       LOCALE_NAME_INVARIANT         Name of an invariant locale that provides stable locale and calendar data.
            "!x-sys-default-locale"  LOCALE_NAME_SYSTEM_DEFAULT    Name of the current operating system locale.
        Flags:
            0x08000000  LOCALE_ALLOW_NEUTRAL_NAMES    Allow the return of a neutral locale identifier.
    Return value:
        If the function succeeds, the return value is the locale identifier corresponding to the locale name.
        If the locale provided is a transient locale or a CLDR (Unicode Common Locale Data Repository) locale, then the return value is 0x1000.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    A_LastError:
        If the function fails, it is set to one of the following error codes.
        0x00000057  ERROR_INVALID_PARAMETER      Any of the parameter values was invalid.
    Note:
        For custom locales, including those created by Microsoft, your applications should prefer locale names over locale identifiers.
*/
LangGetLocaleID(LocaleName, Flags := 0)
{
    return DllCall("Kernel32.dll\LocaleNameToLCID", "Ptr", Type(LocaleName)=="String"?&LocaleName:LocaleName, "UInt", Flags, "UInt")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winnls/nf-winnls-localenametolcid





/*
    Creates a language identifier from a primary language identifier and a sublanguage identifier.
    Parameters:
        Primary:
            Primary language identifier.
            This identifier can be a predefined value or a value for a user-defined primary language.
            For a user-defined language, the identifier is a value in the range 0x0200 to 0x03FF.
            All other values are reserved for operating system use.
        Sublanguage:
            Sublanguage identifier.
            This parameter can be a predefined sublanguage identifier or a user-defined sublanguage.
            For a user-defined sublanguage, the identifier is a value in the range 0x20 to 0x3F.
            All other values are reserved for operating system use.
    Return value:
        Returns an integer number that represents the language identifier.
    Language Identifier Constants and Strings:
        https://docs.microsoft.com/es-es/windows/desktop/Intl/language-identifier-constants-and-strings#language-identifier-notes
*/
MAKELANGID(Primary, Sublanguage)
{
    return (Sublanguage << 10) | Primary
} ; https://docs.microsoft.com/es-es/windows/desktop/api/winnt/nf-winnt-makelangid
