/*
    A BlurParams object contains members that specify the nature of a Gaussian blur.

    You can apply a Gaussian blur effect to a bitmap by following these steps.
    1. Create and initialize a Gdiplus::BlurParams object.
    2. Pass the BlurParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the Blur object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    BlurParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams
*/
class BlurParams
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
    __New(Radius, ExpandEdge)
    {
        this.Buffer := BufferAlloc(Gdiplus.BlurParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.Radius     := Radius
        this.ExpandEdge := ExpandEdge
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the blur radius (the radius of the Gaussian convolution kernel) in pixels.
    */
    Radius[]
    {
        get => NumGet(this, "Float")
        set => NumPut("Float", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams

    /*
        Gets or sets the flag that specifies whether the bitmap expands by an amount equal to the blur radius.
    */
    ExpandEdge[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a BlurParams object.
    Parameters:
        Radius:
            Real number that specifies the blur radius (the radius of the Gaussian convolution kernel) in pixels.
            The radius must be in the range 0 through 255. As the radius increases, the resulting bitmap becomes more blurry.
        ExpandEdge:
            Boolean value that specifies whether the bitmap expands by an amount equal to the blur radius.
            TRUE    The bitmap expands by an amount equal to the radius so that it can have soft edges.
            FALSE   The bitmap remains the same size and the soft edges are clipped.
    Return value:
        The return value is a BlurParams object.
*/
static BlurParams(Radius := 0, ExpandEdge := 0)
{
    return Gdiplus.BlurParams.New(Radius, ExpandEdge)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-blurparams
