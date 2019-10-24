/*
    The ColorCurve object encompasses eight separate adjustments: exposure, density, contrast, highlight, shadow, midtone, white saturation, and black saturation.

    1. To specify the adjustment, the intensity of the adjustment, and the color channel to which the adjustment applies, pass a Gdiplus::ColorCurveParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the ColorCurve object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorCurve Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-colorcurve
*/
class ColorCurve extends Gdiplus.Effect
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr  ; nativeEffect.
    static New(Ptr) => Ptr ? base.New(Ptr) : 0
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus::Effect)                                                                                      #
; #######################################################################################################################
/*
    Creates a ColorCurve object.
    Return value:
        If the method succeeds, the return value is a ColorCurve object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static ColorCurve()
{
    return Gdiplus.Effect.ColorCurve.New(Gdiplus.Effect(Gdiplus.Effect.ColorCurveEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-colorcurve-colorcurve
