/*
    Specifies how a string is aligned in reference to the bounding rectangle.
    A bounding rectangle is used to define the area in which the text displays.

    StringAlignment Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringalignment
*/
class StringAlignment
{
    static Near   := 0  ; Specifies that alignment is towards the origin of the bounding rectangle. May be used for alignment of characters along the line or for alignment of lines within the rectangle. For a right to left bounding rectangle (StringFormatFlagsDirectionRightToLeft), the origin is at the upper right.
    static Center := 1  ; Specifies that alignment is centered between origin and extent (width) of the formatting rectangle.
    static Far    := 2  ; Specifies that alignment is to the far extent (right side) of the formatting rectangle.
}
