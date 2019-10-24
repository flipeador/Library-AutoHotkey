/*
    The Levels object encompasses three bitmap adjustments: highlight, midtone, and shadow.

    1. To specify the intensities of the adjustments, pass a Gdiplus::LevelsParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the Levels object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    Levels Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-levels
*/
class Levels extends Gdiplus.Effect
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
    Creates a Levels object.
    Return value:
        If the method succeeds, the return value is a Levels object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Levels()
{
    return Gdiplus.Effect.Levels.New(Gdiplus.Effect(Gdiplus.Effect.LevelsEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-levels-levels
