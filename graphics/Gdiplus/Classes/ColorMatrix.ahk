/*
    The ColorMatrix object contains a 5×5 matrix of real numbers.
    Several methods of the Gdiplus::ImageAttributes class adjust image colors by using a color matrix.

    You can apply a ColorMatrix effect to a bitmap by following these steps.
    1. Create and initialize a Gdiplus::ColorMatrix object.
    2. Pass the Gdiplus::ColorMatrix object to the Gdiplus::Effect::SetParameters method.
    3. Pass the Gdiplus::Effect::ColorMatrixEffect object to the Gdiplus::Graphics::DrawImage method or to the Gdiplus::Bitmap::ApplyEffect method.

    ColorMatrix Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ns-gdipluscolormatrix-colormatrix
*/
class ColorMatrix
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Size := 4*(5*5)  ; Size, in bytes, of this structure.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer := 0
    Ptr    := 0
    Size   := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(m1, m2, m3, m4, m5)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.ColorMatrix.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        NumPut("Float", m1, "Float", m2, "Float", m3, "Float", m4, "Float", m5, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ns-gdipluscolormatrix-colormatrix


    ; ===================================================================================================================
    ; ITEM PROPERTY
    ; ===================================================================================================================
    __Item[Index]
    {
        get => NumGet(this, 4*(Index-1), "Float")
        set => NumPut("Float", Value, this, 4*(Index-1))
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a Gdiplus::ColorMatrix object.
    Return value:
        The return value is a Gdiplus::ColorMatrix object.
*/
static ColorMatrix(m1 := 0, m2 := 0, m3 := 0, m4 := 0, m5 := 0)
{
    return Gdiplus.ColorMatrix.New(m1, m2, m3, m4, m5)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolormatrix/ns-gdipluscolormatrix-colormatrix
