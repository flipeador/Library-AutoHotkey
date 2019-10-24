/*
    The LinearGradientBrush class defines a brush that paints a color gradient in which the color changes evenly from the starting boundary line of the linear gradient brush to the ending boundary line of the linear gradient brush.
    The boundary lines of a linear gradient brush are two parallel straight lines.
    The color gradient is perpendicular to the boundary lines of the linear gradient brush, changing gradually across the stroke from the starting boundary line to the ending boundary line.
    The color gradient has one color at the starting boundary line and another color at the ending boundary line.

    LinearGradientBrush Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nl-gdiplusbrush-lineargradientbrush

    LinearGradientBrush Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-lineargradientbrush-flat
*/
class LinearGradientBrush extends Gdiplus.Brush
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Creates a LinearGradientBrush object based on a rectangle and mode of direction.
        Parameters:
            Rect:
                A rectangle that specifies the starting and ending points of the gradient.
                The direction of the gradient, specified by mode, affects how these points are defined.
                The dimensions of the rectangle affect the direction of the gradient for forward diagonal mode and backward diagonal mode.
            Color1:
                An ARGB Color that specifies the color at the starting boundary line of this linear gradient brush.
            Color2:
                An ARGB Color that specifies the color at the ending boundary line of this linear gradient brush.
            Mode:
                Element of the LinearGradientMode Enumeration that specifies the direction of the gradient.
            WrapMode:
                Specifies how areas painted with the linear gradient brush will be tiled.
                This parameter must be a value of the WrapMode Enumeration. The default value is WrapModeTile.
        Return value:
            If the method succeeds, the return value is a LinearGradientBrush object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            The starting boundary of the gradient is a straight line that either passes through the starting point or borders the rectangle rect.
            The ending boundary of the gradient is a straight line that is parallel to the starting boundary line and that either passes through the ending point or borders the rectangle.
            The "directional line", an imaginary straight line, is perpendicular to the boundary lines.
            The gradient color is constant along lines that are parallel to the boundary lines.
            The gradient gradually changes from the starting color to the ending color along the directional line.
            ---------------------------------------------------------------------------------------
            The mode affects the boundaries of the gradient:
            • Vertical mode The boundary lines are parallel to the top (and bottom) of the rectangle rect. The starting and ending boundary lines are the top and bottom, respectively, of the rectangle rect.
            • Horizontal mode The boundary lines are parallel to the left (and right) of the rectangle rect. The starting and ending boundary lines are the left and right, respectively, of the rectangle rect.
            • Forward diagonal mode The boundary lines are parallel to the diagonal line that is defined by the upper-right corner and lower-left corner of the rectangle rect. The starting boundary line passes through the starting point (upper-left corner of the rectangle rect). The ending boundary line passes through the ending point (lower-right corner of the rectangle rect). Note that starting and ending points are opposites of the starting and ending points for backward diagonal mode.
            • Backward diagonal mode The boundary lines are parallel to the diagonal line that is defined by the upper-left corner and lower-right corner of the rectangle rect. The starting boundary line passes through the starting point (upper-right corner of the rectangle rect). The ending boundary line passes through the ending point (lower-left corner of the rectangle rect). Note that starting and ending points are opposites of the starting and ending points for forward diagonal mode.
    */
    static FromRect(Rect, Color1, Color2, Mode := 0, WrapMode := 0)
    {
        local pLGBrush := 0
        Gdiplus.LastStatus := Rect is IRect  ; IRect object.
                            ? DllCall("Gdiplus.dll\GdipCreateLineBrushFromRectI", "Ptr", Rect, "UInt", Color1, "UInt", Color2, "Int", Mode, "Int", WrapMode, "UPtrP", pLGBrush)
                            : DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect", "Ptr", Rect, "UInt", Color1, "UInt", Color2, "Int", Mode, "Int", WrapMode, "UPtrP", pLGBrush)
        return Gdiplus.LinearGradientBrush.New(pLGBrush)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-lineargradientbrush(inconstrectf__inconstcolor__inconstcolor__inlineargradientmode)

    /*
        Creates a LinearGradientBrush object from a rectangle and angle of direction.
        Parameters:
            Rect:
                A rectangle that specifies the starting and ending points of the gradient.
                The upper-left corner of the rectangle is the starting point.
                The lower-right corner is the ending point.
            Color1:
                An ARGB Color that specifies the color at the starting boundary line of this linear gradient brush.
            Color2:
                An ARGB Color that specifies the color at the ending boundary line of this linear gradient brush.
            Angle:
                If «IsAngleScalable» is TRUE, specifies the base angle from which the angle of the directional line is calculated.
                If «IsAngleScalable» is FALSE, specifies the angle of the directional line.
                The angle is measured from the top of the rectangle that is specified by rect and must be in degrees.
                The gradient follows the directional line.
            IsAngleScalable:
                TRUE     The angle of the directional line is scalable.
                FALSE    The angle of the directional line is not scalable.
            WrapMode:
                Specifies how areas painted with the linear gradient brush will be tiled.
                This parameter must be a value of the WrapMode Enumeration. The default value is WrapModeTile.
        Return value:
            If the method succeeds, the return value is a LinearGradientBrush object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            The "directional line", an imaginary straight line, is defined by the starting point (upper-left corner of the rectangle rect) and the angle angle.
            The starting boundary of the gradient is a straight line that is perpendicular to the directional line and that passes through the starting point.
            The ending boundary of the gradient is a straight line that is parallel to the starting boundary line and that passes through the ending point (lower-right corner of the rectangle rect).
            The gradient color is constant along lines that are parallel to the boundary lines.
            The gradient gradually changes from the starting color to the ending color along the directional line.
            ---------------------------------------------------------------------------------------
            If «IsAngleScalable» is TRUE, the base angle is scaled to produce the angle of the directional line:
            •⠀ß = arctan( (width / height) tan(ø) )
            where ß is the new angle of the directional line; width and height are the dimensions of the rectangle rect; and ø is the base angle angle.
            This relationship is valid only if angle is less than 90 degrees.
    */
    static FromRectAngle(Rect, Color1, Color2, Angle := 90, IsAngleScalable := FALSE, WrapMode := 0)
    {
        local pLGBrush := 0
        Gdiplus.LastStatus := Rect is IRect
                            ? DllCall("Gdiplus.dll\GdipCreateLineBrushFromRectWithAngleI", "Ptr", Rect, "UInt", Color1, "UInt", Color2, "Float", Angle, "Int", IsAngleScalable, "Int", WrapMode, "UPtrP", pLGBrush)
                            : DllCall("Gdiplus.dll\GdipCreateLineBrushFromRectWithAngle", "Ptr", Rect, "UInt", Color1, "UInt", Color2, "Float", Angle, "Int", IsAngleScalable, "Int", WrapMode, "UPtrP", pLGBrush)
        return Gdiplus.LinearGradientBrush.New(pLGBrush)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-lineargradientbrush(inconstrectf__inconstcolor__inconstcolor__inreal_inbool)


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Sets the starting color and ending color of this linear gradient brush.
        Parameters:
            Color1:
                An ARGB Color that specifies the color at the starting boundary line of this linear gradient brush.
            Color2:
                An ARGB Color that specifies the color at the ending boundary line of this linear gradient brush.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetLinearColors(Color1, Color2)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetLineColors", "Ptr", this, "UInt", Color1, "UInt", Color2))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-setlinearcolors

    /*
        Gets the starting color and ending color of this linear gradient brush.
        Return value:
            If the method succeeds, the return value is a IColor object that receives the starting color and the ending color.
            - The first color in the colors array is the color at the starting boundary line of the gradient.
            - The second color in the colors array is the color at the ending boundary line.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetLinearColors()
    {
        local Colors := IColor.Alloc.New(2)  ; Color(Color1, Color2).
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetLineColors", "Ptr", this, "Ptr", Colors))
             ? 0       ; Error.
             : Colors  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-getlinearcolors

    /*
        Sets the colors to be interpolated for this linear gradient brush and their corresponding blend positions.
        Parameters:
            PresetColors:
                An array of Color objects that specify the colors to be interpolated for this linear gradient brush.
                A color of a given index in the «PresetColors» array corresponds to the blend position of that same index in the «BlendPositions» array.
            BlendPositions:
                An array of real numbers that specify the blend positions.
                Each number in the array specifies a percentage of the distance between the starting boundary and the ending boundary and is in the range from 0.0 through 1.0, where 0.0 indicates the starting boundary of the gradient and 1.0 indicates the ending boundary.
                There must be at least two positions specified: the first position, which is always 0.0, and the last position, which is always 1.0. Otherwise, the behavior is undefined.
                A blend position between 0.0 and 1.0 indicates the line, parallel to the boundary lines, that is a certain fraction of the distance from the starting boundary to the ending boundary.
                For example, a blend position of 0.7 indicates the line that is 70 percent of the distance from the starting boundary to the ending boundary.
                The color is constant on lines that are parallel to the boundary lines.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetInterpolationColors(PresetColors, BlendPositions)
    {
        if (BlendPositions.Capacity < PresetColors.Capacity)
            throw Exception(Format("0x{:08X}",Gdiplus.LastStatus:=2), -1, "Gdiplus.LinearGradientBrush.SetInterpolationColors() - Invalid parameter.")  ; InvalidParameter.
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetLinePresetBlend", "Ptr", this, "Ptr", PresetColors, "Ptr", BlendPositions, "Int", PresetColors.Capacity))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-setinterpolationcolors

    /*
        Updates this brush's current transformation matrix with the product of itself and a rotation matrix.
        Parameters:
            Angle:
                Real number that specifies the angle of rotation in degrees.
            MatrixOrder:
                Specifies the order of the multiplication.
                MatrixOrderPrepend specifies that the rotation matrix is on the left.
                MatrixOrderAppend specifies that the rotation matrix is on the right.
                This parameter must be a value of the MatrixOrder Enumeration. The default value is MatrixOrderPrepend.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    RotateTransform(Angle, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipRotateLineTransform", "Ptr", this, "Float", Angle, "Float", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-rotatetransform


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Sets or gets whether gamma correction is enabled for this LinearGradientBrush object (occurs during rendering).
        TRUE     Specifies that gamma correction is enabled.
        FALSE    specifies that gamma correction is not enabled.
        By default, gamma correction is disabled during construction of a LinearGradientBrush object.
        Remarks:
            Gamma correction is often done to match the intensity contrast of the gradient to the ability of the human eye to perceive intensity changes.
    */
    GammaCorrection[]
    {
        get {
            local GammaCorrection := 0
            DllCall("Gdiplus.dll\GdipGetLineGammaCorrection", "Ptr", this, "IntP", GammaCorrection)
            return GammaCorrection
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-getgammacorrection
        set => DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-setgammacorrection
    }

    /*
        Gets the rectangle that defines the boundaries of the gradient.
        The return value is a IRectF object that receives the rectangle that defines the boundaries of the gradient.
        For example, if a linear gradient brush is constructed with a starting point at (20.2,50.8) and an ending point at (60.5,110.0), then the defining rectangle has its upper-left point at (20.2,50.8), a width of 40.3, and a height of 59.2.
        Remarks:
            The rectangle defines the boundaries of the gradient in the following ways:
            • The right and left sides of the rectangle form the boundaries of a horizontal gradient.
            • The top and bottom sides form the boundaries of a vertical gradient.
            • Two of the diagonally opposing corners lie on the boundaries of a diagonal gradient.
            In each of these cases, either side/corner may be on the starting boundary, depending on how the starting and ending points are passed to the constructor.
    */
    Rect[]
    {
        get {
            local RectF := RectF()
            DllCall("Gdiplus.dll\GdipGetLineRect", "Ptr", this, "Ptr", RectF)
            return RectF
        } ; https://docs.microsoft.com/en-us/previous-versions//ms535352(v=vs.85)
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a LinearGradientBrush object from a set of boundary points and boundary colors.
    Parameters:
        Point1:
            Specifies the starting point of the gradient. The starting boundary line passes through the starting point.
        Point2:
            Specifies the ending point of the gradient. The ending boundary line passes through the ending point.
        Color1:
            An ARGB Color that specifies the color at the starting boundary line of this linear gradient brush.
        Color2:
            An ARGB Color that specifies the color at the ending boundary line of this linear gradient brush.
        WrapMode:
            Specifies how areas painted with the linear gradient brush will be tiled.
            This parameter must be a value of the WrapMode Enumeration. The default value is WrapModeTile.
    Remarks:
        The "directional line", an imaginary straight line, is defined by the starting point, Point1, and the ending point, Point2.
        The starting boundary of the gradient is a straight line that is perpendicular to the directional line and that passes through the starting point.
        The ending boundary of the gradient is a straight line that is parallel to the starting boundary line and that passes through the ending point.
        The gradient color is constant along lines that are parallel to the boundary lines.
        The gradient gradually changes from the starting color to the ending color along the directional line.
    Return value:
        If the method succeeds, the return value is a LinearGradientBrush object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static LinearGradientBrush(Point1, Point2, Color1, Color2, WrapMode := 0)
{
    local pLGBrush := 0
    Gdiplus.LastStatus := Point1 is IPoint  ; IPoint object.
                        ? DllCall("Gdiplus.dll\GdipCreateLineBrushI", "Ptr", Point1, "Ptr", Point2, "UInt", Color1, "UInt", Color2, "Int", WrapMode, "UPtrP", pLGBrush)
                        : DllCall("Gdiplus.dll\GdipCreateLineBrush", "Ptr", Point1, "Ptr", Point2, "UInt", Color1, "UInt", Color2, "Int", WrapMode, "UPtrP", pLGBrush)
    return Gdiplus.LinearGradientBrush.New(pLGBrush)
}  ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-lineargradientbrush-lineargradientbrush(inconstpointf__inconstpointf__inconstcolor__inconstcolor_)
