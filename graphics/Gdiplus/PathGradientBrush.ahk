/*
    A PathGradientBrush object stores the attributes of a color gradient that you can use to fill the interior of a path with a gradually changing color.
    A path gradient brush has a boundary path, a boundary color, a center point, and a center color.
    When you paint an area with a path gradient brush, the color changes gradually from the boundary color to the center color as you move from the boundary path to the center point.

    PathGradientBrush Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nl-gdipluspath-pathgradientbrush

    PathGradientBrush Functions:
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-pathgradientbrush-flat
*/
class PathGradientBrush extends Gdiplus.Brush
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Gets the color of the center point of this path gradient brush.
        Return value:
            Returns the ARGB color of the center point of this path gradient brush.
        Remarks:
            By default, the center point of a PathGradientBrush object is the centroid of the brush's boundary path,
             but you can set the center point to any location, inside or outside the path, by calling the SetCenterPoint method.
    */
    GetCenterColor()
    {
        local Color := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetPathGradientCenterColor", "Ptr", this, "UIntP", Color)
        return Color
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-getcentercolor

    /*
        Sets the center color of this path gradient brush. The center color is the color that appears at the brush's center point.
        Parameters:
            Color:
                Specifies the center ARGB color.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            By default the center point is the centroid of the brush's boundary path, but you can set the center point to any location inside or outside the path.
    */
    SetCenterColor(Color)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetPathGradientCenterColor", "Ptr", this, "UInt", Color))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-setcentercolor

    /*
        Gets the surround colors currently specified for this path gradient brush.
        Return value:
            If the method succeeds, the return value is a IColor object with the surround ARGB colors retrieved.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            A path gradient brush has a boundary path and a center point.
            The center point is set to a single color, but you can specify different colors for several points on the boundary.
            For example, suppose you specify red for the center color, and you specify blue, green, and yellow for distinct points on the boundary.
            Then as you move along the boundary, the color will change gradually from blue to green to yellow and back to blue.
            As you move along a straight line from any point on the boundary to the center point, the color will change from that boundary point's color to red.
    */
    GetSurroundColors()
    {
        local Colors := 0  ; Count: the number of colors that have been specified for the boundary path of this path gradient brush.
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-getsurroundcolorcount
        DllCall("Gdiplus.dll\GdipGetPathGradientSurroundColorCount", "Ptr", this, "IntP", Colors)
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetPathGradientSurroundColorsWithCount", "Ptr", this, "Ptr", Colors:=ColorAlloc(Colors), "IntP", Colors.Capacity))
             ? 0       ; Error.
             : Colors  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-getsurroundcolors

    /*
        Sets the surround colors of this path gradient brush. The surround colors are colors specified for discrete points on the brush's boundary path.
        Parameters:
            Colors:
                Specifies an array of ARGB colors that specify the surround colors.
                This parameter can be a IColor object, a Buffer-like object or a memory address that points to an array of UInts.
            Count:
                Specifies the number of colors in «Colors» to use.
                This parameter can be omitted only if «Colors» specifies a IColor object.
        Return value:
            If the method succeeds, the return value is the number of surround colors set.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetSurroundColors(Colors, Count := -1)
    {
        Count := (Type(Colors)=="IColor" && Count<0) ? Colors.Capacity : Count
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetPathGradientSurroundColorsWithCount", "Ptr", this, "Ptr", Colors, "IntP", Count))
             ? 0      ; Error.
             : Count  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-setsurroundcolors
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a PathGradientBrush object based on an array of points. Initializes the wrap mode of the path gradient brush.
    Parameters:
        Point:
            An array of points that specifies the boundary path of the path gradient brush.
        WrapMode:
            Specifies how areas painted with the path gradient brush will be tiled.
            This parameter must be a value from the WrapMode Enumeration. The default value is WrapModeClamp.
    ----------------------------------------------------------------------------------------------------
    Creates a PathGradientBrush object based on a GraphicsPath object.
    Parameters:
        Point:
            A GraphicsPath object that specifies the boundary path of the path gradient brush.
    Return value:
        If the method succeeds, the return value is a PathGradientBrush object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static PathGradientBrush(Point, WrapMode := 4)
{
    local pPathGradientBrush := 0
    switch Type(Point)
    {
    case "IPoint":  ; IPoint object.
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-pathgradientbrush(inconstpoint_inint_inwrapmode)
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreatePathGradientI", "Ptr", Point, "Int", Point.Capacity, "Int", WrapMode, "UPtrP", pPathGradientBrush)
    case "IPointF":  ; IPointF object.
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-pathgradientbrush(inconstpointf_inint_inwrapmode)
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreatePathGradient", "Ptr", Point, "Int", Point.Capacity, "Int", WrapMode, "UPtrP", pPathGradientBrush)
    case "Buffer", "Object":  ; Buffer-like object.
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreatePathGradient", "Ptr", Point, "Int", Point.Size//2, "Int", WrapMode, "UPtrP", pPathGradientBrush)
    default:
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-pathgradientbrush-pathgradientbrush(inconstgraphicspath)
        DllCall("Gdiplus.dll\GdipCreatePathGradientFromPath", "Ptr", Point, "UPtrP", pPathGradientBrush)
    }
    return Gdiplus.PathGradientBrush.New(pPathGradientBrush)
}
