/*
    The ImageType enumeration indicates whether an image is a bitmap or a metafile.
    The Gdiplus::Image::Type property returns an element of this enumeration.

    ImageType Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-imagetype
*/
class ImageType
{
    static Unknown  := 0  ; Indicates that the image type is not known.
    static Bitmap   := 1  ; Indicates a bitmap image.
    static Metafile := 2  ; Indicates a metafile image.
}
