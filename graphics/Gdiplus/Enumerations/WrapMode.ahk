/*
    The WrapMode enumeration specifies how repeated copies of an image are used to tile an area.

    WrapMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-wrapmode
*/
class WrapMode
{
    static Tile       := 0  ; Specifies tiling without flipping.
    static TileFlipX  := 1  ; Specifies that tiles are flipped horizontally as you move from one tile to the next in a row.
    static TileFlipY  := 2  ; Specifies that tiles are flipped vertically as you move from one tile to the next in a column.
    static TileFlipXY := 3  ; Specifies that tiles are flipped horizontally as you move along a row and flipped vertically as you move along a column.
    static Clamp      := 4  ; Specifies that no tiling takes place.
}
