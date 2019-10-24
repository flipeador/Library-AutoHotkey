/*
    The BrightnessContrast object enables you to change the brightness and contrast of a bitmap.

    1. To specify the brightness and contrast levels, pass a Gdiplus::BrightnessContrastParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the BrightnessContrast object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    BrightnessContrast Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-brightnesscontrast
*/
class BrightnessContrast extends Gdiplus.Effect
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
    Creates a BrightnessContrast object.
    Return value:
        If the method succeeds, the return value is a BrightnessContrast object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static BrightnessContrast()
{
    return Gdiplus.Effect.BrightnessContrast.New(Gdiplus.Effect(Gdiplus.Effect.BrightnessContrastEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-brightnesscontrast-brightnesscontrast
