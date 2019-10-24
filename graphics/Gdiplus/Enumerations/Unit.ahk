/*
    The Unit enumeration specifies the unit of measure for a given data type.

    Unit Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-unit
*/
class Unit
{
    static UnitWorld      := 0  ; Specifies world coordinates, a nonphysical unit.
    static UnitDisplay    := 1  ; Specifies display units. For example, if the display device is a monitor, then the unit is 1 pixel.
    static UnitPixel      := 2  ; Specifies that a unit is 1 pixel.
    static UnitPoint      := 3  ; Specifies that a unit is 1 point or 1/72 inch.
    static UnitInch       := 4  ; Specifies that a unit is 1 inch.
    static UnitDocument   := 5  ; Specifies that a unit is 1/300 inch.
    static UnitMillimeter := 6  ; Specifies that a unit is 1 millimeter.
}
