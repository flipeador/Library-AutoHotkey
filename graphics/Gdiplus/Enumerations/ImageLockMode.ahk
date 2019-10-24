/*
    The ImageLockMode enumeration specifies flags that are passed to the flags parameter of the Gdiplus::Bitmap::LockBits method.
    The Gdiplus::Bitmap::LockBits method locks a portion of an image so that you can read or write the pixel data.

    ImageLockMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-imagelockmode
*/
class ImageLockMode
{
    static Read         := 0x0001  ; Specifies that a portion of the image is locked for reading.
    static Write        := 0x0002  ; Specifies that a portion of the image is locked for writing.
    static UserInputBuf := 0x0004  ; Specifies that the buffer used for reading or writing pixel data is allocated by the user.
                                   ; If this flag is set, then the BitmapData parameter of the Gdiplus::Bitmap::LockBits method serves as an input parameter (and possibly as an output parameter).
                                   ; If this flag is cleared, then the BitmapData parameter serves only as an output parameter.
}
