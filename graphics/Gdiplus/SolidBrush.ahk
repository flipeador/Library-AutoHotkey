/*
    The SolidBrush class defines a solid color Brush object.
    A Brush object is used to fill in shapes similar to the way a paint brush can paint the inside of a shape.

    SolidBrush Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nl-gdiplusbrush-solidbrush

    SolidBrush Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-solidbrush-flat
*/
class SolidBrush extends Gdiplus.Brush
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
        Gets or sets the ARGB color of this SolidBrush object.
    */
    Color[]
    {
        get {
            local Color := 0
            DllCall("Gdiplus.dll\GdipGetSolidFillColor", "Ptr", this, "UIntP", Color)
            return Color
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-solidbrush-getcolor
        set => DllCall("Gdiplus.dll\GdipSetSolidFillColor", "Ptr", this, "UInt", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-solidbrush-setcolor
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a SolidBrush object based on a color.
    Parameters:
        Color:
            Specifies the ARGB color for this SolidBrush object. The default color is 100% black.
    Return value:
        If the method succeeds, the return value is a SolidBrush object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static SolidBrush(Color := 0xFF000000)
{
    local pBrush := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", Color, "UPtrP", pBrush)
    return Gdiplus.SolidBrush.New(pBrush)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-solidbrush-solidbrush(constsolidbrush_)
