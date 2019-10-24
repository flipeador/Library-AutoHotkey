class Font extends GdiBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr)
    {
        this.Ptr := Ptr
    }

    static New(Ptr)
    {
        return Ptr ? base.New(Ptr) : 0
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdi)                                                                                                  #
; #######################################################################################################################
/*
    Creates a Font object with the specified characteristics.
    The logical font can subsequently be selected as the font for any device.
    Parameters:
        Options:
            A string with the font size and style.
            Available options: sN (size), wiN (width), wN (weight), qN (quality), cN (charSet), Bold (w700), Italic, Underline, Strike.
        FontName:
            The typeface name of the font. The length of this string must not exceed 31 characters.
            If this parameter is an empty string, the first font that matches the other specified attributes is used.
            This parameter can be a pointer to a null-terminated string.
    Return value:
        If the method succeeds, the return value is a Font object.
        If the method fails, the return value is zero.
*/
static Font(Options, FontName)
{
    local hDC        := DllCall("Gdi32.dll\CreateDCW", "Str", "DISPLAY", "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
    local LOGPIXELSY := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 90)  ; Number of pixels per logical inch along the screen height.

    local t, Size := RegExMatch(Options,"i)s([\d]+)",t) ? t[1] : 10  ; 10 = Default size.
    local hFont := DllCall("Gdi32.dll\CreateFontW",  "Int", -Round((Abs(Size)*LOGPIXELSY)/72)                                          ; int     cHeight.
                                                  ,  "Int", RegExMatch(Options,"i)wi([\-\d]+)",t) ? t[1] : 0                           ; int     cWidth.
                                                  ,  "Int", 0                                                                          ; int     cEscapement.
                                                  ,  "Int", !DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC)                                 ; int     cOrientation.
                                                  ,  "Int", RegExMatch(Options,"i)w([\-\d]+)",t) ? t[1] : (Options~="i)Bold"?700:400)  ; int     cWeight.
                                                  , "UInt", Options ~= "i)Italic"    ? TRUE : FALSE                                    ; DWORD   bItalic.
                                                  , "UInt", Options ~= "i)Underline" ? TRUE : FALSE                                    ; DWORD   bUnderline.
                                                  , "UInt", Options ~= "i)Strike"    ? TRUE : FALSE                                    ; DWORD   bStrikeOut.
                                                  , "UInt", RegExMatch(Options,"i)c([\d]+)",t) ? t[1] : 1                              ; DWORD   iCharSet.
                                                  , "UInt", 4                                                                          ; DWORD   iOutPrecision.
                                                  , "UInt", 0                                                                          ; DWORD   iClipPrecision.
                                                  , "UInt", RegExMatch(Options,"i)q([0-5])",t) ? t[1] : 5                              ; DWORD   iQuality.
                                                  , "UInt", 0                                                                          ; DWORD   iPitchAndFamily.
                                                  , "UPtr", Type(FontName) == "String" ? &FontName : FontName                          ; LPCWSTR pszFaceName.
                                                  , "UPtr")                                                                            ; ReturnType.

    return Gdi.Font.New(hFont)
} ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createfontw
