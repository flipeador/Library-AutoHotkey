/*
    The RedEyeCorrection object enables you to correct the red eyes that sometimes occur in flash photographs.

    1. To specify areas of the bitmap that have red eyes, pass a Gdiplus::RedEyeCorrectionParams object to the Gdiplus::Effect::SetParameters method.
    2. Pass the RedEyeCorrection object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    RedEyeCorrection Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-redeyecorrection
*/
class RedEyeCorrection extends Gdiplus.Effect
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
    Creates a RedEyeCorrection object.
    Return value:
        If the method succeeds, the return value is a RedEyeCorrection object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static RedEyeCorrection()
{
    return Gdiplus.Effect.RedEyeCorrection.New(Gdiplus.Effect(Gdiplus.Effect.RedEyeCorrectionEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-redeyecorrection-redeyecorrection
