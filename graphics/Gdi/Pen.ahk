class Pen extends GdiBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr)
    {
        this.Ptr := Ptr
    }

    static New(Ptr)
    {
        return Ptr ? base.New(Ptr) : 0
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdi)                                                                                                  #
; #######################################################################################################################
/*
    Creates a Pen object that has the specified style, width, and color.
    The pen can subsequently be selected into a device context and used to draw lines and curves.
    Parameters:
        Color:
            A RGB color for the pen color.
        Width:
            The width of the pen, in logical units. If zero, the pen is a single pixel wide, regardless of the current transformation.
        Style:
            The pen style. It can be any one of the following values.
            0 PS_SOLID         The pen is solid. Used if the width is greater than 1 for styles PS_DASH, PS_DOT, PS_DASHDOT and PS_DASHDOTDOT.
            1 PS_DASH          The pen is dashed. This style is valid only when the pen width is one or less in device units.
            2 PS_DOT           The pen is dotted. This style is valid only when the pen width is one or less in device units.
            3 PS_DASHDOT       The pen has alternating dashes and dots. This style is valid only when the pen width is one or less in device units.
            4 PS_DASHDOTDOT    The pen has alternating dashes and double dots. This style is valid only when the pen width is one or less in device units.
            5 PS_NULL          The pen is invisible.
            6 PS_INSIDEFRAME   The pen is solid. When this pen is used in any GDI drawing function that takes a bounding rectangle, the dimensions of the figure are shrunk so that it fits entirely in the bounding rectangle, taking into account the width of the pen. This applies only to geometric pens.
    Remarks:
        If the width is zero, a line drawn with the created pen always is a single pixel wide regardless of the current transformation.
        If the width is greater than 1, the style must be PS_NULL, PS_SOLID, or PS_INSIDEFRAME.
        If the width is greater than 1 and the style is PS_INSIDEFRAME, the line associated with the pen is drawn inside the frame of all primitives except polygons and polylines.
        If the width is greater than 1, the style is PS_INSIDEFRAME, and the color does not match one of the entries in the logical palette, the system draws lines by using a dithered color. Dithered colors are not available with solid pens.
        -------------------------------------------------------------------------------------------
        ICM: No color management is done at creation. However, color management is performed when the pen is selected into an ICM-enabled device context.
        -------------------------------------------------------------------------------------------
        Although you can specify any color for a pen when creating it, the system uses only colors that are available on the device. This means the system uses the closest matching color when it realizes the pen for drawing.
    Return value:
        If the method succeeds, the return value is a Pen object.
        If the method fails, the return value is zero.
*/
static Pen(Color := 0x000000, Width := 1, Style := 0)
{
    return Gdi.Pen.New(DllCall("Gdi32.dll\CreatePen","Int",Style,"Int",Width,"UInt",Color,"UPtr"))
} ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createpen
