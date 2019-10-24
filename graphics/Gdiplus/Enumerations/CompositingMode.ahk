/*
    The CompositingMode enumeration specifies how rendered colors are combined with background colors.
    This enumeration is used by the CompositingMode property of the Gdiplus::Graphics class.

    CompositingMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-compositingmode
*/
class CompositingMode
{
    static SourceOver := 0  ; Specifies that when a color is rendered, it is blended with the background color. The blend is determined by the alpha component of the color being rendered.
    static SourceCopy := 1  ; Specifies that when a color is rendered, it overwrites the background color. This mode cannot be used along with TextRenderingHintClearTypeGridFit.
}
