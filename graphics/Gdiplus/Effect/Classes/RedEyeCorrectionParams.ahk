/*
    A RedEyeCorrectionParams object contains members that specify the areas of a bitmap to which a red-eye correction is applied.

    You can can correct red eyes in a bitmap by following these steps.
    1. Create and initialize a Gdiplus::RedEyeCorrectionParams object.
    2. Pass the RedEyeCorrectionParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the RedEyeCorrection object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    RedEyeCorrectionParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams
*/
class RedEyeCorrectionParams
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Size := 2*A_PtrSize  ; Size, in bytes, of this structure.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer := 0
    Ptr    := 0
    Size   := 0
    _Areas := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Areas, NumberOfAreas)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.RedEyeCorrectionParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.NumberOfAreas := NumberOfAreas
        this._Areas        := Areas
        this.Areas         := IsObject(Areas) ? Areas.Ptr : Areas
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the number of RECT structures in the areas array.
    */
    NumberOfAreas[]
    {
        get => NumGet(this, "UInt")
        set => NumPut("UInt", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams

    /*
        Gets or sets the pointer to the array of RECT structures.
    */
    Areas[]
    {
        get => NumGet(this, A_PtrSize, "UPtr")
        set => NumPut("UPtr", IsObject(Value)?Value.Ptr:Value, (this._Areas:=Value)?this:this, A_PtrSize)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a RedEyeCorrectionParams object.
    Parameters:
        Areas:
            An array of RECT structures, each of which specifies an area of the bitmap to which red eye correction should be applied.
            This parameter must be a IRect object, a memory address or a Buffer-like object.
        NumberOfAreas:
            Integer that specifies the number of RECT structures in the areas array.
    Return value:
        The return value is a RedEyeCorrectionParams object.
*/
static RedEyeCorrectionParams(Areas := 0, NumberOfAreas := 0)
{
    return Gdiplus.RedEyeCorrectionParams.New(Areas, NumberOfAreas)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-redeyecorrectionparams
