/*
    The CompositingQuality enumeration specifies whether gamma correction is applied when colors are blended with background colors.
    This enumeration is used by the CompositingQuality property of the Gdiplus::Graphics class.

    CompositingQuality Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingquality
*/
class CompositingQuality
{
    static Invalid        := -1  ; -
    static Default        :=  0  ; Specifies that gamma correction is not applied.
    static HighSpeed      :=  1  ; Specifies that gamma correction is not applied.
    static HighQuality    :=  2  ; Specifies that gamma correction is applied.
    static GammaCorrected :=  3  ; Specifies that gamma correction is applied.
    static AssumeLinear   :=  4  ; Specifies that gamma correction is not applied.
}
