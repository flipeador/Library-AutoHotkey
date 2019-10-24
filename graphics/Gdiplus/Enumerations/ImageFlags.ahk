/*
    The ImageFlags enumeration specifies the attributes of the pixel data contained in a Gdiplus::Image object.
    The Gdiplus::Image::Flags property returns an element of this enumeration.

    ImageFlags Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-imageflags
*/
class ImageFlags
{
    static None              := 0x0000  ; Specifies no format information.

    ; Low-word: shared with SINKFLAG_x:
    static Scalable          := 0x00001  ; Specifies that the image can be scaled.
    static HasAlpha          := 0x00002  ; Specifies that the pixel data contains alpha values.
    static HasTranslucent    := 0x00004  ; Specifies that the pixel data has alpha values other than 0 (transparent) and 255 (opaque).
    static PartiallyScalable := 0x00008  ; Specifies that the pixel data is partially scalable with some limitations.

    ; Low-word: color space definition:
    static ColorSpaceRGB     := 0x00010  ; Specifies that the image is stored using an RGB color space.
    static ColorSpaceCMYK    := 0x00020  ; Specifies that the image is stored using a CMYK color space.
    static ColorSpaceGRAY    := 0x00040  ; Specifies that the image is a grayscale image.
    static ColorSpaceYCBCR   := 0x00080  ; Specifies that the image is stored using a YCBCR color space.
    static ColorSpaceYCCK    := 0x00100  ; Specifies that the image is stored using a YCCK color space.

    ; Low-word: image size info:
    static HasRealDPI        := 0x01000  ; Specifies that dots per inch information is stored in the image.
    static HasRealPixelSize  := 0x02000  ; Specifies that the pixel size is stored in the image.

    ; High-word:
    static ReadOnly          := 0x10000  ; Specifies that the pixel data is read-only.
    static Caching           := 0x20000  ; Specifies that the pixel data can be cached for faster access.
}
