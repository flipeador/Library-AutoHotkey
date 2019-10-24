/*
    The Sharpen object enables you to adjust the sharpness of a bitmap.

    1. To specify the nature of the sharpening adjustment, pass a Gdiplus::SharpenParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the Sharpen object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    Sharpen Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-sharpen

    SharpenParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams
*/
class Sharpen extends Gdiplus.Effect
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
    Creates a Sharpen object.
    Return value:
        If the method succeeds, the return value is a Sharpen object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Sharpen()
{
    return Gdiplus.Effect.Sharpen.New(Gdiplus.Effect(Gdiplus.Effect.SharpenEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-sharpen-sharpen
