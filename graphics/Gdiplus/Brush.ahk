/*
    The Brush class is an abstract base class that defines a Brush object.
    A Brush object is used to paint the interior of graphics shapes, such as rectangles, ellipses, pies, polygons, and paths.

    Brush Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nl-gdiplusbrush-brush

    Brush Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-brush-flat
*/
class Brush extends GdiplusBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static BrushTypes := Map(0,"SolidBrush",1,"HatchBrush",2,"TextureBrush",3,"PathGradientBrush",4,"LinearGradientBrush")


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Ptr)
            DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-brush-flat


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Makes a copy of this Brush object.
        Return value:
            If the method succeeds, the return value is a Brush object of the same type.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pBrush := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneBrush", "Ptr", this, "UPtrP", pBrush)
        return Gdiplus.%Gdiplus.Brush.BrushTypes[this.Type]%.New(pBrush)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-brush-flat


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the type of this Brush object.
        The value returned is one of the elements of the BrushType Enumeration.
    */
    Type[]
    {
        get {
            local BrushType := 0  ; BrushType Enumeration.
            DllCall("Gdiplus.dll\GdipGetBrushType", "Ptr", this, "IntP", BrushType)
            return BrushType
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-brush-gettype
    }
}
