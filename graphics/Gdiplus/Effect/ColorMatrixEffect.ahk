/*
    The ColorMatrixEffect object enables you to apply an affine transformation to a bitmap.

    1. To specify the transformation, pass a Gdiplus::ColorMatrix object to the Gdiplus::Effect::SetParameters method.
    2. Pass the ColorMatrixEffect object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorMatrixEffect Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-colormatrixeffect

    ColorMatrix Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ns-gdipluscolormatrix-colormatrix
*/
class ColorMatrixEffect extends Gdiplus.Effect
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
    Creates a ColorMatrixEffect object.
    Return value:
        If the method succeeds, the return value is a ColorMatrixEffect object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static ColorMatrixEffect()
{
    return Gdiplus.Effect.ColorMatrixEffect.New(Gdiplus.Effect(Gdiplus.Effect.ColorMatrixEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-colormatrixeffect-colormatrixeffect
