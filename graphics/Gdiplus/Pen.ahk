/*
    A Pen object is a Windows GDI+ object used to draw lines and curves.

    Pen Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nl-gdipluspen-pen

    Pen Functions:
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-pen-flat
*/
class Pen extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr  := 0  ; Pointer to the object.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        DllCall("Gdiplus.dll\GdipDeletePen", "Ptr", this)
    } ; https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-pen-flat


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Creates a Pen object that uses the attributes of a brush and a real number to set the width of this Pen object.
        Parameters:
            Brush:
                A Brush object to base this pen on.
        Return value:
            If the method succeeds, the return value is a Pen object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromBrush(Brush, Width, Unit := 2)
    {
        local pPen := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreatePen2", "Ptr", Brush, "Float", Width, "Int", Unit, "UPtrP", pPen)
        return Gdiplus.Pen.New(pPen)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-pen(inconstbrush_inreal)


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Makes a copy of this Pen object.
        Return value:
            If the method succeeds, the return value is a Pen object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pPen := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipClonePen", "Ptr", this, "UPtrP", pPen)
        return Gdiplus.Pen.New(pPen)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-clone


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the width for this Pen object.
    */
    Width[]
    {
        get {
            local Width := 0
            DllCall("Gdiplus.dll\GdipGetPenWidth", "Ptr", this, "FloatP", Width)
            return Width
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-getwidth
        set => DllCall("Gdiplus.dll\GdipSetPenWidth", "Ptr", this, "Float", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-setwidth
    }

    /*
        Gets or sets the ARGB color for this Pen object.
    */
    Color[]
    {
        get {
            local Color := 0
            DllCall("Gdiplus.dll\GdipGetPenColor", "Ptr", this, "UIntP", Color)
            return Color
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-getcolor
        set => DllCall("Gdiplus.dll\GdipSetPenColor", "Ptr", this, "UInt", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-setcolor
    }

    /*
        Gets or sets the unit of measure for this Pen object.
    */
    Unit[]
    {
        get {
            local Unit := 0
            DllCall("Gdiplus.dll\GdipGetPenUnit", "Ptr", this, "IntP", Unit)
            return Unit
        }
        set => DllCall("Gdiplus.dll\GdipSetPenUnit", "Ptr", this, "Int", Value)
    } ; https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-pen-flat

    /*
        Gets or sets the alignment for this Pen object relative to the line.
        Value:
            Element of the PenAlignment enumeration that specifies the alignment setting of the pen relative to the line that is drawn. The default value is PenAlignmentCenter.
    */
    Alignment[]
    {
        get {
            local Alignment := 0
            DllCall("Gdiplus.dll\GdipGetPenMode", "Ptr", this, "IntP", Alignment)
            return Alignment
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusstringformat/nf-gdiplusstringformat-stringformat-getalignment
        set => DllCall("Gdiplus.dll\GdipSetPenMode", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-setalignment
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a Pen object that uses a specified color and width.
    Parameters:
        Color:
            Specifies the ARGB color for this Pen object. The default color is 100% black.
        Width:
            Real number that specifies the width of this pen's stroke. The default value is 1.
        Unit:
            Specifies the unit of measure (Unit Enumeration). The default unit of measure is UnitPixel.
    Return value:
        If the method succeeds, the return value is a Pen object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Pen(Color := 0xFF000000, Width := 1, Unit := 2)
{
    local pPen := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreatePen1", "UInt", Color, "Float", Width, "Int", Unit, "UPtrP", pPen)
    return Gdiplus.Pen.New(pPen)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspen/nf-gdipluspen-pen-pen(inconstcolor__inreal)
