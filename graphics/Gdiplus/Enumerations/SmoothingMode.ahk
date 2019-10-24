/*
    The SmoothingMode enumeration specifies the type of smoothing (antialiasing) that is applied to lines and curves.
    This enumeration is used by the SmoothingMode property of the Gdiplus::Graphics class.

    SmoothingMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-smoothingmode
*/
class SmoothingMode
{
    static Invalid      := -1  ; Reserved.
    static Default      :=  0  ; Specifies that smoothing is not applied.
    static HighSpeed    :=  1  ; Specifies that smoothing is not applied.
    static HighQuality  :=  2  ; Specifies that smoothing is applied using an 8x4 box filter.
    static None         :=  3  ; Specifies that smoothing is not applied.
    static AntiAlias    :=  4  ; Specifies that smoothing is applied using an 8x4 box filter.
    static AntiAlias8x4 :=  5  ; Specifies that smoothing is applied using an 8x4 box filter.
    static AntiAlias8x8 :=  6  ; Specifies that smoothing is applied using an 8x8 box filter.
}
