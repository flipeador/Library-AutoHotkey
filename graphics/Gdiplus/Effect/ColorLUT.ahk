/*
    A ColorLUTParams object has four members, each being a lookup table for a particular color channel: alpha, red, green, or blue.
    The lookup tables can be used to make custom color adjustments to bitmaps. Each lookup table is an array of 256 bytes that you can set to values of your choice.

    1. After you have initialized a Gdiplus::ColorLUTParams object, pass it to the Gdiplus::Effect::SetParameters method.
    2. Pass the ColorLUT object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorLUT Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-colorlut
*/
class ColorLUT extends Gdiplus.Effect
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
    Creates a ColorLUT object.
    Return value:
        If the method succeeds, the return value is a ColorLUT object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static ColorLUT()
{
    return Gdiplus.Effect.ColorLUT.New(Gdiplus.Effect(Gdiplus.Effect.ColorLUTEffectGuid))
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-colorlut-colorlut
