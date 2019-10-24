/*
    The StringFormat class encapsulates text layout information (such as alignment, orientation, tab stops, and clipping)
    - and display manipulations (such as trimming, font substitution for characters that are not supported by the requested font,
    - and digit substitution for languages that do not use Western European digits).

    StringFormat Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nl-gdiplusstringformat-stringformat
*/
class StringFormat extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


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
            DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-stringformat-flat


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Creates a new StringFormat object from this StringFormat object.
        Return value:
            If the method succeeds, the return value is a new StringFormat object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pStringFormat := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneStringFormat", "Ptr", this, "UPtrP", pStringFormat)
        return Gdiplus.StringFormat.New(pStringFormat)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-stringformat(conststringformat_)

    /*
        Sets a series of character ranges for this StringFormat object that, when in a string, can be measured by the Graphics::MeasureCharacterRanges method.
        Parameters:
            CharacterRange:
                An array of CharacterRange objects that specify the character ranges to be measured.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetMeasurableCharacterRanges(CharacterRange)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\SetMeasurableCharacterRanges", "Ptr", this, "Int", CharacterRange.Count, "Ptr", CharacterRange))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-setmeasurablecharacterranges


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the string format flags for this StringFormat object.
        The format flags determine most of the characteristics of a StringFormat object.
    */
    FormatFlags[]
    {
        get {
            local Flags := 0
            DllCall("Gdiplus.dll\GdipGetStringFormatFlags", "Ptr", this, "IntP", Flags)
            return Flags
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-getformatflags
        set => DllCall("Gdiplus.dll\GdipSetStringFormatFlags", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-setformatflags
    }

    /*
        Gets or sets the character alignment of this StringFormat object in relation to the origin of the layout rectangle.
        A layout rectangle is used to position the displayed string.
        This value is an element of the StringAlignment Enumeration.
    */
    Alignment[]
    {
        get {
            local Alignment := 0
            DllCall("Gdiplus.dll\GdipGetStringFormatAlign", "Ptr", this, "IntP", Alignment)
            return Alignment
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-getalignment
        set => DllCall("Gdiplus.dll\GdipSetStringFormatAlign", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-setalignment
    }

    /*
        Gets or sets the line alignment of this StringFormat object in relation to the origin of the layout rectangle.
        The line alignment setting specifies how to align the string vertically in the layout rectangle.
        The layout rectangle is used to position the displayed string.
        This value is an element of the StringAlignment Enumeration.
    */
    LineAlignment[]
    {
        get {
            local Alignment := 0
            DllCall("Gdiplus.dll\GdipGetStringFormatLineAlign", "Ptr", this, "IntP", Alignment)
            return Alignment
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-getlinealignment
        set => DllCall("Gdiplus.dll\GdipSetStringFormatLineAlign", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-setlinealignment
    }

    /*
        Gets or sets the trimming style for this StringFormat object.
        The trimming style determines how to trim a string so that it fits into the layout rectangle.
        This value is an element of the StringTrimming Enumeration.
    */
    Trimming[]
    {
        get {
            local Trimming := 0
            DllCall("Gdiplus.dll\GdipGetStringFormatTrimming", "Ptr", this, "IntP", Trimming)
            return Trimming
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-gettrimming
        set => DllCall("Gdiplus.dll\GdipSetStringFormatTrimming", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-settrimming
    }

    /*
        Gets the number of measurable character ranges that are currently set.
        The character ranges that are set can be measured in a string by using the Graphics::MeasureCharacterRanges method.
    */
    MeasurableCharacterRangeCount[]
    {
        get {
            local MeasurableCharacterRangeCount := 0
            DllCall("Gdiplus.dll\GdipGetStringFormatMeasurableCharacterRangeCount", "Ptr", this, "IntP", MeasurableCharacterRangeCount)
            return MeasurableCharacterRangeCount
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-getmeasurablecharacterrangecount
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a StringFormat object based on string format flags and a language.
    Parameters:
        FormatFlags:
            Value that specifies the format flags that control most of the characteristics of the StringFormat object.
            The flags are set by applying a bitwise OR to elements of the StringFormatFlags Enumeration.
        Language:
            Sixteen-bit value that specifies the language to use.
            The default value is LANG_NEUTRAL, which is the user's default language.
    Return value:
        If the method succeeds, the return value is a StringFormat object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static StringFormat(FormatFlags := 0, Language := 0x0000)
{
    local pStringFormat := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateStringFormat", "Int", FormatFlags, "UShort", Language, "UPtrP", pStringFormat)
    return Gdiplus.StringFormat.New(pStringFormat)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-stringformat(inint_inlangid)
