/*
    Specifies the direction in which the change of color occurs for a linear gradient brush.

    LinearGradientMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-lineargradientmode
*/
class LinearGradientMode
{
    static Horizontal       := 0  ; Specifies the color to change in a horizontal direction from the left of the display to the right of the display.
    static Vertical         := 1  ; Specifies the color to change in a vertical direction from the top of the display to the bottom of the display.
    static ForwardDiagonal  := 2  ; Specifies the color to change in a forward diagonal direction from the upper-left corner to the lower-right corner of the display.
    static BackwardDiagonal := 3  ; Specifies the color to change in a backward diagonal direction from the upper-right corner to the lower-left corner of the display.
}
