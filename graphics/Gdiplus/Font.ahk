/*
    The Font class encapsulates the characteristics, such as family, height, size, and style (or combination of styles), of a specific font.
    A Font object is used when drawing strings.

    Font Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-font

    Font Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-font-flat
*/
class Font extends GdiplusBase
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
            DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-font-flat


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Creates a Font object based on the GDI font object that is currently selected into a specified device context.
        Parameters:
            hDC:
                A handle to a Windows device context that has a font selected.
        Return value:
            If the method succeeds, the return value is a Font object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromDC(hDC)
    {
        local pFont := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateFontFromDC", "Ptr", hDC, "UPtrP", pFont)
        return Gdiplus.Font.New(pFont)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-font(inhdc)

    /*
        Creates a Font object directly from a GDI logical font.
        The GDI logical font is a LOGFONTW structure, which is the wide character version of a logical font.
        Parameters:
            hDC:
                A handle to a Windows device context that has a font selected.
            LogFont:
                A LOGFONTW structure that contains attributes of the font.
                The LOGFONTW structure is the wide character version of the logical font.
        Return value:
            If the method succeeds, the return value is a Font object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromLogFont(hDC, LogFont)
    {
        local pFont := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateFontFromLogfontW", "Ptr", hDC, "Ptr", LogFont, "UPtrP", pFont)
        return Gdiplus.Font.New(pFont)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-font(inhdc_inconstlogfontw)


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Creates a new Font object based on this Font object.
        Return value:
            If the method succeeds, the return value is a Font object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pFont := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneFont", "Ptr", this, "UPtrP", pFont)
        return Gdiplus.Font.New(pFont)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-clone

    /*
        Gets the line spacing of this font in the current unit of a specified Graphics object.
        Parameters:
            GraphicsOrDPI:
                A Graphics object whose unit and vertical resolution are used in the height calculation.
        ----------------------------------------------------------------------------------------------------------------
        Gets the line spacing, in pixels, of this font.
        Parameters:
            GraphicsOrDPI:
                Real number that specifies the vertical resolution, in dots per inch, of the device that displays the font.
        ----------------------------------------------------------------------------------------------------------------
        The line spacing is the vertical distance between the base lines of two consecutive lines of text.
        Thus, the line spacing includes the blank space between lines along with the height of the character itself.
    */
    GetHeight(GraphicsOrDPI)
    {
        local Height := 0
        Gdiplus.LastStatus := IsObject(GraphicsOrDPI)
                            ? DllCall("Gdiplus.dll\GdipGetFontHeight", "Ptr", this, "Ptr", GraphicsOrDPI, "FloatP", Height)
                            : DllCall("Gdiplus.dll\GdipGetFontHeightGivenDPI", "Ptr", this, "Float", GraphicsOrDPI, "FloatP", Height)
        return Height
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536201(v=vs.85) | https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-getheight(inreal)

    /*
        Uses a LOGFONTW structure to get the attributes of this Font object.
        Parameters:
            Graphics:
                A Graphics object that contains attributes of the video display.
            LogFont:
                A LOGFONTW structure that receives the font attributes.
                If this parameter is omitted, space is automatically allocated for the LOGFONTW structure.
        Return value:
            If the method succeeds, the return value is «LogFont» or a Buffer object (LOGFONTW structure).
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetLogFont(Graphics, LogFont := 0)
    {
        LogFont := LogFont || BufferAlloc(92)  ; 92 = sizeof(LOGFONTW).
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetLogFontW", "Ptr", this, "Ptr", Graphics, "Ptr", LogFont))
              ? 0        ; Error.
              : LogFont  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-getlogfontw


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the font size (commonly called the em size) of this Font object.
        The size is in the units of this Font object.
    */
    Size[]
    {
        get {
            local Size := 0
            DllCall("Gdiplus.dll\GdipGetFontSize", "Ptr", this, "FloatP", Size)
            return Size
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-getsize
    }

    /*
        Gets the style of this font's typeface.
    */
    Style[]
    {
        get {
            local Style := 0
            DllCall("Gdiplus.dll\GdipGetFontStyle", "Ptr", this, "IntP", Style)
            return Style
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-getstyle
    }

    /*
        Gets the unit of measure of this Font object.
    */
    Unit[]
    {
        get {
            local Unit := 0
            DllCall("Gdiplus.dll\GdipGetFontUnit", "Ptr", this, "IntP", Unit)
            return Unit
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-getunit
    }

    /*
        Gets the FontFamily object on which this font is based.
    */
    Family[]
    {
        get {
            local pFontFamily := 0
            DllCall("Gdiplus.dll\GdipGetFamily", "Ptr", this, "UPtrP", pFontFamily)
            return Gdiplus.FontFamily.New(pFontFamily)
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-getfamily
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a Font object based on a font family, a size, a font style, a unit of measurement, and a FontCollection object.
    Parameters:
        FontFamily:
            Specifies the font family.
            This parameter can be a string with the name of the font family or a FontFamily object.
        Size:
            Real number that specifies the em size of the font measured in the units specified in the «Unit» parameter.
        Style:
            Integer that specifies the style of the typeface.
            This parameter must be a value or a combination of values of the FontStyle Enumeration.
        Unit:
            Specifies the unit of measurement for the font size.
            This parameter must be a value of the Unit Enumeration. The default value is UnitPoint.
        FontCollection:
            A FontCollection object that specifies the collection that the font family belongs to.
            If this parameter is zero, this font family is not part of a collection.
            This parameter is ignored if the «FontFamily» parameter specifies a FontFamily object.
    Return value:
        If the method succeeds, the return value is a Font object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    Remarks:
        If the Size parameter is a string, the Font2 method is called as follows: Font2(FontFamily,Size,Style).
*/
static Font(FontFamily, Size, Style := 0, Unit := 3, FontCollection := 0)
{
    if !(Size is "Number")
        return Gdiplus.Font2(FontFamily, Size, Style)
    local pFont := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateFont", "Ptr", IsObject(FontFamily)?FontFamily:Gdiplus.FontFamily(FontFamily,FontCollection)
        , "Float", Size, "Int", Style, "Int", Unit, "UPtrP", pFont)
    return Gdiplus.Font.New(pFont)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-font-font(inconstwchar_inreal_inint_inunit_inconstfontcollection)

/*
    Similar to the Font method. This method is used if the Size parameter of the Font method is a string.
    Parameters:
        Options:
            Zero or more options. Each option is either a single letter immediately followed by a value, or a single word.
            sN           The em size of the font measured in the specified units.
            uN           The unit of measurement for the font size. The default value is UnitPoint.
            Bold         Specifies bold typeface. Bold is a heavier weight or thickness.
            Italic       Specifies italic typeface, which produces a noticeable slant to the vertical stems of the characters.
            Underline    Specifies underline, which displays a line underneath the baseline of the characters.
            Strike       Specifies strikeout, which displays a horizontal line drawn through the middle of the characters.
        FontFamily:
            Specifies the font family.
            This parameter can be a string with the name of the font family or a FontFamily object.
        FontCollection:
            A FontCollection object that specifies the collection that the font family belongs to.
            If this parameter is zero, this font family is not part of a collection.
            This parameter is ignored if the «FontFamily» parameter specifies a FontFamily object.
    Return value:
        If the method succeeds, the return value is a Font object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    Remarks:
        Use the Font method instead.
*/
static Font2(Options, FontFamily, FontCollection := 0)
{
    local t
    local Size  := RegExMatch(Options,"i)\bs([\d\.]+\b)",t) ? t[1] : 10  ; 10 = Default size.
    local Unit  := RegExMatch(Options,"i)\bu([\d]+)\b"  ,t) ? t[1] : 3   ;  3 = UnitPoint.
    local Style := (Options~="i)\bBold\b"?1:0)      | (Options~="i)\bItalic\b"?2:0)
                 | (Options~="i)\bUnderline\b"?4:0) | (Options~="i)\bStrike\b"?5:0)
    return Gdiplus.Font(FontFamily, Size, Style, Unit, FontCollection)
}
