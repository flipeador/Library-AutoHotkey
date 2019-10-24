/*
    The BitmapData class is used by the LockBits and UnlockBits methods of the Gdiplus::Bitmap class.
    A BitmapData object stores attributes of a bitmap.

    BitmapData Class:
        https://docs.microsoft.com/en-us/previous-versions/ms534421(v=vs.85)
*/
class BitmapData
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer := 0
    Ptr    := 0
    Size   := 0
    Bitmap := 0  ; Bitmap object associated with this BitmapData object.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Bitmap := 0)
    {
        this.Buffer := BufferAlloc(16+2*A_PtrSize)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size
        this.Bitmap := Bitmap
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Bitmap)
            DllCall("Gdiplus.dll\GdipBitmapUnlockBits", "Ptr", this.Bitmap, "Ptr", this)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-unlockbits


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Gets the color of a specified pixel in this bitmap.
        Parameters:
            X:
                Integer that specifies the x-coordinate (column) of the pixel.
            Y:
                Integer that specifies the y-coordinate (row) of the pixel.
        Return value:
            Returns the ARGB color of the specified pixel.
    */
    GetPixel(X, Y)
    {
        return NumGet(NumGet(this,16)+X*4+Y*NumGet(this,8,"Int"), "UInt")
    }

    /*
        Sets the color of a specified pixel in this bitmap.
        Parameters:
            Color:
                Specifies the ARGB color to set.
            X:
                Integer that specifies the x-coordinate (column) of the pixel.
            Y:
                Integer that specifies the y-coordinate (row) of the pixel.
    */
    SetPixel(Color, X, Y)
    {
        return Numput(Color, NumGet(this,16)+X*4+Y*NumGet(this,8,"Int"), "UInt")
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the number of pixels in one scan line of the bitmap.
    */
    Width[]
    {
        get => NumGet(this, "UInt")
        set => NumPut("UInt", Value, this)
    }

    /*
        Gets or sets the number of scan lines in the bitmap.
    */
    Height[]
    {
        get => NumGet(this, 4, "UInt")
        set => NumPut("UInt", Value, this, 4)
    }

    /*
        The offset, in bytes, between consecutive scan lines of the bitmap.
        If the stride is positive, the bitmap is top-down.
        If the stride is negative, the bitmap is bottom-up.
    */
    Stride[]
    {
        get => NumGet(this, 8, "Int")
        set => NumPut("Int", Value, this, 8)
    }

    /*
        Integer that specifies the pixel format of the bitmap.
    */
    PixelFormat[]
    {
        get => NumGet(this, 12, "Int")
        set => NumPut("Int", Value, this, 12)
    }

    /*
        Pointer to the first (index 0) scan line of the bitmap.
    */
    Scan0[]
    {
        get => NumGet(this, 16, "UPtr")
        set => NumPut("UPtr", Value, this, 16)
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a BitmapData object.
    Parameters:
        Bitmap:
            A Bitmap object that will be associated with this BitmapData object.
            This parameter is optional and can be omitted or zero.
            If specified, when the BitmapData object is deleted, the Gdiplus::Bitmap::UnlockBits method is automatically called.
    Return value:
        If the method succeeds, the return value is a BitmapData object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static BitmapData(Bitmap := 0)
{
    return Gdiplus.BitmapData.New(Bitmap)
}
