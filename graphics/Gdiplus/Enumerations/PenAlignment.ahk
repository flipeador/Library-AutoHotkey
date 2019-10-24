/*
    The PenAlignment enumeration specifies the alignment of a pen relative to the stroke that is being drawn.

    PenAlignment Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-penalignment
*/
class PenAlignment
{
    static Center := 0  ; Specifies that the pen is aligned on the center of the line that is drawn.
    static Inset  := 1  ; Specifies, when drawing a polygon, that the pen is aligned on the inside of the edge of the polygon.
}
