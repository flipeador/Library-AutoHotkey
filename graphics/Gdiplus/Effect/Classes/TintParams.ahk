/*
    A TintParams object contains members that specify the nature of a tint adjustment to a bitmap.

    You can adjust the tint of a bitmap by following these steps.
    1. Create and initialize a Gdiplus::TintParams object.
    2. Pass the TintParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the Tint object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    TintParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams
*/
class TintParams
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
    __New(Hue, Amount)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.TintParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.Hue    := Hue
        this.Amount := Amount
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the hue.
    */
    Hue[]
    {
        get => NumGet(this, "Int")
        set => NumPut("Int", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams

    /*
        Gets or sets how much the hue is strengthened or weakened.
    */
    Amount[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a TintParams object.
    Parameters:
        Hue:
            Integer in the range -180 through 180 that specifies the hue to be strengthened or weakened.
            A value of 0 specifies blue.
            A positive value specifies a clockwise angle on the color wheel. For example, positive 60 specifies cyan and positive 120 specifies green.
            A negative value specifies a counter-clockwise angle on the color wheel. For example, negative 60 specifies magenta and negative 120 specifies red.
        Amount:
            Integer in the range -100 through 100 that specifies how much the hue (given by the Hue parameter) is strengthened or weakened.
            A value of 0 specifies no change. Positive values specify that the hue is strengthened and negative values specify that the hue is weakened.
    Return value:
        The return value is a TintParams object.
*/
static TintParams(Hue := 0, Amount := 0)
{
    return Gdiplus.TintParams.New(Hue, Amount)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-tintparams
