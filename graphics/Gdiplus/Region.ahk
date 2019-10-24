/*
    The Region class describes an area of the display surface. The area can be any shape.
    In other words, the boundary of the area can be a combination of curved and straight lines.
    Regions can also be created from the interiors of rectangles, paths, or a combination of these.
    Regions are used in clipping and hit-testing operations.

    Region Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-region

    Region Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-region-flat
*/
class Region extends GdiplusBase
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
        if (this.Ptr)
            DllCall("Gdiplus.dll\GdipDeleteRegion", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-region-flat


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Creates a region that is defined by a rectangle.
        Parameters:
            Rect:
                Specifies a rectangle.
        Return value:
            If the method succeeds, the return value is a Region object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromRect(Rect)
    {
        local pRegion := 0
        Gdiplus.LastStatus := Rect is IRect
                            ? DllCall("Gdiplus.dll\GdipCreateRegionRectI", "Ptr", Rect, "UPtrP", pRegion)
                            : DllCall("Gdiplus.dll\GdipCreateRegionRect", "Ptr", Rect, "UPtrP", pRegion)
        return Gdiplus.Region.New(pRegion)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-region-region(inconstrectf_)

    /*
        Creates a region that is defined by a path and has a fill mode that is contained in the GraphicsPath object.
        Parameters:
            GraphicsPath:
                A GraphicsPath object that specifies the path.
        Return value:
            If the method succeeds, the return value is a Region object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromPath(GraphicsPath)
    {
        local pRegion := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateRegionPath", "Ptr", GraphicsPath, "UPtrP", pRegion)
        return Gdiplus.Region.New(pRegion)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-region-region(inconstgraphicspath)

    /*
        Creates a region that is defined by data obtained from another region.
        Parameters:
            RegionData:
                Pointer to an array of bytes that specifies a region.
                The data contained in the bytes is obtained from another region by using the GetData method.
        Return value:
            If the method succeeds, the return value is a Region object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromRgnData(RegionData)
    {
        local pRegion := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateRegionRgnData", "Ptr", RegionData, "UPtrP", pRegion)
        return Gdiplus.Region.New(pRegion)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-region-region(inconstbyte_inint)

    /*
        Creates a region that is identical to the region that is specified by a handle to a Windows Graphics Device Interface (GDI) region.
        Parameters:
            hRegion:
                Handle to an existing GDI region.
        Return value:
            If the method succeeds, the return value is a Region object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromHREGION(hRegion)
    {
        local pRegion := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateRegionHrgn", "Ptr", hRgn, "UPtrP", pRegion)
        return Gdiplus.Region.New(pRegion)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-region-region(inhrgn)


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Makes a copy of this Region object and returns the new Region object.
        Return value:
            If the method succeeds, the return value is a Region object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pRegion := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneRegion", "Ptr", this, "UPtrP", pRegion)
        return Gdiplus.Region.New(pRegion)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-region-clone
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a Region object that is infinite.
    Return value:
        If the method succeeds, the return value is a Region object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Region()
{
    local pRegion := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateRegion", "UPtrP", pRegion)
    return Gdiplus.Region.New(pRegion)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-region-region
