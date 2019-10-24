/*
    The Tint object enables you to apply a tint to a bitmap.

    1. To specify the nature of the tint, pass a Gdiplus::TintParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the Tint object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    Tint Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-tint
*/
class Tint extends Gdiplus.Effect
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
    Creates a Tint object.
    Return value:
        If the method succeeds, the return value is a Tint object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Tint()
{
    return Gdiplus.Effect.Tint.New(Gdiplus.Effect(Gdiplus.Effect.TintEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-tint-tint
