/*
    The following constants specify various pixel formats used in bitmaps.

    Image Pixel Format Constants:
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-constant-image-pixel-format-constants

    Remarks:
        PixelFormat48bppRGB, PixelFormat64bppARGB, and PixelFormat64bppPARGB use 16 bits per color component (channel).
        Windows GDI+ version 1.0 can read 16-bits-per-channel images, but such images are converted to an 8-bits-per-channel format for processing, displaying, and saving.
*/
static PixelFormat1bppIndexed    := 0x00030101  ; Specifies that the format is 1 bit per pixel, indexed.
static PixelFormat4bppIndexed    := 0x00030402  ; PixelFormat4bppIndexed     Specifies that the format is 4 bits per pixel, indexed.
static PixelFormat8bppIndexed    := 0x00030803  ; Specifies that the format is 8 bits per pixel, indexed.
static PixelFormat16bppARGB1555  := 0x00061007  ; Specifies that the format is 16 bits per pixel; 1 bit is used for the alpha component, and 5 bits each are used for the red, green, and blue components.
static PixelFormat16bppGrayScale := 0x00101004  ; Specifies that the format is 16 bits per pixel, grayscale.
static PixelFormat16bppRGB555    := 0x00021005  ; Specifies that the format is 16 bits per pixel; 5 bits each are used for the red, green, and blue components. The remaining bit is not used.
static PixelFormat16bppRGB565    := 0x00021006  ; Specifies that the format is 16 bits per pixel; 5 bits are used for the red component, 6 bits are used for the green component, and 5 bits are used for the blue component.
static PixelFormat24bppRGB       := 0x00021808  ; Specifies that the format is 24 bits per pixel; 8 bits each are used for the red, green, and blue components.
static PixelFormat32bppARGB      := 0x0026200A  ; Specifies that the format is 32 bits per pixel; 8 bits each are used for the alpha, red, green, and blue components.
static PixelFormat32bppPARGB     := 0x000E200B  ; Specifies that the format is 32 bits per pixel; 8 bits each are used for the alpha, red, green, and blue components. The red, green, and blue components are premultiplied according to the alpha component.
static PixelFormat32bppRGB       := 0x00022009  ; Specifies that the format is 32 bits per pixel; 8 bits each are used for the red, green, and blue components. The remaining 8 bits are not used.
static PixelFormat48bppRGB       := 0x0010300C  ; Specifies that the format is 48 bits per pixel; 16 bits each are used for the red, green, and blue components.
static PixelFormat64bppARGB      := 0x0034400D  ; Specifies that the format is 64 bits per pixel; 16 bits each are used for the alpha, red, green, and blue components.
static PixelFormat64bppPARGB     := 0x001C400E  ; Specifies that the format is 64 bits per pixel; 16 bits each are used for the alpha, red, green, and blue components. The red, green, and blue components are premultiplied according to the alpha component.
