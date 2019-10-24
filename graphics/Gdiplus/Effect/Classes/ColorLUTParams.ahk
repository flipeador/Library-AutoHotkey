/*
    A ColorLUTParams object contains members (color lookup tables) that specify color adjustments to a bitmap.

    You can apply a custom adjustment to a bitmap by following these steps.
    1. Create and initialize a Gdiplus::ColorLUTParams object.
    2. Each member of the ColorLUTParams object is a color lookup table (array of 256 bytes) for a particular color channel, alpha, red, green, or blue. Assign values of your choice to the four lookup tables.
    3. Pass the ColorLUTParams object to the Gdiplus::Effect::SetParameters method.
    4. Pass the ColorLUT object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    ColorLUTParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams
*/
class ColorLUTParams
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Size := 4*256  ; Size, in bytes, of this structure.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer := 0
    Ptr    := 0
    Size   := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.BlurParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Array of 256 bytes that specifies the adjustment for the red channel.
    */
    Red[Index]
    {
        get => NumGet(this, 511+Index, "UChar")
        set => NumPut("UChar", Value, this, 511+Index)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams

    /*
        Array of 256 bytes that specifies the adjustment for the green channel.
    */
    Green[Index]
    {
        get => NumGet(this, 255+Index, "UChar")
        set => NumPut("UChar", Value, this, 255+Index)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams

    /*
        Array of 256 bytes that specifies the adjustment for the blue channel.
    */
    Blue[Index]
    {
        get => NumGet(this, Index-1, "UChar")
        set => NumPut("UChar", Value, this, Index-1)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams

    /*
        Array of 256 bytes that specifies the adjustment for the alpha channel.
    */
    Alpha[Index]
    {
        get => NumGet(this, 767+Index, "UChar")
        set => NumPut("UChar", Value, this, 767+Index)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a ColorLUTParams object.
    Return value:
        The return value is a ColorLUTParams object.
*/
static ColorLUTParams()
{
    return Gdiplus.ColorLUTParams.New()
}  ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-colorlutparams
