class SolidBrush extends GdiBase
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
    Creates a SolidBrush object that has the specified solid color.
    Parameters:
        Color:
            The RGB color of the brush.
    Remarks:
        A solid brush is a bitmap that the system uses to paint the interiors of filled shapes.
        -------------------------------------------------------------------------------------------
        No color management is done at brush creation. However, color management is performed when the brush is selected into an ICM-enabled device context.
    Return value:
        If the method succeeds, the return value is a SolidBrush object.
        If the method fails, the return value is zero.
*/
static SolidBrush(Color := 0x000000)
{
    return Gdi.SolidBrush.New(DllCall("Gdi32.dll\CreateSolidBrush","UInt",Color,"UPtr"))
} ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createsolidbrush
