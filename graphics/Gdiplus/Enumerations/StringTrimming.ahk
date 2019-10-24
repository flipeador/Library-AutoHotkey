/*
    Specifies how to trim characters from a string so that the string fits into a layout rectangle.
    The layout rectangle is used to position and size the display string.

    StringTrimming Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-stringtrimming
*/
class StringTrimming
{
    static None              := 0  ; Specifies that no trimming is done.
    static Character         := 1  ; Specifies that the string is broken at the boundary of the last character that is inside the layout rectangle. This is the default.
    static Word              := 2  ; Specifies that the string is broken at the boundary of the last word that is inside the layout rectangle.
    static EllipsisCharacter := 3  ; Specifies that the string is broken at the boundary of the last character that is inside the layout rectangle and an ellipsis (...) is inserted after the character.
    static EllipsisWord      := 4  ; Specifies that the string is broken at the boundary of the last word that is inside the layout rectangle and an ellipsis (...) is inserted after the word.
    static EllipsisPath      := 5  ; Specifies that the center is removed from the string and replaced by an ellipsis. The algorithm keeps as much of the last portion of the string as possible.
}
