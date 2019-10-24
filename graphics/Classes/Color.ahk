#Include ArrayBlock.ahk





/*
    A IColor object stores 32-bit values that represents colors of type RGB or ARGB.
    The RGB color value contains three, 8-bit components: red, green, and blue.
    The ARGB color value contains four, 8-bit components: alpha, red, green, and blue.

    Color Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluscolor/nl-gdipluscolor-color

    COLORREF Structure:
        https://docs.microsoft.com/en-us/windows/win32/gdi/colorref
*/
class IColor extends IArrayBlockBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static DataType := "UInt"


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Capacity, Colors := 0)
    {
        this.InitBuff(IColor.DataType, Capacity, Colors)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Retrieves the alpha, red, green and blue components at the specified index in this object.
        Parameters:
            Index:
                Index of the color whose components are to be retrieved.
        Return value:
            Returns an object with properties Apha, Red, Green and Blue.
    */
    GetValue(Index)
    {
        local Color := NumGet(this, 4*Index-4, "UInt")
        return { Alpha: (0xFF000000&Color)>>24
               , Red  : (0x00FF0000&Color)>>16
               , Green: (0x0000FF00&Color)>>8
               , Blue : (0x000000FF&Color)     }

    }

    /*
        Sets the alpha, red, green and blue components at the specified index in this object.
        Parameters:
            Index:
                Index of the color whose components are to be set.
            Alpha / Red / Green / Blue:
                The alpha/red/green/blue components of the color.
        Return value:
            The return value for this method is not used.
    */
    SetValue(Index, Alpha := "", Red := "", Green := "", Blue := "")
    {
        local Color := NumGet(this, 4*Index-4, "UInt")
        NumPut("UInt", ((Alpha==""?(0xFF000000&Color)>>24:Alpha)<<24)
                     | ((Red  ==""?(0x00FF0000&Color)>>16:Red)  <<16)
                     | ((Green==""?(0x0000FF00&Color)>> 8:Green)<< 8)
                     |  (Blue ==""?(0x000000FF&Color)    :Blue      )
                     , this, 4*Index-4)
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the RGB color at the specified index in this object.
    */
    RGB[Index := 1] => NumGet(this, 4*Index-4, "UInt") & 0x00FFFFFF
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
/*
    Creates a IColor object and initializes it with the specified colors.
    Parameters:
        Colors:
            The colors to be used to initialize this object.
            If no color is specified, one is added by default (0xFF000000).
    Return value:
        Returns a IColor object.
*/
Color(Colors*)
{
    return IColor.New(Colors.Length, Colors.Length?Colors:[0xFF000000])
}

/*
    Creates a IColor object with enough space to store the specified number of colors.
    Parameters:
        Count:
            Specifies the number of colors that the object should be able to store.
    Return value:
        Returns a IColor object.
*/
ColorAlloc(Count)
{
    return IColor.New(Count)
}

/*
    Creates a IColor object by using specified values for the alpha, red, green, and blue components.
    Return value:
        Returns a IColor object.
*/
ColorARGB(Alpha, Red, Green, Blue)
{
    return IColor.New(1, [(Alpha<<24)|(Red<<16)|(Green<<8)|Blue])
}
