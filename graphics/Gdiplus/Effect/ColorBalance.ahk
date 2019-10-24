/*
    The ColorBalance object enables you to change the color balance (relative amounts of red, green, and blue) of a bitmap.

    1. To specify the nature of the change, pass a Gdiplus::ColorBalanceParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the ColorBalance object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorBalance Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-colorbalance
*/
class ColorBalance extends Gdiplus.Effect
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
    Creates a ColorBalance object.
    Return value:
        If the method succeeds, the return value is a ColorBalance object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static ColorBalance()
{
    return Gdiplus.Effect.ColorBalance.New(Gdiplus.Effect(Gdiplus.Effect.ColorBalanceEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-colorbalance-colorbalance
