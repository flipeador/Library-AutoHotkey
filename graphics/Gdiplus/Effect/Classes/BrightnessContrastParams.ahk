/*
    A BrightnessContrastParams object contains members that specify the nature of a brightness or contrast adjustment.

    You can change the brightness or contrast (or both) of a bitmap by following these steps.
    1. Create and initialize a Gdiplus::BrightnessContrastParams object.
    2. Pass the BrightnessContrastParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the BrightnessContrast object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    BrightnessContrastParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams
*/
class BrightnessContrastParams
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Size := 8  ; Size, in bytes, of this structure.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer := 0
    Ptr    := 0
    Size   := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(BrightnessLevel, ContrastLevel)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.BrightnessContrastParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.BrightnessLevel := BrightnessLevel
        this.ContrastLevel   := ContrastLevel
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the brightness level.
    */
    BrightnessLevel[]
    {
        get => NumGet(this, "Int")
        set => NumPut("Int", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams

    /*
        Gets or sets the contrast level.
    */
    ContrastLevel[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a BrightnessContrastParams object.
    Parameters:
        BrightnessLevel:
            Integer in the range -255 through 255 that specifies the brightness level.
            If the value is 0, the brightness remains the same.
            As the value moves from 0 to 255, the brightness of the image increases.
            As the value moves from 0 to -255, the brightness of the image decreases.
        ContrastLevel:
            Integer in the range -100 through 100 that specifies the contrast level.
            If the value is 0, the contrast remains the same.
            As the value moves from 0 to 100, the contrast of the image increases.
            As the value moves from 0 to -100, the contrast of the image decreases.
    Return value:
        The return value is a BrightnessContrastParams object.
*/
static BrightnessContrastParams(BrightnessLevel := 0, ContrastLevel := 0)
{
    return Gdiplus.BrightnessContrastParams.New(BrightnessLevel, ContrastLevel)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-brightnesscontrastparams
