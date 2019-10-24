/*
    A ColorCurveParams object contains members that specify an adjustment to the colors of a bitmap.
    The ColorCurve class encompasses eight separate adjustments: exposure, density, contrast, highlight, shadow, midtone, white saturation, and black saturation.

    You can apply one of those adjustments to a bitmap by following these steps.
    1. Create and initialize a Gdiplus::ColorCurveParams object.
    2. Pass the ColorCurveParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the ColorCurve object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorCurveParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorcurveparams

    CurveAdjustments Enumeration:
        The ColorCurve class encompasses the eight bitmap adjustments listed in the CurveAdjustments enumeration.
        0  AdjustExposure           Simulates increasing or decreasing the exposure of a photograph. When you set the adjustment member of a ColorCurveParams object to AdjustExposure, you should set the adjustValue member to an integer in the range -255 through 255. A value of 0 specifies no change in exposure. Positive values specify increased exposure and negative values specify decreased exposure.
        1  AdjustDensity            Simulates increasing or decreasing the film density of a photograph. When you set the adjustment member of a ColorCurveParams object to AdjustDensity, you should set the adjustValue member to an integer in the range -255 through 255. A value of 0 specifies no change in density. Positive values specify increased density (lighter picture) and negative values specify decreased density (darker picture).
        2  AdjustContrast           Increases or decreases the contrast of a bitmap. When you set the adjustment member of a ColorCurveParams object to AdjustContrast, you should set the adjustValue member to an integer in the range -100 through 100. A value of 0 specifies no change in contrast. Positive values specify increased contrast and negative values specify decreased contrast.
        3  AdjustHighlight          Increases or decreases the value of a color channel if that channel already has a value that is above half intensity. You can use this adjustment to get more definition in the light areas of an image without affecting the dark areas. When you set the adjustment member of a ColorCurveParams object to AdjustHighlight, you should set the adjustValue member to an integer in the range -100 through 100. A value of 0 specifies no change. Positive values specify that the light areas are made lighter, and negative values specify that the light areas are made darker.
        4  AdjustShadow             Increases or decreases the value of a color channel if that channel already has a value that is below half intensity. You can use this adjustment to get more definition in the dark areas of an image without affecting the light areas. When you set the adjustment member of a ColorCurveParams object to AdjustShadow, you should set the adjustValue member to an integer in the range -100 through 100. A value of 0 specifies no change. Positive values specify that the dark areas are made lighter, and negative values specify that the dark areas are made darker.
        5  AdjustMidtone            Lightens or darkens an image. Color channel values in the middle of the intensity range are altered more than color channel values near the minimum or maximum intensity. You can use this adjustment to lighten (or darken) an image without loosing the contrast between the darkest and lightest portions of the image. When you set the adjustment member of a ColorCurveParams object to AdjustMidtone, you should set the adjustValue member to an integer in the range -100 through 100. A value of 0 specifies no change. Positive values specify that the midtones are made lighter, and negative values specify that the midtones are made darker.
        6  AdjustWhiteSaturation    When you set the adjustment member of a ColorCurveParams object to AdjustWhiteSaturation, you should set the adjustValue member to an integer in the range 0 through 255. A value of t specifies that the interval [0, t] is mapped linearly to the interval [0, 255]. For example, if adjustValue is equal to 240, then color channel values in the interval [0, 240] are adjusted so that they spread out over the interval [0, 255]. Color channel values greater than 240 are set to 255.
        7  AdjustBlackSaturation    When you set the adjustment member of a ColorCurveParams object to AdjustBlackSaturation, you should set the adjustValue member to an integer in the range 0 through 255. A value of t specifies that the interval [t, 255] is mapped linearly to the interval [0, 255]. For example, if adjustValue is equal to 15, then color channel values in the interval [15, 255] are adjusted so that they spread out over the interval [0, 255]. Color channel values less than 15 are set to 0.
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curveadjustments

    CurveChannel Enumeration:
        Specifies which color channels are affected by a ColorCurve bitmap adjustment.
        1  CurveChannelAll      Specifies that the color adjustment applies to all channels.
        2  CurveChannelRed      Specifies that the color adjustment applies only to the red channel.
        3  CurveChannelGreen    Specifies that the color adjustment applies only to the green channel.
        4  CurveChannelBlue     Specifies that the color adjustment applies only to the blue channel.
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel
*/
class ColorCurveParams
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
    __New(Adjustment, Channel, AdjustValue)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.ColorCurveParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.Adjustment  := Adjustment
        this.Channel     := Channel
        this.AdjustValue := AdjustValue
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the adjustment to be applied.
    */
    Adjustment[]
    {
        get => NumGet(this, "Int")
        set => NumPut("Int", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel

    /*
        Gets or sets the color channel to which the adjustment applies.
    */
    Channel[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel

    /*
        Gets or sets the intensity of the adjustment.
    */
    AdjustValue[]
    {
        get => NumGet(this, 8, "Int")
        set => NumPut("Int", Value, this, 8)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a ColorCurveParams object.
    Parameters:
        Adjustment:
            Element of the CurveAdjustments Enumeration that specifies the adjustment to be applied.
        Channel:
            Element of the CurveChannel Enumeration that specifies the color channel to which the adjustment applies.
        AdjustValue:
            Integer that specifies the intensity of the adjustment.
            The range of acceptable values depends on which adjustment is being applied.
            To see the range of acceptable values for a particular adjustment, see the CurveAdjustments Enumeration.
    Return value:
        The return value is a ColorCurveParams object.
*/
static ColorCurveParams(Adjustment := 0, Channel := 0, AdjustValue := 0)
{
    return Gdiplus.ColorCurveParams.New(Adjustment, Channel, AdjustValue)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ne-gdipluseffects-curvechannel
