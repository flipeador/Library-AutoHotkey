/*
    The FontStyle enumeration specifies the style of the typeface of a font. Styles can be combined.

    FontStyle Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-fontstyle
*/
class FontStyle
{
    static Regular    := 0  ; Specifies normal weight or thickness of the typeface.
    static Bold       := 1  ; Specifies bold typeface. Bold is a heavier weight or thickness.
    static Italic     := 2  ; Specifies italic typeface, which produces a noticeable slant to the vertical stems of the characters.
    static BoldItalic := 3  ; Specifies the typeface as both bold and italic.
    static Underline  := 4  ; Specifies underline, which displays a line underneath the baseline of the characters.
    static Strikeout  := 5  ; Specifies strikeout, which displays a horizontal line drawn through the middle of the characters.
}
