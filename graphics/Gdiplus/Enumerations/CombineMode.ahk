/*
    The CombineMode enumeration specifies how a new region is combined with an existing region.

    CombineMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-combinemode
*/
class CombineMode
{
    static Replace    := 0  ; Specifies that the existing region is replaced by the new region.
    static Intersect  := 1  ; Specifies that the existing region is replaced by the intersection of itself and the new region.
    static Union      := 2  ; Specifies that the existing region is replaced by the union of itself and the new region.
    static Xor        := 3  ; Specifies that the existing region is replaced by the result of performing an XOR on the two regions. A point is in the XOR of two regions if it is in one region or the other but not in both regions.
    static Exclude    := 4  ; Specifies that the existing region is replaced by the portion of itself that is outside of the new region.
    static Complement := 5  ; Specifies that the existing region is replaced by the portion of the new region that is outside of the existing region.
}
