/*
    A ColorBalanceParams object contains members that specify the nature of a color balance adjustment.

    You can change the color balance of a bitmap by following these steps.
    1. Create and initialize a Gdiplus::ColorBalanceParams object.
    2. Pass the ColorBalanceParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the ColorBalance object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorBalanceParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams
*/
class ColorBalanceParams
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
    __New(CyanRed, MagentaGreen, YellowBlue)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.ColorBalanceParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.CyanRed      := CyanRed
        this.MagentaGreen := MagentaGreen
        this.YellowBlue   := YellowBlue
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the change in the amount of red in the image.
    */
    CyanRed[]
    {
        get => NumGet(this, "Int")
        set => NumPut("Int", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams

    /*
        Gets or sets the change in the amount of green in the image.
    */
    MagentaGreen[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams

    /*
        Gets or sets the change in the amount of blue in the image.
    */
    YellowBlue[]
    {
        get => NumGet(this, 8, "Int")
        set => NumPut("Int", Value, this, 8)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a ColorBalanceParams object.
    Parameters:
        CyanRed:
            Integer in the range -100 through 100 that specifies a change in the amount of red in the image.
            If the value is 0, there is no change.
            As the value moves from 0 to 100, the amount of red in the image increases and the amount of cyan decreases.
            As the value moves from 0 to -100, the amount of red in the image decreases and the amount of cyan increases.
        MagentaGreen:
            Integer in the range -100 through 100 that specifies a change in the amount of green in the image.
            If the value is 0, there is no change.
            As the value moves from 0 to 100, the amount of green in the image increases and the amount of magenta decreases.
            As the value moves from 0 to -100, the amount of green in the image decreases and the amount of magenta increases.
        YellowBlue:
            Integer in the range -100 through 100 that specifies a change in the amount of blue in the image.
            If the value is 0, there is no change. As the value moves from 0 to 100, the amount of blue in the image increases and the amount of yellow decreases.
            As the value moves from 0 to -100, the amount of blue in the image decreases and the amount of yellow increases.
    Return value:
        The return value is a ColorBalanceParams object.
*/
static ColorBalanceParams(CyanRed := 0, MagentaGreen := 0, YellowBlue := 0)
{
    return Gdiplus.ColorBalanceParams.New(CyanRed, MagentaGreen, YellowBlue)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorbalanceparams
