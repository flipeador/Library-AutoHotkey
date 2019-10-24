/*
    The LevelsParams object contains members that specify adjustments to the light, midtone, or dark areas of a bitmap.

    You can adjust the light, midtone, or dark areas of a bitmap by following these steps.
    1. Create and initialize a Gdiplus::LevelsParams object.
    2. Pass the LevelsParams object to the Gdiplus::Effect::SetParameters method.
    3. Pass the Levels object to the Graphics::DrawImage method or to the Bitmap::ApplyEffect method.

    LevelsParams Structure:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams
*/
class LevelsParams
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
    __New(Highlight, Midtone, Shadow)
    {
        this.Buffer := BufferAlloc(Gdiplus.Effect.LevelsParams.Size)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        this.Highlight := Highlight
        this.Midtone   := Midtone
        this.Shadow    := Shadow
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    Highlight[]
    {
        get => NumGet(this, "Int")
        set => NumPut("Int", Value, this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams

    Midtone[]
    {
        get => NumGet(this, 4, "Int")
        set => NumPut("Int", Value, this, 4)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams

    Shadow[]
    {
        get => NumGet(this, 8, "Int")
        set => NumPut("Int", Value, this, 8)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a LevelsParams object.
    Parameters:
        Highlight:
            Integer in the range 0 through 100 that specifies which pixels should be lightened.
            You can use this adjustment to lighten pixels that are already lighter than a certain threshold.
            Setting highlight to 100 specifies no change.
            Setting highlight to t specifies that a color channel value is increased if it is already greater than t percent of full intensity.
            For example, setting highlight to 90 specifies that all color channel values greater than 90 percent of full intensity are increased.
        Midtone:
            Integer in the range -100 through 100 that specifies how much to lighten or darken an image.
            Color channel values in the middle of the intensity range are altered more than color channel values near the minimum or maximum intensity.
            You can use this adjustment to lighten (or darken) an image without loosing the contrast between the darkest and lightest portions of the image.
            A value of 0 specifies no change.
            Positive values specify that the midtones are made lighter.
            Negative values specify that the midtones are made darker.
        Shadow:
            Integer in the range 0 through 100 that specifies which pixels should be darkened.
            You can use this adjustment to darken pixels that are already darker than a certain threshold.
            Setting shadow to 0 specifies no change.
            Setting shadow to t specifies that a color channel value is decreased if it is already less than t percent of full intensity.
            For example, setting shadow to 10 specifies that all color channel values less than 10 percent of full intensity are decreased.
    Return value:
        The return value is a LevelsParams object.
*/
static LevelsParams(Highlight := 0, Midtone := 0, Shadow := 0)
{
    return Gdiplus.LevelsParams.New(Highlight, Midtone, Shadow)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/ns-gdipluseffects-levelsparams
