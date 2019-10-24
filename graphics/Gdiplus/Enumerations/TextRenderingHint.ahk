/*
    The TextRenderingHint enumeration specifies the process used to render text. The process affects the quality of the text.
    This enumeration is used by the TextRenderingHint property of the Gdiplus::Graphics class.

    TextRenderingHint Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-textrenderinghint

    Remarks:
        The quality associated with each process varies according to the circumstances.
        TextRenderingHintClearTypeGridFit provides the best quality for most LCD monitors and relatively small font sizes.
        TextRenderingHintAntiAlias provides the best quality for rotated text.
        Generally, a process that produces higher quality text is slower than a process that produces lower quality text.
*/
class TextRenderingHint
{
    static SystemDefault            := 0  ; Specifies that a character is drawn using the currently selected system font smoothing mode (also called a rendering hint).
    static SingleBitPerPixelGridFit := 1  ; Specifies that a character is drawn using its glyph bitmap and hinting to improve character appearance on stems and curvature.
    static SingleBitPerPixel        := 2  ; Specifies that a character is drawn using its glyph bitmap and no hinting. This results in better performance at the expense of quality.
    static AntiAliasGridFit         := 3  ; Specifies that a character is drawn using its antialiased glyph bitmap and hinting. This results in much better quality due to antialiasing at a higher performance cost.
    static AntiAlias                := 4  ; Specifies that a character is drawn using its antialiased glyph bitmap and no hinting. Stem width differences may be noticeable because hinting is turned off.
    static ClearTypeGridFit         := 5  ; Specifies that a character is drawn using its glyph ClearType bitmap and hinting. This type of text rendering cannot be used along with CompositingModeSourceCopy.
}
