/*
    The HueSaturationLightness object enables you to change the hue, saturation, and lightness of a bitmap.

    1. To specify the magnitudes of the changes in hue, saturation, and lightness, pass a Gdiplus::HueSaturationLightnessParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the HueSaturationLightness object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    HueSaturationLightness Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-huesaturationlightness
*/
class HueSaturationLightness extends Gdiplus.Effect
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
    Creates a HueSaturationLightness object.
    Return value:
        If the method succeeds, the return value is a HueSaturationLightness object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static HueSaturationLightness()
{
    return Gdiplus.Effect.HueSaturationLightness.New(Gdiplus.Effect(Gdiplus.Effect.HueSaturationLightnessEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-huesaturationlightness-huesaturationlightness
