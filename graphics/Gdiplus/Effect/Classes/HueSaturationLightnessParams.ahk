/*
    The HueSaturationLightnessParams object contains members that specify hue, saturation and lightness adjustments to a bitmap.

    You can adjust the hue, saturation, and lightness of a bitmap by following these steps.
    1. Create and initialize a Gdiplus::HueSaturationLightnessParams object.
    2. Pass the HueSaturationLightnessParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the HueSaturationLightness object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    HueSaturationLightnessParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams
*/
class HueSaturationLightnessParams
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Size := 12  ; Size, in bytes, of this structure.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer := 0
    Ptr    := 0
    Size   := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(HueLevel, SaturationLevel, LightnessLevel)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.HueSaturationLightnessParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.HueLevel        := HueLevel
        this.SaturationLevel := SaturationLevel
        this.LightnessLevel  := LightnessLevel
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the change in hue.
    */
    HueLevel[]
    {
        get => NumGet(this, "Int")
        set => NumPut("Int", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams

    /*
        Gets or sets the change in saturation.
    */
    SaturationLevel[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams

    /*
        Gets or sets the change in lightness.
    */
    LightnessLevel[]
    {
        get => NumGet(this, 8, "Int")
        set => NumPut("Int", Value, this, 8)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a HueSaturationLightnessParams object.
    Parameters:
        HueLevel:
            Integer in the range -180 through 180 that specifies the change in hue.
            A value of 0 specifies no change.
            Positive values specify counterclockwise rotation on the color wheel.
            Negative values specify clockwise rotation on the color wheel.
        SaturationLevel:
            Integer in the range -100 through 100 that specifies the change in saturation.
            A value of 0 specifies no change.
            Positive values specify increased saturation.
            Negative values specify decreased saturation.
        LightnessLevel:
            Integer in the range -100 through 100 that specifies the change in lightness.
            A value of 0 specifies no change.
            Positive values specify increased lightness.
            Negative values specify decreased lightness.
    Return value:
        The return value is a HueSaturationLightnessParams object.
*/
static HueSaturationLightnessParams(HueLevel := 0, SaturationLevel := 0, LightnessLevel := 0)
{
    return Gdiplus.HueSaturationLightnessParams.New(HueLevel, SaturationLevel, LightnessLevel)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams
