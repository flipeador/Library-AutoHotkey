/*
    The RotateFlipType enumeration specifies the direction of an image's rotation and the axis used to flip the image.

    RotateFlipType Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimaging/ne-gdiplusimaging-rotatefliptype
*/
class RotateFlipType
{
    static RotateNoneFlipNone := 0  ; Specifies no rotation and no flipping.
    static Rotate180FlipXY    := 0  ; Specifies a 180-degree rotation followed by a horizontal flip and then a vertical flip.
    static Rotate90FlipNone   := 1  ; Specifies a 90-degree rotation without flipping.
    static Rotate270FlipXY    := 1  ; Specifies a 270-degree rotation followed by a horizontal flip and then a vertical flip.
    static Rotate180FlipNone  := 2  ; Specifies a 180-degree rotation without flipping.
    static RotateNoneFlipXY   := 2  ; Specifies no rotation, a horizontal flip, and then a vertical flip.
    static Rotate270FlipNone  := 3  ; Specifies a 270-degree rotation without flipping.
    static Rotate90FlipXY     := 3  ; Specifies a 90-degree rotation followed by a horizontal flip and then a vertical flip.
    static RotateNoneFlipX    := 4  ; Specifies no rotation and a horizontal flip.
    static Rotate180FlipY     := 4  ; Specifies a 180-degree rotation followed by a vertical flip.
    static Rotate90FlipX      := 5  ; Specifies a 90-degree rotation followed by a horizontal flip.
    static Rotate270FlipY     := 5  ; Specifies a 270-degree rotation followed by a vertical flip.
    static Rotate180FlipX     := 6  ; Specifies a 180-degree rotation followed by a horizontal flip.
    static RotateNoneFlipY    := 6  ; Specifies no rotation and a vertical flip.
    static Rotate270FlipX     := 7  ; Specifies a 270-degree rotation followed by a horizontal flip.
    static Rotate90FlipY      := 7  ; Specifies a 90-degree rotation followed by a vertical flip.
}
