/*
    The FontFamily class encapsulates a set of fonts that make up a font family.
    A font family is a group of fonts that have the same typeface but different styles.

    FontFamily Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-fontfamily

    FontFamily Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-fontfamily-flat
*/
class FontFamily extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr  := 0  ; Pointer to the object.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Ptr)
            DllCall("Gdiplus.dll\GdipDeleteFontFamily", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-fontfamily-flat


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Gets a FontFamily object that represents a generic serif typeface.
        Return value:
            If the method succeeds, the return value is a FontFamily object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static GenericSerif()
    {
        local pFontFamily := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetGenericFontFamilySerif", "UPtrP", pFontFamily)
        return Gdiplus.FontFamily.New(pFontFamily)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-genericserif

    /*
        Gets a FontFamily object that specifies a generic sans serif typeface.
        Return value:
            If the method succeeds, the return value is a FontFamily object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static GenericSansSerif()
    {
        local pFontFamily := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetGenericFontFamilySansSerif", "UPtrP", pFontFamily)
        return Gdiplus.FontFamily.New(pFontFamily)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-genericsansserif

    /*
        Gets a FontFamily object that specifies a generic monospace typeface.
        Return value:
            If the method succeeds, the return value is a FontFamily object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static GenericMonospace()
    {
        local pFontFamily := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetGenericFontFamilyMonospace", "UPtrP", pFontFamily)
        return Gdiplus.FontFamily.New(pFontFamily)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-genericmonospace


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Creates a new FontFamily object based on this FontFamily object.
        Return value:
            If the method succeeds, the return value is a FontFamily object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pFontFamily := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneFontFamily", "Ptr", this, "UPtrP", pFontFamily)
        return Gdiplus.FontFamily.New(pFontFamily)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-clone

    /*
        Gets the name of this font family.
        Parameters:
            LangID:
                Sixteen-bit value that specifies the language to use.
                The default value is LANG_NEUTRAL, which is the user's default language.
        Return value:
            If the method succeeds, the return value is a string with the name of this font family.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetFamilyName(LangID := 0)
    {
        local Name := BufferAlloc(2*32)  ; LF_FACESIZE = 32.
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetFamilyName", "Ptr", this, "Ptr", Name, "UShort", LangID))
              ? 0             ; Error.
              : StrGet(Name)  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Gdiplusheaders/nf-gdiplusheaders-fontfamily-getfamilyname

    /*
        Determines whether the specified style is available for this font family.
        Parameters:
            Style:
                Integer that specifies the style of the typeface.
                This value must be an element of the FontStyle enumeration or the result of a bitwise OR applied to two or more of these elements.
        Return value:
            Returns TRUE if the style or combination of styles is available; otherwise, it returns FALSE.
    */
    IsStyleAvailable(Style)
    {
        local IsStyleAvailable := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipIsStyleAvailable", "Ptr", this, "Int", Style, "IntP", IsStyleAvailable)
        return IsStyleAvailable
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-isstyleavailable

    /*
        Gets the size (commonly called em size or em height), in design units, of this font family.
        Return value:
            Returns the size, in design units, of this font family.
    */
    GetEmHeight(Style)
    {
        local EmHeight := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetEmHeight", "Ptr", this, "Int", Style, "UShortP", EmHeight)
        return EmHeight
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-getemheight

    /*
        Gets the cell ascent, in design units, of this font family for the specified style or style combination.
        Return value:
            Returns the cell ascent, in design units, of this font family for the specified style or style combination.
    */
    GetCellAscent(Style)
    {
        local CellAscent := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetCellAscent", "Ptr", this, "Int", Style, "UShortP", CellAscent)
        return CellAscent
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-getcellascent

    /*
        Gets the cell descent, in design units, of this font family for the specified style or style combination.
        Return value:
            Returns the cell descent, in design units, of this font family for the specified style or style combination.
    */
    GetCellDescent(Style)
    {
        local CellDescent := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetCellDescent", "Ptr", this, "Int", Style, "UShortP", CellDescent)
        return CellDescent
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-getcelldescent

    /*
        Gets the line spacing, in design units, of this font family for the specified style or style combination.
        The line spacing is the vertical distance between the base lines of two consecutive lines of text.
        Return value:
            Returns the line spacing of this font family.
    */
    GetLineSpacing(Style)
    {
        local LineSpacing := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetLineSpacing", "Ptr", this, "Int", Style, "UShortP", LineSpacing)
        return LineSpacing
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-getlinespacing


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the name of this font family. Same as the GetFamilyName method.
    */
    Name[LangID := 0]
    {
        get {
            local Name := BufferAlloc(2*32, 0)  ; LF_FACESIZE = 32.
            DllCall("Gdiplus.dll\GdipGetFamilyName", "Ptr", this, "Ptr", Name, "UShort", LangID)
            return StrGet(Name)
        }
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a FontFamily object based on a specified font family.
    Parameters:
        FontName:
            A string with the name of the font family.
            For example, "Arial.ttf" is the name of the Arial font family.
        FontCollection:
            A FontCollection object that specifies the collection that the font family belongs to.
            If this parameter is zero, this font family is not part of a collection.
    Return value:
        If the method succeeds, the return value is a FontFamily object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static FontFamily(FontName, FontCollection := 0)
{
    local pFontFamily := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateFontFamilyFromName", "Ptr", &FontName, "Ptr", FontCollection, "UPtrP", pFontFamily)
    return Gdiplus.FontFamily.New(pFontFamily)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-fontfamily-fontfamily(inconstwchar_inconstfontcollection)
