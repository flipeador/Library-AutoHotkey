/*
    The Graphics class provides methods for drawing lines, curves, figures, images, and text.
    A Graphics object stores attributes of the display device and attributes of the items to be drawn.

    Graphics Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nl-gdiplusgraphics-graphics

    Graphics Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-graphics-flat
*/
class Graphics extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Image := 0  ; Image object associated with the Graphics object.


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
            DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-graphics-flat


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Creates a Graphics object that is associated with a specified device context and a specified device.
        Parameters:
            hDC:
                Handle to a device context that will be associated with the new Graphics object.
            hDevice:
                Handle to a device that will be associated with the new Graphics object.
                This parameter is optional and can be omitted.
        Return value:
            If the method succeeds, the return value is a Graphics object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            Make sure that the Graphics object is deleted or goes out of scope before the device context is released.
    */
    static FromDC(hDC, hDevice := "")
    {
        local pGraphics := 0
        Gdiplus.LastStatus := hDevice == ""
                            ? DllCall("Gdiplus.dll\GdipCreateFromHDC", "Ptr", hDC, "UPtrP", pGraphics)
                            : DllCall("Gdiplus.dll\GdipCreateFromHDC2", "Ptr", hDC, "Ptr", hDevice, "UPtrP", pGraphics)
        return Gdiplus.Graphics.New(pGraphics)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-graphics(inhdc_inhandle)

    /*
        Creates a Graphics object that is associated with a specified window.
        Parameters:
            hWnd:
                Handle to a window that will be associated with the new Graphics object.
            ICM:
                Specifies whether the new Graphics object applies color adjustment according to the ICC profile associated with the display device.
                TRUE     Specifies that color adjustment is applied.
                FALSE    Specifies that color adjustment is not applied. This is the default value.
        Return value:
            If the method succeeds, the return value is a Graphics object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromWindow(hWnd, ICM := FALSE)
    {
        local pGraphics := 0
        Gdiplus.LastStatus := ICM ? DllCall("Gdiplus.dll\GdipCreateFromHWNDICM", "Ptr", hWnd, "UPtrP", pGraphics)
                                  : DllCall("Gdiplus.dll\GdipCreateFromHWND", "Ptr", hWnd, "UPtrP", pGraphics)
        return Gdiplus.Graphics.New(pGraphics)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-graphics(inhwnd_inbool)


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Clears this Graphics object to a specified color.
        Parameters:
            Color:
                Specifies the ARGB color to paint the background. The default color is white 100% transparent.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clear(Color := 0x00FFFFFF)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGraphicsClear", "Ptr", this, "UInt", Color))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-clear

    /*
        Flushes all pending graphics operations.
        Parameters:
            Intention:
                Specifies whether pending operations are flushed immediately (not executed) or executed as soon as possible.
                This parameter must be a value of the FlushIntention Enumeration. The default value is FlushIntentionFlush.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Flush(Intention := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFlush", "Ptr", this, "Int", Intention))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-flush

    /*
        Gets a handle to the device context associated with this Graphics object.
        Return value:
            If the method succeeds, the return value is a handle to the device context associated with this Graphics object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            Each call to the GetHDC method should be paired with a call to the ReleaseDC method.
            Do not call any methods of the Graphics object between the calls to GetHDC and ReleaseDC.
            If you attempt to call a method of the Graphics object between GetHDC and ReleaseDC, the method will fail with ObjectBusy.
            ---------------------------------------------------------------------------------------
            Any state changes you make to the device context between GetHDC and ReleaseDC will be ignored by GDI+ and will not be reflected in rendering done by GDI+.
    */
    GetDC()
    {
        local hDC := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetDC", "Ptr", this, "UPtrP", hDC)
        return hDC
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-gethdc

    /*
        Releases a device context handle obtained by a previous call to the GetDC method of this Graphics object.
        Parameters:
            hDC:
                Handle to a device context obtained by a previous call to the GetDC method of this Graphics object.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    ReleaseDC(hDC)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipReleaseDC", "Ptr", this, "Ptr", hDC))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-releasehdc

    /*
        Uses a brush to fill the interior of a rectangle.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the rectangle.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle.
            Width / Height:
                Real number that specifies the width/height of the rectangle.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillRectangle(Brush, X, Y, Width, Height)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillRectangle", "Ptr", this, "Ptr", Brush, "Float", X, "Float", Y, "Float", Width, "Float", Height))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillrectangle(inconstbrush_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a sequence of rectangles.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the rectangles.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rectangles.
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillRectangles(Brush, Rects, Count := -1)
    {
        return (Rects is IRect)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillRectangles", "Ptr", this, "Ptr", Brush, "Ptr", Rects, "Int", Count<0?Rects.Length:Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillRectanglesI", "Ptr", this, "Ptr", Brush, "Ptr", Rects, "Int", Count<0?Rects.Length:Count))
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-graphics-flat

    /*
        Uses a brush to fill the interior of a rounded rectangle.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the rounded rectangle.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rounded rectangle.
            Width / Height:
                Real number that specifies the width/height of the rounded rectangle.
            Radius:
                Real number that specifies the radius of the rounded corners of the rounded rectangle.
                This parameter can be an array: [upper_left,upper_right,lower_right,lower_left].
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillRoundedRectangle(Brush, X, Y, Width, Height, Radius)
    {
        local Path  := Gdiplus.GraphicsPath()
        Radius := IsObject(Radius) ? Radius : [Radius,Radius,Radius,Radius]
        Path.AddArc(X+Width-2*Radius[2], Y                   , 2*Radius[2], 2*Radius[2], 270, 90)  ; Upper right rounded corner.  ┐
        Path.AddArc(X+Width-2*Radius[3], Y+Height-2*Radius[3], 2*Radius[3], 2*Radius[3], 0  , 90)  ; Lower right rounded corner.  ┘
        Path.AddArc(X                  , Y+Height-2*Radius[4], 2*Radius[4], 2*Radius[4], 90 , 90)  ; Lower left rounded corner.   └
        Path.AddArc(X                  , Y                   , 2*Radius[1], 2*Radius[1], 180, 90)  ; Upper left rounded corner.   ┌
        return this.FillPath(Brush, Path)
    } ; http://codewee.com/view.php?idx=60

    /*
        Uses a brush to fill the interior of a sequence of rounded rectangles.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the rounded rectangles.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rounded rectangles.
            Radius:
                Real number that specifies the radius of the rounded corners of the rounded rectangles.
                This parameter can be an array: [upper_left,upper_right,lower_right,lower_left].
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillRoundedRectangles(Brush, Rects, Radius, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.FillRoundRectangle(Brush,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index],Radius))
                return FALSE
        return TRUE
    }

    /*
        Uses a brush to fill the interior of an ellipse.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the ellipse.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the ellipse.
            Width / Height:
                Real number that specifies the width/height of the rectangle that bounds the ellipse.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillEllipse(Brush, X, Y, Width, Height)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillEllipse", "Ptr", this, "Ptr", Brush, "Float", X, "Float", Y, "Float", Width, "Float", Height))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillellipse(inconstbrush_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a sequence of ellipses.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the ellipses.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rectangles that bounds the ellipses.
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillEllipses(Brush, Rects, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.FillEllipse(Brush,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index]))
                return FALSE
        return TRUE
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillellipse(inconstbrush_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a circle that is specified by coordinates and a diameter.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the circle.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the circle.
            Diameter:
                Real number that specifies the diameter of the circle.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillCircle(Brush, X, Y, Diameter)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillEllipse", "Ptr", this, "Ptr", Brush, "Float", X, "Float", Y, "Float", Diameter, "Float", Diameter))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillellipse(inconstbrush_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a sequence of circles that are specified by coordinates and a diameter.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the circles.
            Points:
                An array of points that specifies the coordinates of the upper-left corner of the rectangles that bounds the circles.
            Diameter:
                Real number that specifies the diameter of the circles.
                This parameter can be an array: [diameter_circle1, diameter_circle2, ...].
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillCircles(Brush, Points, Diameter, Count := -1)
    {
        loop (Count<0 ? Points.Length : Count)
            if (!this.FillCircle(Brush,Points.X[A_Index],Points.Y[A_Index],IsObject(Diameter)?Diameter[A_Index]:Diameter))
                return FALSE
        return TRUE
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillellipse(inconstbrush_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a circle that is specified by center coordinates and a radius.
    */
    FillCircleR(Brush, X, Y, Radius)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillEllipse", "Ptr", this, "Ptr", Brush, "Float", X-Radius, "Float", Y-Radius, "Float", 2*Radius, "Float", 2*Radius))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillellipse(inconstbrush_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a polygon.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the polygon.
            Point:
                An array of points that make up the vertices of the polygon.
                The first two points specify the first side of the polygon.
                Each additional point specifies a new side, the vertices of which include the point and the previous point.
                If the last point and the first point do not coincide, they specify the last side of the polygon.
            Count:
                Integer that specifies the number elements in the points array.
                This parameter can be omitted to use all points.
            FillMode:
                Specifies how to fill a closed area that is within another closed area and that is created when the curve or path passes over itself.
                This parameter must be a value of the FillMode Enumeration. The default value is FillModeAlternate.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillPolygon(Brush, Point, Count := -1, FillMode := 0)
    {
        return !(Gdiplus.LastStatus := Point is IPoint
                                     ? DllCall("Gdiplus.dll\GdipFillPolygonI", "Ptr", this, "Ptr", Brush, "Ptr", Point, "Int", Count<0?Point.Length:Count, "Int", FillMode)
                                     : DllCall("Gdiplus.dll\GdipFillPolygon", "Ptr", this, "Ptr", Brush, "Ptr", Point, "Int", Count<0?Point.Length:Count, "Int", FillMode))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillpolygon

    /*
        Uses a brush to fill the interior of a pie.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the pie.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the ellipse.
                A curved portion of the ellipse is the arc of the pie.
            Width / Height:
                Real number that specifies the width/height of the rectangle that bounds the ellipse.
            StartAngle:
                Real number that specifies the angle, in degrees, between the x-axis and the starting point of the pie's arc.
            SweepAngle:
                Real number that specifies the angle, in degrees, between the starting and ending points of the pie's arc.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            A pie is a portion of the interior of an ellipse (it is bounded by an elliptical curve and two radial lines).
            The StartAngle and SweepAngle parameters specify the portion of the ellipse to be used.
    */
    FillPie(Brush, X, Y, Width, Height, StartAngle, SweepAngle)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillPie", "Ptr", this, "Ptr", Brush
            , "Float", X, "Float", Y, "Float", Width, "Float", Height, "Float", StartAngle, "Float", SweepAngle))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillpie(inconstbrush_inreal_inreal_inreal_inreal_inreal_inreal)

    /*
        Uses a brush to fill the interior of a sequence of pies.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the pies.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rectangle that bounds the ellipses.
            StartAngle:
                Real number that specifies the angle, in degrees, between the x-axis and the starting point of the pie's arc.
                This parameter can be an array: [start_angle_pie1,start_angle_pie2, ...].
            SweepAngle:
                Real number that specifies the angle, in degrees, between the starting and ending points of the pie's arc.
                This parameter can be an array: [sweep_angle_pie1,sweep_angle_pie2, ...].
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillPies(Brush, Rects, StartAngle, SweepAngle, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.FillPie(Brush,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index]
                ,IsObject(StartAngle)?StartAngle[A_Index]:StartAngle,IsObject(SweepAngle)?SweepAngle[A_Index]:SweepAngle))
                return FALSE
        return TRUE
    }

    /*
        Creates a closed cardinal spline from an array of points and uses a brush to fill, according to a specified mode, the interior of the spline.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the spline.
            Points:
                An array of points that this method uses to create a closed cardinal spline.
                Each point is a point on the spline.
            Count:
                Integer that specifies the number of elements in the points array.
                This parameter can be omitted to use all elements in the points array.
            Tension:
                Non negative real number that specifies how tightly the spline bends as it passes through the points.
                A value of 0 specifies that the spline is a sequence of straight lines.
                As the value increases, the curve becomes fuller. The default value is 0.5.
            FillMode:
                Specifies how to fill a closed area that is created when the curve passes over itself.
                This parameter must be a value of the FillMode Enumeration. The default value is FillModeAlternate.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillClosedCurve(Brush, Points, Count := -1, Tension := 0.5, FillMode := 0)
    {
        return (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillClosedCurve2I", "Ptr", this, "Ptr", Brush
                , "Ptr", Points, "Int", Count<0?Points.Length:Count, "Float", Tension, "Int", FillMode))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillClosedCurve2", "Ptr", this, "Ptr", Brush
                , "Ptr", Points, "Int", Count<0?Points.Length:Count, "Float", Tension, "Int", FillMode))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillclosedcurve(inconstbrush_inconstpointf_inint_infillmode_inreal)

    /*
        Uses a brush to fill the interior of a path.
        Parameters:
            Brush:
                A Brush object that is used to paint the interior of the path.
            Path:
                A GraphicsPath object that specifies the path.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If a figure in the path is not closed, this method treats the nonclosed figure as if it were closed by a straight line that connects the figure's starting and ending points.
    */
    FillPath(Brush, Path)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillPath", "Ptr", this, "Ptr", Brush, "Ptr", Path))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillpath

    /*
        Uses a brush to fill a specified region.
        Parameters:
            Brush:
                A Brush object that is used to paint the region.
            Region:
                A Region object to be filled.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    FillRegion(Brush, Region)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipFillRegion", "Ptr", this, "Ptr", Brush, "Ptr", Region))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-fillregion

    /*
        Uses a pen to draw a line that connects two points.
        Parameters:
            Pen:
                A Pen object that is used to draw the line.
            X1 / Y1:
                Real number that specifies the x/y-coordinate of the starting point of the line.
            X2 / Y2:
                Real number that specifies the x/y-coordinate of the ending point of the line.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawLine(Pen, X1, Y1, X2, Y2)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawLine", "Ptr", this, "Ptr", Pen, "Float", X1, "Float", Y1, "Float", X2, "Float", Y2))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536024(v=vs.85)?redirectedfrom=MSDN

    /*
        Uses a pen to draw a sequence of connected lines.
        Parameters:
            Pen:
                A Pen object that is used to draw the lines.
            Points:
                An array of points that specify the starting and ending points of the lines.
            Count:
                Integer that specifies the number of elements in the points array.
                This parameter can be omitted to use all elements in the points array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawLines(Pen, Points, Count := -1)
    {
        return (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawLinesI", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawLines", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536019(v=vs.85)

    /*
        Uses a pen to draw a rectangle.
        Parameters:
            Pen:
                A Pen object that is used to draw the rectangle.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle.
            Width / Height:
                Real number that specifies the width/height of the rectangle.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawRectangle(Pen, X, Y, Width, Height)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawRectangle", "Ptr", this, "Ptr", Pen, "Float", X, "Float", Y, "Float", Width, "Float", Height))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawrectangle(inconstpen_inreal_inreal_inreal_inreal)

    /*
        Uses a pen to draw a sequence of rectangles.
        Parameters:
            Pen:
                A Pen object that is used to draw the rectangles.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rectangles.
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawRectangles(Pen, Rects, Count := -1)
    {
        return (Rects is IRect)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawRectanglesI", "Ptr", this, "Ptr", Pen, "Ptr", Rects, "Int", Count<0?Rects.Length:Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawRectangles", "Ptr", this, "Ptr", Pen, "Ptr", Rects, "Int", Count<0?Rects.Length:Count))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535998(v=vs.85)

    /*
        Uses a pen to draw a rounded rectangle.
        Parameters:
            Pen:
                A Pen object that is used to draw the rounded rectangle.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rounded rectangle.
            Width / Height:
                Real number that specifies the width/height of the rounded rectangle.
            Radius:
                Real number that specifies the radius of the rounded corners of the rounded rectangle.
                This parameter can be an array: [upper_left,upper_right,lower_right,lower_left].
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawRoundedRectangle(Pen, X, Y, Width, Height, Radius)
    {
        local Path  := Gdiplus.GraphicsPath()
        Radius := IsObject(Radius) ? Radius : [Radius,Radius,Radius,Radius]
        Path.AddArc(X+Width-2*Radius[2], Y                   , 2*Radius[2], 2*Radius[2], 270, 90)  ; Upper right rounded corner.  ┐
        Path.AddArc(X+Width-2*Radius[3], Y+Height-2*Radius[3], 2*Radius[3], 2*Radius[3], 0  , 90)  ; Lower right rounded corner.  ┘
        Path.AddArc(X                  , Y+Height-2*Radius[4], 2*Radius[4], 2*Radius[4], 90 , 90)  ; Lower left rounded corner.   └
        Path.AddArc(X                  , Y                   , 2*Radius[1], 2*Radius[1], 180, 90)  ; Upper left rounded corner.   ┌
        return this.DrawPath(Pen, Path)
    } ; http://codewee.com/view.php?idx=60

    /*
        Uses a pen to draw a sequence of rounded rectangles.
        Parameters:
            Pen:
                A Pen object that is used to draw the rounded rectangles.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rounded rectangles.
            Radius:
                Real number that specifies the radius of the rounded corners of the rounded rectangles.
                This parameter can be an array: [upper_left,upper_right,lower_right,lower_left].
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawRoundedRectangles(Pen, Rects, Radius, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.DrawRoundRectangle(Pen,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index],Radius))
                return FALSE
        return TRUE
    }

    /*
        Uses a pen to draw an arc that is part of an ellipse.
        Parameters:
            Pen:
                A Pen object that is used to draw the arc.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the bounding rectangle for the ellipse that contains the arc.
            Width / Height:
                Real number that specifies the width/height of the bounding rectangle for the ellipse that contains the arc.
            StartAngle:
                Real number that specifies the angle between the x-axis and the starting point of the arc.
            SweepAngle:
                Real number that specifies the angle between the starting and ending points of the arc.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawArc(Pen, X, Y, Width, Height, StartAngle, SweepAngle)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawArc", "Ptr", this, "Ptr", Pen
            , "Float", X, "Float", Y, "Float", Width, "Float", Height, "Float", StartAngle, "Float", SweepAngle))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536154(v=vs.85)

    /*
        Uses a pen to draw a sequence of arcs.
        Parameters:
            Pen:
                A Pen object that is used to draw the sequence of arcs.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the bounding rectangle for the ellipse that contains the arcs.
            StartAngle:
                Real number that specifies the angle between the x-axis and the starting point of the arc.
                This parameter can be an array: [start_angle_rect1, start_angle_rect2, ...].
            SweepAngle:
                Real number that specifies the angle between the starting and ending points of the arc.
                This parameter can be an array: [sweep_angle_arc1, sweep_angle_arc2, ...].
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawArcs(Pen, Rects, StartAngle, SweepAngle, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.DrawArcs(Pen,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index]
                ,IsObject(StartAngle)?StartAngle[A_Index]:StartAngle,IsObject(SweepAngle)?SweepAngle[A_Index]:SweepAngle))
                return FALSE
        return TRUE
    }

    /*
        Uses a pen to draw an ellipse.
        Parameters:
            Pen:
                A Pen object that is used to draw the ellipse.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the ellipse.
            Width / Height:
                Real number that specifies the width/height of the rectangle that bounds the ellipse.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawEllipse(Pen, X, Y, Width, Height)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawEllipse", "Ptr", this, "Ptr", Pen, "Float", X, "Float", Y, "Float", Width, "Float", Height))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawellipse(inconstpen_inreal_inreal_inreal_inreal)

    /*
        Uses a pen to draw a sequence of ellipses.
        Parameters:
            Pen:
                A Pen object that is used to draw the sequence of ellipses.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rectangles that bounds the ellipses.
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawEllipses(Pen, Rects, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.DrawEllipse(Pen,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index]))
                return FALSE
        return TRUE
    } ; https://msdn.microsoft.com/en-us/library/ms536064(v=VS.85).aspx

    /*
        Uses a pen to draw a circle that is specified by coordinates and a diameter.
        Parameters:
            Pen:
                A Pen object that is used to draw the circle.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the circle.
            Diameter:
                Real number that specifies the diameter of the circle.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawCircle(Pen, X, Y, Diameter)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawEllipse", "Ptr", this, "Ptr", Pen, "Float", X, "Float", Y, "Float", Diameter, "Float", Diameter))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawellipse(inconstpen_inreal_inreal_inreal_inreal)

    /*
        Uses a pen to draw a sequence of circles that are specified by coordinates and a diameter.
        Parameters:
            Pen:
                A Pen object that is used to draw the circles.
            Points:
                An array of points that specifies the coordinates of the upper-left corner of the rectangles that bounds the circles.
            Diameter:
                Real number that specifies the diameter of the circles.
                This parameter can be an array: [diameter_circle1, diameter_circle2, ...].
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawCircles(Pen, Points, Diameter, Count := -1)
    {
        loop (Count<0 ? Points.Length : Count)
            if (!this.DrawCircle(Pen,Points.X[A_Index],Points.Y[A_Index],IsObject(Diameter)?Diameter[A_Index]:Diameter))
                return FALSE
        return TRUE
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawellipse(inconstpen_inreal_inreal_inreal_inreal)

    /*
        Uses a pen to draw a circle that is specified by center coordinates and a radius.
    */
    DrawCircleR(Pen, X, Y, Radius)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawEllipse", "Ptr", this, "Ptr", Pen, "Float", X-Radius, "Float", Y-Radius, "Float", 2*Radius, "Float", 2*Radius))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawellipse(inconstpen_inreal_inreal_inreal_inreal)

    /*
        Uses a pen to draw a polygon.
        Parameters:
            Pen:
                A Pen object that is used to draw the polygon.
            Points:
                An array of points that specify the vertices of the polygon.
            Count:
                Integer that specifies the number of elements in the points array.
                This parameter can be omitted to use all elements in the points array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If the first and last coordinates in the points array are not identical, a line is drawn between them to close the polygon.
    */
    DrawPolygon(Pen, Points, Count := -1)
    {
        return (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawPolygonI", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawPolygon", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536009(v=vs.85)

    /*
        Uses a pen to draw a pie.
        Parameters:
            Pen:
                A Pen object that is used to draw the pie.
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that bounds the ellipse.
            Width / Height:
                Real number that specifies the width/height of the rectangle that bounds the ellipse.
            StartAngle:
                Real number that specifies the angle, in degrees, between the x-axis and the starting point of the arc that defines the pie.
                A positive value specifies clockwise rotation.
            SweepAngle:
                Real number that specifies the angle, in degrees, between the starting and ending points of the arc that defines the pie.
                A positive value specifies clockwise rotation.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawPie(Pen, X, Y, Width, Height, StartAngle, SweepAngle)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawPie", "Ptr", this, "Ptr", Pen
            , "Float", X, "Float", Y, "Float", Width, "Float", Height, "Float", StartAngle, "Float", SweepAngle))
    } ; https://msdn.microsoft.com/en-us/library/ms536014(v=VS.85).aspx

    /*
        Uses a pen to draw a sequence of pies.
        Parameters:
            Pen:
                A Pen object that is used to draw the pies.
            Rects:
                An array of rectangles that specify the coordinates and dimensions of the rectangle that bounds the ellipses.
            StartAngle:
                Real number that specifies the angle, in degrees, between the x-axis and the starting point of the pie's arc.
                This parameter can be an array: [start_angle_pie1,start_angle_pie2, ...].
            SweepAngle:
                Real number that specifies the angle, in degrees, between the starting and ending points of the pie's arc.
                This parameter can be an array: [sweep_angle_pie1,sweep_angle_pie2, ...].
            Count:
                Integer that specifies the number of elements in the rectangles array.
                This parameter can be omitted to use all elements in the rectangles array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawPies(Pen, Rects, StartAngle, SweepAngle, Count := -1)
    {
        loop (Count<0 ? Rects.Length : Count)
            if (!this.DrawPie(Pen,Rects.X[A_Index],Rects.Y[A_Index],Rects.W[A_Index],Rects.H[A_Index]
                ,IsObject(StartAngle)?StartAngle[A_Index]:StartAngle,IsObject(SweepAngle)?SweepAngle[A_Index]:SweepAngle))
                return FALSE
        return TRUE
    }

    DrawCurve(Pen, Points, Count := -1, Tension := 0.5, Offset := "", NumberOfSegments := "")
    {
        return (Offset == "" || NumberOfSegments == "")
             ? (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawCurve2I", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count, "Float", Tension))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawCurve2", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count, "Float", Tension))
             : (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawCurve3I", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count, "Int", Offset, "Int", NumberOfSegments, "Float", Tension))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawCurve3", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count, "Int", Offset, "Int", NumberOfSegments, "Float", Tension))
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-graphics-flat

    /*
        Uses a pen to draw a closed cardinal spline.
        Parameters:
            Pen:
                A Pen object that is used to draw the closed cardinal spline.
            Points:
                An array of points that specify the coordinates of the closed cardinal spline.
                The array of points must contain a minimum of three elements.
            Count:
                Integer that specifies the number of elements in the points array.
                This parameter can be omitted to use all elements in the points array.
            Tension:
                Real number that specifies how tightly the curve bends through the coordinates of the closed cardinal spline.
                The default value is 0.5.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawClosedCurve(Pen, Points, Count := -1, Tension := 0.5)
    {
        return (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawClosedCurve2I", "Ptr", this, "Ptr", Pen
                , "Ptr", Points, "Int", Count<0?Points.Length:Count, "Float", Tension))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawClosedCurve2", "Ptr", this, "Ptr", Pen
                , "Ptr", Points, "Int", Count<0?Points.Length:Count, "Float", Tension))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawclosedcurve(inconstpen_inconstpointf_inint_inreal)

    /*
        Uses a pen to draw a Bézier spline.
        Parameters:
            Pen:
                A Pen object that is used to draw the Bézier spline.
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
        Remarks:
            A Bézier spline does not pass through its control points.
            The control points act as magnets, pulling the curve in certain directions to influence the way the Bézier spline bends.
    */
    DrawBezier(Pen, X1, Y1, X2, Y2, X3, Y3, X4, Y4)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawBezier", "Ptr", this, "Ptr", Pen
            , "Float", X1, "Float", Y1, "Float", X2, "Float", Y2, "Float", X3, "Float", Y3, "Float", X4, "Float", Y4))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536150(v=vs.85)

    /*
        Uses a pen to draw a sequence of connected Bézier splines.
        Parameters:
            Pen:
                A Pen object that is used to draw the Bézier splines.
            Points:
                An array of points that specify the starting, ending, and control points of the Bézier splines.
            Count:
                Integer that specifies the number of elements in the points array.
                This parameter can be omitted to use all elements in the points array.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawBeziers(Pen, Points, Count := -1)
    {
        return (Points is IPoint)
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawBeziersI", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawBeziers", "Ptr", this, "Ptr", Pen, "Ptr", Points, "Int", Count<0?Points.Length:Count))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536147(v=vs.85)

    /*
        Uses a pen to draw a sequence of lines and curves defined by a GraphicsPath object.
        Parameters:
            Pen:
                A Pen object that is used to draw the path.
            Path:
                A GraphicsPath object that specifies the sequence of lines and curves that make up the path.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawPath(Pen, GraphicsPath)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawPath", "Ptr", this, "Ptr", Pen, "Ptr", GraphicsPath))
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Gdiplusgraphics/nf-gdiplusgraphics-graphics-drawpath

    /*
        Measures the extent of the string in the specified font, format, and layout rectangle.
        Parameters:
            String:
                A string to be measured.
                For bidirectional languages, such as Arabic, the string length must not exceed 2046 characters.
            Rect:
                The rectangle that bounds the string.
            Font:
                A Font object that specifies the family name, size, and style of the font to be applied to the string.
            StringFormat:
                A StringFormat object that specifies the layout information, such as alignment, trimming, tab stops, and so forth.
                This parameter is optional and can be zero or omitted.
        Return value:
            If the method succeeds, the return value is an object with the following properties:
                Rect                A rectangle (float) that receives the rectangle that bounds the string.
                CodePointsFitted    The number of characters that actually fit into the layout rectangle.
                LinesFilled         The number of lines that fit into the layout rectangle.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    MeasureString(String, Rect, Font, StringFormat := 0)
    {
        local OutRect := RectF(), CodePointsFitted := 0, LinesFilled := 0
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipMeasureString", "Ptr", this, "Ptr", &String, "Int", -1
            , "Ptr", Font, "Ptr", ToRectF(Rect), "Ptr", StringFormat, "Ptr", OutRect, "IntP", CodePointsFitted, "IntP", LinesFilled))
             ? 0                                                                           ; Error.
             : {Rect:OutRect, CodePointsFitted:CodePointsFitted, LinesFilled:LinesFilled}  ; Ok.
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535831(v=vs.85)

    /*
        Gets a set of regions each of which bounds a range of character positions within a string.
        Parameters:
            String:
                A string.
            Rect:
                A rectangle that bounds the string.
            Font:
                A Font object that specifies the font characteristics (the family name, size, and style of the font) to be applied to the string.
            StringFormat:
                A StringFormat object that specifies the character ranges and layout information, such as alignment, trimming, tab stops, and so forth.
        Return value:
            If the method succeeds, the return value is an array of Region objects.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            A character range is a range of character positions within a string of text.
            The area of the display that is occupied by a group of characters that are specified by the character range, is the bounding region.
            A character range is set by the Gdiplus::StringFormat::SetMeasurableCharacterRanges method.
            The number of ranges that are currently set can be determined by querying the Gdiplus::StringFormat::MeasurableCharacterRangeCount property.
            - This number is also the number of regions expected to be obtained by the Gdiplus::Graphics::MeasureCharacterRanges method.
    */
    MeasureCharacterRanges(String, Rect, Font, StringFormat)
    {
        local Buffer := BufferAlloc(StringFormat.MeasurableCharacterRangeCount*A_PtrSize)  ; Region objects.
        local MCRCount := Buffer.Size//A_PtrSize, Regions := []  ; Array of Region objects.
        loop (MCRCount)  ; Gdiplus::StringFormat::MeasurableCharacterRangeCount.
            Regions.Push(Gdiplus.Region())  ; Creates a Region object and adds it to the array.
           ,NumPut("UPtr", Regions[A_Index].Ptr, Buffer, (A_Index-1)*A_PtrSize)  ; Adds the region to the buffer (pointer).
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipMeasureString", "Ptr", this, "Ptr", &String, "Int", -1
            , "Ptr", Font, "Ptr", ToRectF(Rect), "Ptr", StringFormat, "Int", MCRCount, "Ptr", Buffer))
             ? 0        ; Error. Created regions are automatically deleted by the destructor of class Gdiplus::Region.
             : Regions  ; Ok. Returns the ahk-array containing all Region objects.
    }

    /*
        Draws a string based on a font, a layout rectangle, and a format.
        Parameters:
            Brush:
                A Brush object that is used to fill the string.
            String:
                A string to be drawn.
            Rect:
                A rectangle that bounds the string.
            Font:
                A Font object that specifies the font attributes (the family name, the size, and the style of the font) to use.
            StringFormat:
                A StringFormat object that specifies text layout information and display manipulations to be applied to the string.
                This parameter is optional and can be zero or omitted.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            GDI+ does not support PostScript fonts or OpenType fonts which do not have TrueType outlines.
            ----------------------------------------------------------------------------------------------------
            You must not allow your application to download arbitrary fonts from untrusted sources.
            The operating system requires elevated privileges to assure that all installed fonts are trusted.
    */
    DrawString(Brush, String, Rect, Font, StringFormat := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawString", "Ptr", this, "Ptr", &String
            , "Int", -1, "Ptr", Font, "Ptr", ToRectF(Rect), "Ptr", StringFormat, "Ptr", Brush))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535991(v=vs.85)

    /*
        Draws the specified text on this Graphics object using the DrawString method.
        Parameters:
            Text:
                A string containing the text to be drawn.
            Options:
                Zero or more options. Each option is either a single letter immediately followed by a value, or a single word.
                ----------------------------------------- General Options ------------------------------------------
                cN           Specifies the text color. Can be a hex ARGB color value, or the memory address of a Brush object ("c&<ptr>").
                xN / yN      Specifies the x/y-coordinate of the upper-left corner of the text box. By default they are set to zero.
                wN / hN      Specifies the width/height of the text box. If one or both are omitted, parameters Width and Height are used instead.
                -------------------------------------- String Format Options ---------------------------------------
                NoWrap       Specifies that the wrapping of text to the next line is disabled.
                Right        Specifies that the text is aligned to the right side of the formatting rectangle. The Center option is ignored.
                Bottom       Specifies that the text is aligned to the bottom side of the formatting rectangle. The VCenter option is ignored.
                Center       Specifies that the text is horizontally centered between the formatting rectangle. Ignored if Right option is present.
                VCenter      Specifies that the text is vertically centered between the formatting rectangle. Ignored if Bottom option is present.
                --------------------------------------- Font Related Options ---------------------------------------
                sN           The em size of the font measured in the specified units.
                uN           The unit of measurement for the font size. The default value is 3 (UnitPoint).
                Bold         Specifies bold typeface. Bold is a heavier weight or thickness.
                Italic       Specifies italic typeface, which produces a noticeable slant to the vertical stems of the characters.
                Underline    Specifies underline, which displays a line underneath the baseline of the characters.
                Strike       Specifies strikeout, which displays a horizontal line drawn through the middle of the characters.
                -------------------------------------- Return Related Options --------------------------------------
                NoDraw       Return without drawing the text on this Graphics object. The Measure option is ignored.
                Measure      If not specified, the Measure property of the returned object is set to zero. Ignored if NoDraw option is present.
            Font:
                A Font object that specifies the font attributes (the family name, the size, and the style of the font) to use.
                This parameter can be a string with the name of a font family.
            Width / Height:
                Specifies a width and a height. These are used as follows:
                - These are used in place of options wN and hN if one or both are omitted. The default value of both parameters is zero.
                - If option xN has a "p" at the end, the following formula applies: Width*(xN/100).
                - If option yN has a "p" at the end, the following formula applies: Height*(yN/100).
                - If option wN has a "p" at the end, the following formula applies: Width*(wN/100).
                - If option hN has a "p" at the end, the following formula applies: Height*(hN/100).
            StringFormat:
                A StringFormat object that specifies text layout information and display manipulations to be applied to the string.
                This parameter is optional and can be zero or omitted.
            FontCollection:
                A FontCollection object that specifies the collection that the font family belongs to.
                If this parameter is zero, this font family is not part of a collection.
                This parameter is ignored if the «Font» parameter specifies a FontFamily object.
        Return value:
            If the method succeeds, the return value is an object with properties Brush, Rect, Font, StringFormat and Measure.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            This method is a wrapper of the DrawString method for ease of use. All needed objects are automatically created, and returned.
            This method does not check for certain errors, you must use Try to handle these errors.
    */
    DrawText(Text, Options, Font, Width := 0, Height := 0, StringFormat := 0, FontCollection := 0)
    {
        local t, X := 0, Y := 0, W := 0, H := 0, Brush := 0, Size := 0, Rect, Measure, Pos
        Brush:=RegExMatch(Options,"i)\bc(&\d+|[\da-f]+)\b",t) ? (t[1]~="&"?Object(SubStr(t[1],2)):Gdiplus.SolidBrush("0x" . t[1])) : Gdiplus.SolidBrush(),Font:=IsObject(Font)
        ?Font:Gdiplus.Font(Font,RegExMatch(Options,"i)\bs(\d+)(p*)\b",Size)&&Size[1]>0?Size[2]!=""?Height*(Size[1]/100):Size[1]:9,!!InStr(Options,"Bold")|(InStr(Options,"Italic")
        &&2)|(InStr(Options,"Underline")&&4)|(InStr(Options,"Strike")&&8),RegExMatch(Options,"i)\bu([\d]+)\b",t)?t[1]:3,FontCollection),Pos:=IsObject(StringFormat)?StringFormat
        :(!!(StringFormat:=Gdiplus.StringFormat(RegExMatch(Options,"i)(-|No)Wrap")?0x5000:0x4000))) . (StringFormat.Alignment:=InStr(Options,"Right")&&2||!!RegExMatch(Options
        ,"i)\bCenter")) . (StringFormat.LineAlignment:=InStr(Options,"Bottom")&&2||!!InStr(Options,"VCenter")),Rect:=RectF(RegExMatch(Options,"i)\bx(-?\d+)(p*)\b",X)?X[2]!=""
        ?Width*(X[1]/100):X[1]:0,RegExMatch(Options,"i)\by(-?\d+)(p*)\b",Y)?Y[2]!=""?Height*(Y[1]/100):Y[1]:0,RegExMatch(Options,"i)\bw(-?\d+)(p*)\b",W)?W[2]!=""?Width*(W[1]/100)
        :W[1]:Width,RegExMatch(Options,"i)\bh(-?\d+)(p*)\b",H)?H[2]!=""?Height*(H[1]/100):H[1]:Height)
        return InStr(Options,"NoDraw")?{StringFormat:StringFormat,Measure:this.MeasureString(Text,Rect,Font,StringFormat),Font:Font,Rect:Rect,Brush:Brush}
        :this.DrawString(Brush,Text,Rect,Font,StringFormat)&&{StringFormat:StringFormat,Measure:InStr(Options,"Measure")
        ?this.MeasureString(Text,Rect,Font,StringFormat):0, Font: Font, Rect: Rect, Brush: Brush}
    }

    /*
        Draws the image stored in a CachedBitmap object.
        Parameters:
            CachedBitmap:
                A CachedBitmap object that contains the image to be drawn.
            X / Y:
                Integer that specifies the x/y-coordinate of the upper-left corner of the image.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            You cannot draw a cached bitmap to a printer or to a metafile.
            ---------------------------------------------------------------------------------------
            Cached bitmaps will not work with any transformations other than translation.
            ---------------------------------------------------------------------------------------
            If the screen associated with that Graphics object has its bit depth changed after the cached bitmap is constructed,
            - then the DrawCachedBitmap method will fail, and you should reconstruct the cached bitmap.
            Alternatively, you can hook the display change notification message and reconstruct the cached bitmap at that time.
    */
    DrawCachedBitmap(CachedBitmap, X, Y)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawCachedBitmap", "Ptr", this, "Ptr", CachedBitmap, "Float", X, "Float", Y))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawcachedbitmap

    /*
        Draws a portion of an image at a specified location on this Graphics object.
        Parameters:
            Image:
                An Image object that specifies the source image to be drawn.
            XDest / YDest:
                Real number that specifies the x/y-coordinate of the upper-left corner of the destination position at which to draw the image.
            WDest / HDest:
                Real number that specifies the width/height of the destination rectangle at which to draw the image.
            XSrc / YSrc:
                Real number that specifies the x/y-coordinate of the upper-left corner of the portion of the source image to be drawn.
            WSrc / HSrc:
                Real number that specifies the width/height of the portion of the source image to be drawn.
            ImageAttributes:
                An ImageAttributes object that specifies the color and size attributes of the image to be drawn.
                This parameter is optional and can be zero or omitted.
            Unit:
                Specifies the unit of measure for the image.
                This parameter must be a value of the Unit Enumeration. The default value is UnitPixel.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawImage(Image, XDest := 0, YDest := 0, WDest := "", HDest := "", XSrc := 0, YSrc := 0, WSrc := "", HSrc := "", ImageAttributes := 0, Unit := 2)
    {
        local SrcW := 0, SrcH := 0
        DllCall("Gdiplus.dll\GdipGetImageDimension", "Ptr", Image, "FloatP", SrcW, "FloatP", SrcH)
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawImageRectRect", "Ptr", this, "Ptr", Image
                , "Float", XDest, "Float", YDest, "Float", WDest==""?this.Image.Width:WDest, "Float", HDest==""?this.Image.Height:HDest
                , "Float", XSrc, "Float", YSrc, "Float", WSrc==""?SrcW:WSrc , "Float", HSrc==""?SrcH:HSrc
                , "Int", Unit, "Ptr", ImageAttributes, "Ptr", 0, "Ptr", 0))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawimage(inimage_inconstpointf_inint_inreal_inreal_inreal_inreal_inunit_inconstimageattributes_indrawimageabort_invoid)

    /*
        Same as the DrawImage method but using a IPoint(F)/ISize(F)/IRect(F) object in Dest and Src.
    */
    DrawImage2(Image, Dest := 0, Src := 0, ImageAttributes := 0, Unit := 2)
    {
        if (Dest is IPointBase)
            return (Src is IPointBase)
                 ? this.DrawImage(Image, Dest.X, Dest.Y,,, Src.X, Src.Y,,, ImageAttributes, Unit)
                 : (Src is ISizeBase)
                 ? this.DrawImage(Image, Dest.X, Dest.Y,,,,, Src.W, Src.H, ImageAttributes, Unit)
                 : (Src is IRectBase)
                 ? this.DrawImage(Image, Dest.X, Dest.Y,,, Src.X, Src.Y, Src.W, Src.H, ImageAttributes, Unit)
                 : this.DrawImage(Image, Dest.X, Dest.Y,,,,,,, ImageAttributes, Unit)
        if (Dest is ISizeBase)
            return (Src is IPointBase)
                 ? this.DrawImage(Image,,, Dest.W, Dest.H, Src.X, Src.Y,,, ImageAttributes, Unit)
                 : (Src is ISizeBase)
                 ? this.DrawImage(Image,,, Dest.W, Dest.H,,, Src.W, Src.H, ImageAttributes, Unit)
                 : (Src is IRectBase)
                 ? this.DrawImage(Image,,, Dest.W, Dest.H, Src.X, Src.Y, Src.W, Src.H, ImageAttributes, Unit)
                 : this.DrawImage(Image,,, Dest.W, Dest.H,,,,, ImageAttributes, Unit)
        if (Dest is IRectBase)
            return (Src is IPointBase)
                 ? this.DrawImage(Image, Dest.X, Dest.Y, Dest.W, Dest.H, Src.X, Src.Y,,, ImageAttributes, Unit)
                 : (Src is ISizeBase)
                 ? this.DrawImage(Image, Dest.X, Dest.Y, Dest.W, Dest.H,,, Src.W, Src.H, ImageAttributes, Unit)
                 : (Src is IRectBase)
                 ? this.DrawImage(Image, Dest.X, Dest.Y, Dest.W, Dest.H, Src.X, Src.Y, Src.W, Src.H, ImageAttributes, Unit)
                 : this.DrawImage(Image, Dest.X, Dest.Y, Dest.W, Dest.H,,,,, ImageAttributes, Unit)
        return (Src is IPointBase)
             ? this.DrawImage(Image,,,,, Src.X, Src.Y,,, ImageAttributes, Unit)
             : (Src is ISizeBase)
             ? this.DrawImage(Image,,,,,,, Src.W, Src.H, ImageAttributes, Unit)
             : (Src is IRectBase)
             ? this.DrawImage(Image,,,,, Src.X, Src.Y, Src.W, Src.H, ImageAttributes, Unit)
             : this.DrawImage(Image,,,,,,,,, ImageAttributes, Unit)
    }

    /*
        Draws a portion of an image at a specified area, in a parallelogram, on this Graphics object.
        Parameters:
            Image:
                An Image object that specifies the source image to be drawn.
            Points:
                An array of points that specify the area, in a parallelogram, in which to draw the image.
            XSrc / YSrc:
                Real number that specifies the x/y-coordinate of the upper-left corner of the portion of the source image to be drawn.
            WSrc / HSrc:
                Real number that specifies the width/height of the portion of the source image to be drawn.
            Count:
                Integer that specifies the number of elements in the points array.
                This parameter can be omitted to use all elements in the points array.
            ImageAttributes:
                An ImageAttributes object that specifies the color and size attributes of the image to be drawn.
                This parameter is optional and can be zero or omitted.
            Unit:
                Specifies the unit of measure for the image.
                This parameter must be a value of the Unit Enumeration. The default value is UnitPixel.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawImagePoints(Image, Points, XSrc, YSrc, WSrc, HSrc, Count := -1, ImageAttributes := 0, Unit := 2)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawImagePointsRect", "Ptr", this, "Ptr", Image
            , "Ptr", ToPointF(Points), "Int", Count<0?Points.Length:Count, "Float", XSrc, "Float", YSrc
            , "Float", WSrc, "Float", HSrc, "Int", Unit, "Ptr", ImageAttributes, "Ptr", 0, "Ptr", 0))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawimage(inimage_inconstpointf_inint_inreal_inreal_inreal_inreal_inunit_inconstimageattributes_indrawimageabort_invoid)

    /*
        Draws a portion of an image after applying a specified effect.
        Parameters:
            Image:
                An Image object that specifies the source image to be drawn.
            Effect:
                A Effect object that specifies an effect or adjustment that is applied to the image before rendering.
                The image is not permanently altered by the effect.
            Rect:
                A rectangle that specifies the portion of the image to be drawn.
                This parameter is optional and can be omitted, in which case the bounding rectangle of the image is used.
            Matrix:
                A Matrix object that specifies the parallelogram in which the image portion is rendered.
                The destination parallelogram is calculated by applying the affine transformation stored in the matrix to the source rectangle.
                This parameter is optional and can be zero or omitted.
            ImageAttributes:
                An ImageAttributes object that specifies color adjustments to be applied when the image is rendered.
                This parameter is optional and can be zero or omitted.
            Unit:
                Specifies the unit of measure for the source rectangle.
                This parameter must be a value of the Unit Enumeration. The default value is UnitPixel.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    DrawImageFX(Image, Effect, Rect := 0, Matrix := 0, ImageAttributes := 0, Unit := 2)    ; RectF = Gdiplus.RectF  |  Matrix = Gdiplus.Matrix  |  Effect = Gdiplus.Effect
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipDrawImageFX", "Ptr", this, "Ptr", Image
            , "Ptr", Rect?ToRectF(Rect):Image.Bounds, "Ptr", Matrix, "Ptr", Effect, "Ptr", ImageAttributes, "Int", Unit))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-drawimage(inimage_inrectf_inmatrix_ineffect_inimageattributes_inunit)

    /*
        Updates the clipping region of this Graphics object to a region that is the combination of itself and a rectangle.
        Parameters:
            Rect:
                A rectangle to be combined with the clipping region of this Graphics object.
            CombineMode:
                Specifies how the specified rectangle is combined with the clipping region of this Graphics object.
                This parameter must be a value of the CombineMode Enumeration. The default value is CombineModeReplace.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetClipRect(Rect, CombineMode := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetClipRect", "Ptr", this, "Float", Rect.X, "Float", Rect.Y, "Float", Rect.W, "Float", Rect.H, "Int", CombineMode))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setclip(inconstrect__incombinemode)

    /*
        Updates the clipping region of this Graphics object to a region that is the combination of itself and the region specified by a graphics path.
        If a figure in the path is not closed, this method treats the nonclosed figure as if it were closed by a straight line that connects the figure's starting and ending points.
        Parameters:
            Path:
                A GraphicsPath object that specifies the region to be combined with the clipping region of this Graphics object.
            CombineMode:
                Specifies how the specified region is combined with the clipping region of this Graphics object.
                This parameter must be a value of the CombineMode Enumeration. The default value is CombineModeReplace.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetClipPath(Path, CombineMode := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetClipPath", "Ptr", this, "Ptr", Path, "Int", CombineMode))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setclip(inconstgraphicspath_incombinemode)

    /*
        Updates the clipping region of this Graphics object to a region that is the combination of itself and the region specified by a Region object.
        Parameters:
            Region:
                A Region object that specifies the region to be combined with the clipping region of this Graphics object.
            CombineMode:
                Specifies how the specified region is combined with the clipping region of this Graphics object.
                This parameter must be a value of the CombineMode Enumeration. The default value is CombineModeReplace.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetClipRegion(Region, CombineMode := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetClipRegion", "Ptr", this, "Ptr", Region, "Int", CombineMode))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setclip(inconstregion_incombinemode)

    /*
        Sets the clipping region of this Graphics object to an infinite region.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If the clipping region of a Graphics object is infinite, then items drawn by that Graphics object will not be clipped.
    */
    ResetClip()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipResetClip", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-resetclip

    /*
        Translates the clipping region of this Graphics object.
        Parameters:
            X / Y:
                Real number that specifies the horizontal/vertical component of the translation.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    TranslateClip(X, Y)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipTranslateClip", "Ptr", this, "Float", X, "Float", Y))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535822(v=vs.85)

    /*
        Gets the clipping region of this Graphics object.
        Parameters:
            Region:
                A Region object that receives the clipping region.
                This parameter is optional and can be omitted.
        Return value:
            If the method succeeds, the return value is a Region object that receives the clipping region.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetClip(Region := 0)
    {
        Region := Region ? Region : Gdiplus.Region()
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetClip", "Ptr", this, "Ptr", Region))
             ? 0       ; Error.
             : Region  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getclip

    /*
        Determines whether the clipping region of this Graphics object is empty.
        Return value:
            If the clipping region of this Graphics object is empty, this method returns TRUE; otherwise, it returns FALSE.
        Remarks:
            If the clipping region is empty, there is no area left in which to draw. Consequently, nothing will be drawn when the clipping region is empty.
    */
    IsClipEmpty()
    {
        local IsClipEmpty := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipIsClipEmpty", "Ptr", this, "IntP", IsClipEmpty)
        return IsClipEmpty
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-isclipempty

    /*
        Gets a rectangle that encloses the clipping region of this Graphics object.
        Return value:
            If the method succeeds, the return value is a IRectF object that receives the rectangle that encloses the clipping region.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            The world transformation is applied to the clipping region and then the enclosing rectangle is calculated.
            ----------------------------------------------------------------------------------------------------
            If you do not explicitly set the clipping region of a Graphics object, its clipping region is infinite.
            When the clipping region is infinite, the GetClipBounds method returns a large rectangle.
            The X and Y data members of that rectangle are large negative numbers, and the Width and Height data members are large positive numbers.
    */
    GetClipBounds()
    {
        local Rect := RectF()
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetClipBounds", "Ptr", this, "Ptr", Rect))
             ? 0     ; Error.
             : Rect  ; Ok.
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535949(v=vs.85)

    /*
        Gets a rectangle that encloses the visible clipping region of this Graphics object.
        Return value:
            If the method succeeds, the return value is a IRectF object that receives the rectangle that encloses the visible clipping region.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            The visible clipping region is the intersection of the clipping region of this Graphics object and the clipping region of the window.
    */
    GetVisibleClipBounds()
    {
        local Rect := RectF()
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetVisibleClipBounds", "Ptr", this, "Ptr", Rect))
             ? 0     ; Error.
             : Rect  ; Ok.
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535947(v=vs.85)

    /*
        Determines whether the visible clipping region of this Graphics object is empty.
        Return value:
            If the visible clipping region of this Graphics object is empty, this method returns TRUE; otherwise, it returns FALSE.
        Remarks:
            The visible clipping region is the intersection of the clipping region of this Graphics object and the clipping region of the window.
            ----------------------------------------------------------------------------------------------------
            If the visible clipping region of a Graphics object is empty, there is no area left in which to draw.
            Consequently, nothing will be drawn when the visible clipping region is empty.
    */
    IsVisibleClipEmpty()
    {
        local IsVisibleClipEmpty := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipIsVisibleClipEmpty", "Ptr", this, "IntP", IsVisibleClipEmpty)
        return IsVisibleClipEmpty
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-isvisibleclipempty

    /*
        Determines whether the specified point is inside the visible clipping region of this Graphics object.
        Determines whether the specified rectangle intersects the visible clipping region of this Graphics object.
        Return value:
            If the specified rectangle intersects the visible clipping region, this method returns TRUE; Otherwise, it returns FALSE.
        Remarks:
            The visible clipping region is the intersection of the clipping region of this Graphics object and the clipping region of the window.
    */
    IsVisible(X, Y, Width := "", Height := "")
    {
        local IsVisible := 0
        Gdiplus.LastStatus := (Width == "" || Height == "")
                            ? DllCall("Gdiplus.dll\GdipIsVisiblePoint", "Ptr", this, "Float", X, "Float", Y, "IntP", IsVisible)
                            : DllCall("Gdiplus.dll\GdipIsVisibleRect", "Ptr", this, "Float", X, "Float", Y, "Float", Width, "Float", Height, "IntP", IsVisible)
        return IsVisible
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-isvisible(inconstpointf_)

    /*
        Saves the current state (transformations, clipping region, and quality settings) of this Graphics object.
        You can restore the state later by calling the Restore method.
        Return value:
            Returns a value that identifies the saved state.
            Pass this value to the Restore method when you want to restore the state.
        Remarks:
            The identifier returned by a given call to the Save method can be passed only once to the Restore method.
    */
    Save()
    {
        local State := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSaveGraphics", "Ptr", this, "UIntP", State)
        return State
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-save

    /*
        Sets the state of this Graphics object to the state stored by a previous call to the Save method of this Graphics object.
        Parameters:
            State:
                A value returned by a previous call to the Save method that identifies a block of saved state.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Restore(State)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipRestoreGraphics", "Ptr", this, "UInt", State))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-restore

    /*
        Updates the world transformation matrix of this Graphics object with the product of itself and a translation matrix.
        Parameters:
            DX / DY:
                Real number that specifies the horizontal/vertical component of the translation.
            MatrixOrder:
                Specifies the order of multiplication.
                MatrixOrderPrepend specifies that the translation matrix is on the left.
                MatrixOrderAppend specifies that the translation matrix is on the right.
                This parameter must be a value of the MatrixOrder Enumeration. The default value is MatrixOrderPrepend.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    TranslateTransform(DX, DY, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipTranslateWorldTransform", "Ptr", this, "Float", DX, "Float", DY, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-translatetransform

    /*
        Sets the world transformation of this Graphics object.
        Parameters:
            Matrix:
                A Matrix object that specifies the world transformation.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetTransform(Matrix)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetWorldTransform", "Ptr", this, "Ptr", Matrix))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-settransform

    /*
        Sets the world transformation matrix of this Graphics object to the identity matrix.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    ResetTransform()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipResetWorldTransform", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-resettransform

    /*
        Updates the world transformation matrix of this Graphics object with the product of itself and another matrix.
        Parameters:
            Matrix:
                A Matrix object that will be multiplied by the world transformation matrix of this Graphics object.
            MatrixOrder:
                Specifies the order of multiplication.
                MatrixOrderPrepend specifies that the passed matrix is on the left.
                MatrixOrderAppend specifies that the passed matrix is on the right.
                This parameter must be a value of the MatrixOrder Enumeration. The default value is MatrixOrderPrepend.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    MultiplyTransform(Matrix, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipMultiplyWorldTransform", "Ptr", this, "Ptr", Matrix, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-multiplytransform

    /*
        Updates the world transformation matrix of this Graphics object with the product of itself and a scaling matrix.
        Parameters:
            SX / SY:
                Real number that specifies the horizontal/vertical scaling factor in the scaling matrix.
            MatrixOrder:
                Specifies the order of multiplication.
                MatrixOrderPrepend specifies that the scaling matrix is on the left.
                MatrixOrderAppend specifies that the scaling matrix is on the right.
                This parameter must be a value of the MatrixOrder Enumeration. The default value is MatrixOrderPrepend.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    ScaleTransform(SX, SY, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipScaleWorldTransform", "Ptr", this, "Float", SX, "Float", SY, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-scaletransform

    /*
        Updates the world transformation matrix of this Graphics object with the product of itself and a rotation matrix.
        Parameters:
            Angle:
                Real number that specifies the angle, in degrees, of rotation.
            MatrixOrder:
                Specifies the order of multiplication.
                MatrixOrderPrepend specifies that the rotation matrix is on the left.
                MatrixOrderAppend specifies that the rotation matrix is on the right.
                This parameter must be a value of the MatrixOrder Enumeration. The default value is MatrixOrderPrepend.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    RotateTransform(Angle, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipRotateWorldTransform", "Ptr", this, "Float", Angle, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-rotatetransform

    /*
        Gets the world transformation matrix of this Graphics object.
        Parameters:
            Matrix:
                A Matrix object that receives the transformation matrix.
                This parameter is optional and can be omitted.
        Return value:
            If the method succeeds, the return value is a Matrix object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetTransform(Matrix := 0)
    {
        Matrix := Matrix ? Matrix : Gdiplus.Matrix()
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetWorldTransform", "Ptr", this, "Ptr", Matrix))
             ? 0       ; Error.
             : Matrix  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-gettransform


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the horizontal resolution, in dots per inch, of the display device associated with this Graphics object.
    */
    DpiX[]
    {
        get {
            local DpiX := 0
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetDpiX", "Ptr", this, "FloatP", DpiX)
            return DpiX
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getdpix
    }

    /*
        Gets the vertical resolution, in dots per inch, of the display device associated with this Graphics object.
    */
    DpiY[]
    {
        get {
            local DpiY := 0
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetDpiY", "Ptr", this, "FloatP", DpiY)
            return DpiY
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getdpiy
    }

    /*
        Gets or sets the text rendering mode of this Graphics object.
        Value is an element of the TextRenderingHint Enumeration that specifies the process currently used by this Graphics object to render text.
        Remarks:
            The quality associated with each process varies according to the circumstances.
            TextRenderingHintClearTypeGridFit provides the best quality for most LCD monitors and relatively small font sizes.
            TextRenderingHintAntiAlias provides the best quality for rotated text.
            Generally, a process that produces higher quality text is slower than a process that produces lower quality text.
            ----------------------------------------------------------------------------------------------------
            You cannot use TextRenderingHintClearTypeGridFit along with CompositingModeSourceCopy.
    */
    TextRenderingHint[]
    {
        get {
            local TextRenderingHint := 0
            DllCall("Gdiplus.dll\GdipGetTextRenderingHint", "Ptr", this, "IntP", TextRenderingHint)
            return TextRenderingHint
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-gettextrenderinghint
        set => DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-settextrenderinghint
    }

    /*
        Gets or sets the contrast value of this Graphics object. The contrast value is used for antialiasing text.
        Value specifies the contrast value for antialiasing text.
    */
    TextContrast[]
    {
        get {
            local TextContrast := 0
            DllCall("Gdiplus.dll\GdipGetTextContrast", "Ptr", this, "UIntP", TextContrast)
            return TextContrast
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-gettextcontrast
        set => DllCall("Gdiplus.dll\GdipSetTextContrast", "Ptr", this, "UInt", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-settextcontrast
    }

    /*
        Gets or sets the interpolation mode of this Graphics object.
        The interpolation mode determines the algorithm that is used when images are scaled or rotated.
        Value is an element of the InterpolationMode Enumeration that specifies the interpolation mode.
    */
    InterpolationMode[]
    {
        get {
            local InterpolationMode := 0
            DllCall("Gdiplus.dll\GdipGetInterpolationMode", "Ptr", this, "IntP", InterpolationMode)
            return InterpolationMode
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getinterpolationmode
        set => DllCall("Gdiplus.dll\GdipSetInterpolationMode", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setinterpolationmode
    }

    /*
        Gets or sets the rendering quality of the Graphics object.
        Value is an element of the SmoothingMode Enumeration that specifies whether smoothing (antialiasing) is applied to lines and curves.
        Get:
            If smoothing (antialiasing) is applied to this Graphics object, this property returns SmoothingModeAntiAlias.
            If smoothing (antialiasing) is not applied to this Graphics object, this property returns SmoothingModeNone.
        Remarks:
            To get the rendering quality for text, query the TextRenderingHint property.
            The higher the level of quality of the smoothing mode, the slower the performance.
    */
    SmoothingMode[]
    {
        get {
            local SmoothingMode := 0
            DllCall("Gdiplus.dll\GdipGetSmoothingMode", "Ptr", this, "IntP", SmoothingMode)
            return SmoothingMode
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getsmoothingmode
        set => DllCall("Gdiplus.dll\GdipSetSmoothingMode", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setsmoothingmode
    }

    /*
        Gets or sets the compositing mode of this Graphics object.
        Value is an element of the CompositingMode Enumeration that specifies the compositing mode.
        Remarks:
            Suppose you create a SolidBrush object based on a color that has an alpha component of 192, which is about 75 percent of 255.
            If your Graphics object has its compositing mode set to CompositingModeSourceOver, then areas filled with the solid brush are a blend that is 75 percent brush color and 25 percent background color.
            If your Graphics object has its compositing mode set to CompositingModeSourceCopy, then the background color is not blended with the brush color.
            However, the color rendered by the brush has an intensity that is 75 percent of what it would be if the alpha component were 255.
            ----------------------------------------------------------------------------------------------------
            You cannot use CompositingModeSourceCopy along with TextRenderingHintClearTypeGridFit.
    */
    CompositingMode[]
    {
        get {
            local CompositingMode := 0
            DllCall("Gdiplus.dll\GdipGetCompositingMode", "Ptr", this, "IntP", CompositingMode)
            return CompositingMode
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getcompositingmode
        set => DllCall("Gdiplus.dll\GdipSetCompositingMode", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setcompositingmode
    }

    /*
        Gets or sets the compositing quality of this Graphics object.
        Value is an element of the CompositingQuality Enumeration that specifies the compositing quality.
        Remarks:
            When you specify that gamma correction should not be applied, the image data to be rendered (blended with the background) is assumed to be in a linear color space with a gamma value of 1.0.
            As a result, no gamma adjustment is applied to the image data before or after blending the image with the background.
            ----------------------------------------------------------------------------------------------------
            When you specify that gamma correction should be applied, the image data to be rendered (blended with the background) is assumed to be in the sRGB color space with a gamma value of 2.2.
            To ensure accurate blending, the input image data is transformed into a linear (gamma = 1.0) space before the colors are blended and transformed back into sRGB (gamma = 2.2) space afterward.
            This mode results in a more accurate blend at the expense of additional processing time.
    */
    CompositingQuality[]
    {
        get {
            local CompositingQuality := 0
            DllCall("Gdiplus.dll\GdipGetCompositingQuality", "Ptr", this, "IntP", CompositingQuality)
            return CompositingQuality
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getcompositingquality
        set => DllCall("Gdiplus.dll\GdipSetCompositingQuality", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setcompositingquality
    }

    /*
        Gets or sets the pixel offset mode of this Graphics object.
        Value is an element of the PixelOffsetMode Enumeration that specifies the pixel offset mode.
        Remarks:
            Consider the pixel in the upper-left corner of an image with address (0,0).
            With PixelOffsetModeNone, the pixel covers the area between –0.5 and 0.5 in both the x and y directions; that is, the pixel center is at (0,0).
            With PixelOffsetModeHalf, the pixel covers the area between 0 and 1 in both the x and y directions; that is, the pixel center is at (0.5,0.5).
    */
    PixelOffsetMode[]
    {
        get {
            local PixelOffsetMode := 0
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetPixelOffsetMode", "Ptr", this, "IntP", PixelOffsetMode)
            return PixelOffsetMode
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-getpixeloffsetmode
        set => DllCall("Gdiplus.dll\GdipSetPixelOffsetMode", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-setpixeloffsetmode
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a Graphics object that is associated with an Image object.
    Parameters:
        Image:
            An Image object that will be associated with the new Graphics object.
    Remarks:
        This method fails if the Image object is based on a metafile that was opened for reading.
        To open a metafile for recording, use a Metafile constructor that receives a device context handle.
        ----------------------------------------------------------------------------------------------------
        This method also fails if the image uses one of the following pixel formats:
        - PixelFormatUndefined
        - PixelFormatDontCare
        - PixelFormat1bppIndexed
        - PixelFormat4bppIndexed
        - PixelFormat8bppIndexed
        - PixelFormat16bppGrayScale
        - PixelFormat16bppARGB1555
        ----------------------------------------------------------------------------------------------------
        The Image object is stored in the Image property of the Graphics object.
        So, you can do something like this: <Gdiplus.Graphics(Gdiplus.Bitmap(W,H))>.
    Return value:
        If the method succeeds, the return value is a Graphics object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Graphics(Image)
{
    local Graphics, pGraphics := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", Image, "UPtrP", pGraphics)
    if !(Graphics := Gdiplus.Graphics.New(pGraphics))
        return 0
    Graphics.Image := Image
    return Graphics
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusgraphics/nf-gdiplusgraphics-graphics-graphics(inimage)
