/*
    A GraphicsPath object stores a sequence of lines, curves, and shapes.
    You can draw the entire sequence by calling the Graphics::DrawPath method, and you can fill a path by calling the Graphics::FillPath method.
    You can partition the sequence of lines, curves, and shapes into figures, and with the help of a GraphicsPathIterator object, you can draw selected figures.
    You can also place markers in the sequence, so that you can draw selected portions of the path.

    A path is a sequence of graphics primitives (lines, rectangles, curves, text, and the like) that can be manipulated and drawn as a single unit.
    A path can be divided into figures that are either open or closed. A figure can contain several primitives.

    GraphicsPath Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nl-gdipluspath-graphicspath

    GraphicsPath Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-graphicspath-flat
*/
class GraphicsPath extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


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
            DllCall("Gdiplus.dll\GdipDeletePath", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-graphicspath-flat


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        creates a new GraphicsPath object, and initializes it with the contents of this GraphicsPath object.
        Return value:
            If the method succeeds, the return value is a GraphicsPath object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pGraphicsPath := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipClonePath", "Ptr", this, "UPtrP", pGraphicsPath)
        return Gdiplus.GraphicsPath.New(pGraphicsPath)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-clone

    /*
        Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    StartFigure()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipStartPathFigure", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-startfigure

    /*
        Closes the current figure of this path.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    CloseFigure()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipClosePathFigure", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-closefigure

    /*
        Closes all open figures in this path.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    CloseAllFigures()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipClosePathFigures", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Gdipluspath/nf-gdipluspath-graphicspath-closeallfigures

    /*
        Replaces this path with curves that enclose the area that is filled when this path is drawn by a specified pen. This method also flattens the path.
        Parameters:
            Pen:
                A Pen object. The path is made as wide as it would be when drawn by this pen.
            Matrix:
                A Matrix object that specifies a transformation to be applied along with the widening.
                If this parameter is zero, no transformation is applied. The default value is zero.
            Flatness:
                Real number that specifies the maximum error between the path and its flattened approximation.
                Reducing the flatness increases the number of line segments in the approximation. The default value is 0.25 (FlatnessDefault=1.0f/4.0f).
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Widen(Pen, Matrix := 0, Flatness := 0.25)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipWidenPath", "Ptr", this, "Ptr", Pen, "Ptr", Matrix, "Float", Flatness))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-widen

    /*
        Adds a pie to this path.
        An arc is a portion of an ellipse, and a pie is a portion of the area enclosed by an ellipse.
        A pie is bounded by an arc and two lines (edges) that go from the center of the ellipse to the endpoints of the arc.
        Parameters:
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the ellipse that bounds the pie.
            Width / Height:
                Real number that specifies the width/height of the rectangle that bounds the ellipse that bounds the pie.
            StartAngle:
                Real number that specifies the clockwise angle, in degrees, between the horizontal axis of the ellipse and the starting point of the arc that defines the pie.
            SweepAngle:
                Real number that specifies the clockwise angle, in degrees, between the starting and ending points of the arc that defines the pie.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    AddPie(X, Y, Width, Height, StartAngle, SweepAngle)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathPie", "Ptr", this, "Float", X, "Float", Y, "Float", Width, "Float", Height, "Float", StartAngle, "Float", SweepAngle))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-addpie

    AddPies(Rect, StartAngle, SweepAngle, Count := -1)
    {
        loop (Count<0 ? Rect.Length : Count)
            if (!this.AddPies(Rect.X[A_Index],Rect.Y[A_Index],Rect.W[A_Index],Rect.H[A_Index]
                ,IsObject(StartAngle)?StartAngle[A_Index]:StartAngle,IsObject(SweepAngle)?SweepAngle[A_Index]:SweepAngle))
                return FALSE
        return TRUE
    }

    /*
        Adds an elliptical arc to the current figure of this path.
        Parameters:
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the bounding rectangle for the ellipse that contains the arc.
            Width / Height:
                Real number that specifies the width/height of the bounding rectangle for the ellipse that contains the arc.
            StartAngle:
                Real number that specifies the clockwise angle, in degrees, between the horizontal axis of the ellipse and the starting point of the arc.
            SweepAngle:
                Real number that specifies the clockwise angle, in degrees, between the starting point (startAngle) and the ending point of the arc.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    AddArc(X, Y, Width, Height, StartAngle, SweepAngle)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", this, "Float", X, "Float", Y, "Float", Width, "Float", Height, "Float", StartAngle, "Float", SweepAngle))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-addarc

    AddArcs(Rect, StartAngle, SweepAngle, Count := -1)
    {
        loop (Count<0 ? Rect.Length : Count)
            if (!this.AddArc(Rect.X[A_Index],Rect.Y[A_Index],Rect.W[A_Index],Rect.H[A_Index]
                ,IsObject(StartAngle)?StartAngle[A_Index]:StartAngle,IsObject(SweepAngle)?SweepAngle[A_Index]:SweepAngle))
                return FALSE
        return TRUE
    }

    /*
        Adds a line to the current figure of this path.
        Parameters:
            X1 / Y1:
                Real number that specifies the x/y-coordinate of the starting point of the line.
            X2 / Y2:
                Real number that specifies the x/y-coordinate of the ending point of the line.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    AddLine(X1, Y1, X2, Y2)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathLine", "Ptr", this, "Float", X1, "Float", Y1, "Float", X2, "Float", Y2))
    } ; https://msdn.microsoft.com/en-us/library/ms535603(v=VS.85).aspx

    /*
        Adds a sequence of connected lines to the current figure of this path.
        Parameters:
            Point:
                Specifies points that specify the starting and ending points of the lines.
                The first point in the array is the starting point of the first line, and the last point in the array is the ending point of the last line.
                Each of the other points serves as ending point for one line and starting point for the next line.
            Count:
                Integer that specifies the number of points in the «Point» parameter.
                This parameter can be omitted to use all points.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    AddLines(Point, Count := -1)
    {
        return Point is IPoint
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathLine2I", "Ptr", this, "Ptr", Point, "Int", Count<0?Point.Length:Count))  ; IPoint object.
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathLine2" , "Ptr", this, "Ptr", Point, "Int", Count<0?Point.Length:Count))  ; IPointF object.
    }  ; https://docs.microsoft.com/en-us/previous-versions//ms535600(v=vs.85)

    /*
        Adds a Bézier spline to the current figure of this path.
        Parameters:
            X1 / Y1:
                Real number that specifies the x/y-coordinate of the starting point of the Bézier spline.
            X2 / Y2:
                Real number that specifies the x/y-coordinate of the first control point of the Bézier spline.
            X3 / Y3:
                Real number that specifies the x/y-coordinate of the second control point of the Bézier spline.
            X4 / Y4:
                Real number that specifies the x/y-coordinate of the ending point of the Bézier spline.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    AddBezier(X1, Y1, X2, Y2, X3, Y3, X4, Y4)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathBezier", "Ptr", this, "Float", X1, "Float", Y1, "Float", X2, "Float", Y2, "Float", X3, "Float", Y3, "Float", X4, "Float", Y4))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-addbezier(inreal_inreal_inreal_inreal_inreal_inreal_inreal_inreal)

    /*
        Adds a sequence of connected Bézier splines to the current figure of this path.
        Parameters:
            Point:
                Specifies starting points, ending points, and control points for the connected splines.
                The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points.
                Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
            Count:
                Integer that specifies the number of points in the «Point» parameter.
                This parameter can be omitted to use all points.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    AddBeziers(Point, Count := -1)
    {
        return Point is IPoint
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathBeziersI", "Ptr", this, "Ptr", Point, "Int", Count<0?Point.Length:Count))  ; IPoint object.
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipAddPathBeziers" , "Ptr", this, "Ptr", Point, "Int", Count<0?Point.Length:Count))  ; IPointF object.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-addbeziers(inconstpoint_inint)
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a GraphicsPath object and initializes the fill mode.
    Parameters:
        FillMode:
            Specifies how areas are filled if the path intersects itself.
            This parameter must be a value from the FillMode Enumeration. The default value is FillModeAlternate.
    Return value:
        If the method succeeds, the return value is a GraphicsPath object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static GraphicsPath(FillMode := 0)
{
    local pGraphicsPath := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreatePath", "Int", FillMode, "UPtrP", pGraphicsPath)
    return Gdiplus.GraphicsPath.New(pGraphicsPath)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluspath/nf-gdipluspath-graphicspath-graphicspath(infillmode)
