/*
    This HatchBrush class defines a rectangular brush with a hatch style, a foreground color, and a background color.
    The foreground color defines the color of the hatch lines; the background color defines the color over which the hatch lines are drawn.

    HatchBrush Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nl-gdiplusbrush-hatchbrush

    HatchBrush Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-hatchbrush-flat
*/
class HatchBrush extends Gdiplus.Brush
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the hatch style of this hatch brush.
    */
    Style[]
    {
        get {
            local Style := 0
            DllCall("Gdiplus.dll\GdipGetHatchStyle", "Ptr", this, "IntP", Style)
            return Style
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-hatchbrush-gethatchstyle
    }

    /*
        Gets the ARGB foreground color of this hatch brush.
    */
    ForeColor[]
    {
        get {
            local ForeColor := 0
            DllCall("Gdiplus.dll\GdipGetHatchForegroundColor", "Ptr", this, "UIntP", ForeColor)
            return ForeColor
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-hatchbrush-getforegroundcolor
    }

    /*
        Gets the ARGB background color of this hatch brush.
    */
    BackColor[]
    {
        get {
            local BackColor := 0
            DllCall("Gdiplus.dll\GdipGetHatchBackgroundColor", "Ptr", this, "UIntP", BackColor)
            return BackColor
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-hatchbrush-getbackgroundcolor
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a HatchBrush object based on a hatch style, a foreground color, and a background color.
    Parameters:
        HatchStyle:
            Specifies the hatch pattern used by the hatch brush.
            The hatch pattern consists of a solid background color and lines drawn over the background.
            This parameter must be a value from the HatchStyle Enumeration.
        ForeColor:
            Specifies the ARGB foreground color for this HatchBrush object. The default color is 100% black.
        BackColor:
            Specifies the ARGB background color for this HatchBrush object. The default color is 100% transparent.
    Return value:
        If the method succeeds, the return value is a HatchBrush object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static HatchBrush(HatchStyle, ForeColor := 0xFF000000, BackColor := 0x00000000)
{
    local pHatchBrush := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateHatchBrush", "Int", HatchStyle, "UInt", ForeColor, "UInt", BackColor, "UPtrP", pHatchBrush)
    return Gdiplus.HatchBrush.New(pHatchBrush)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-hatchbrush-hatchbrush(inhatchstyle_inconstcolor__inconstcolor_)
