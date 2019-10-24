/*
    The Blur object enables you to apply a Gaussian blur effect to a bitmap and specify the nature of the blur.

    1. To specify the nature of the blur, pass a Gdiplus::BlurParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the Blur object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    Blur Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-blur
*/
class Blur extends Gdiplus.Effect
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
    Creates a Blur object.
    Return value:
        If the method succeeds, the return value is a Blur object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Blur()
{
    return Gdiplus.Effect.Blur.New(Gdiplus.Effect(Gdiplus.Effect.BlurEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-blur-blur
