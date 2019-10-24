/*
    The PixelOffsetMode enumeration specifies the pixel offset mode of a Gdiplus::Graphics object.
    This enumeration is used by the PixelOffsetMode property of the Gdiplus::Graphics class.

    PixelOffsetMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-pixeloffsetmode
*/
class PixelOffsetMode
{
    static Invalid     := -1  ; Used internally.
    static Default     :=  0  ; Equivalent to PixelOffsetModeNone.
    static HighSpeed   :=  1  ; Equivalent to PixelOffsetModeNone.
    static HighQuality :=  2  ; Equivalent to PixelOffsetModeHalf.
    static None        :=  3  ; Indicates that pixel centers have integer coordinates.
    static Half        :=  4  ; Indicates that pixel centers have coordinates that are half way between integer values.
}
