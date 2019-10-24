/*
    A SharpenParams object contains members that specify the nature of a sharpening adjustment to a bitmap.

    You can adjust the sharpness of a bitmap by following these steps:
    1. Create and initialize a Gdiplus::SharpenParams object.
    2. Pass the SharpenParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the Sharpen object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    SharpenParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams
*/
class SharpenParams
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
    __New(Radius, Amount)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.SharpenParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.Radius := Radius
        this.Amount := Amount
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the sharpening radius (the radius of the convolution kernel) in pixels.
    */
    Radius[]
    {
        get => NumGet(this, "Float")
        set => NumPut("Float", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams

    /*
        Gets or sets the amount of sharpening to be applied.
    */
    Amount[]
    {
        get => NumGet(this, 4, "Float")
        set => NumPut("Float", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a SharpenParams object.
    Parameters:
        Radius:
            Real number that specifies the sharpening radius (the radius of the convolution kernel) in pixels.
            The radius must be in the range 0 through 255. As the radius increases, more surrounding pixels are involved in calculating the new value of a given pixel.
        Amount:
            Real number in the range 0 through 100 that specifies the amount of sharpening to be applied.
            A value of 0 specifies no sharpening. As the value of amount increases, the sharpness increases.
    Return value:
        The return value is a SharpenParams object.
*/
static SharpenParams(Radius := 0, Amount := 0)
{
    return Gdiplus.SharpenParams.New(Radius, Amount)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-sharpenparams
