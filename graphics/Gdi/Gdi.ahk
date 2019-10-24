class GdiBase
{
    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Ptr)
            DllCall("Gdi32.dll\DeleteObject", "Ptr", this)
    }


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object.
        After the object is deleted, the specified handle is no longer valid.
        Parameters:
            Object:
                A handle to a logical pen, brush, font, bitmap, region, or palette.
        Return value:
            If the function succeeds, the return value is nonzero.
            If the specified handle is not valid or is currently selected into a DC, the return value is zero.
        Remarks:
            Do not delete a drawing object (pen or brush) while it is still selected into a DC.
            ---------------------------------------------------------------------------------------
            When a pattern brush is deleted, the bitmap associated with the brush is not deleted. The bitmap must be deleted independently.
    */
    static DeleteObject(Object)
    {
        return DllCall("Gdi32.dll\DeleteObject", "Ptr", Object)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-deleteobject

    /*
        Retrieves a handle to one of the stock pens, brushes, fonts, or palettes.
        Parameters:
            Type:
                The type of stock object.
                See <https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getstockobject>.
        Return value:
            If the function succeeds, the return value is a handle to the requested logical object.
            If the function fails, the return value is zero.
    */
    static GetStockObject(Type)
    {
        return DllCall("Gdi32.dll\GetStockObject", "Int", Type, "UPtr")
    } ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getstockobject

    /*
        Retrieves the type of the graphics object.
        Parameters:
            Object:
                A handle to the graphics object.
        Remarks:
            If the function succeeds, the return value identifies the object. This value can be one of the following.
            1   OBJ_PEN            Pen.
            2   OBJ_BRUSH          Brush.
            3   OBJ_DC             Device context.
            4   OBJ_METADC         Metafile DC.
            5   OBJ_PAL            Palette.
            6   OBJ_FONT           Font.
            7   OBJ_BITMAP         Bitmap.
            8   OBJ_REGION         Region.
            9   OBJ_METAFILE       Metafile.
            10  OBJ_MEMDC          Memory DC
            11  OBJ_EXTPEN         Extended pen.
            12  OBJ_ENHMETADC      Enhanced metafile DC.
            13  OBJ_ENHMETAFILE    Enhanced metafile.
            14  OBJ_COLORSPACE     Color space.
            If the function fails, the return value is zero.
    */
    static GetObjectType(Object)
    {
        return DllCall("Gdi32.dll\GetObjectType", "Ptr", Object, "UInt")
    } ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getobjecttype

    /*
        Retrieves information for the specified graphics object.
        Parameters:
            Object:
                A handle to the graphics object of interest.
            Buffer:
                A buffer that receives the information about the specified graphics object.
                HBITMAP                       BITMAP structure (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmap).
                HBITMAP (CreateDIBSection)    BITMAP or DIBSECTION structure (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-dibsection).
                HPALETTE                      A WORD count of the number of entries in the logical palette
                HPEN                          LOGPEN structure (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logpen).
                HPEN (ExtCreatePen)           EXTLOGPEN structure (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-extlogpen).
                HBRUSH                        LOGBRUSH structure (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logbrush).
                HFONT                         LOGFONTW structure (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logfontw).
            Size:
                The number of bytes of information to be written to the buffer.
        Return value:
            If the function succeeds, and «Buffer» is valid, the return value is the number of bytes stored into the buffer.
            If the function succeeds, and «Buffer» is zero, the return value is the number of bytes required to hold the information the function would store into the buffer.
            If the function fails, the return value is zero.
    */
    static GetObject(Object, Buffer := 0, Size := 0)
    {
        return DllCall("Gdi32.dll\GetObject", "Ptr", Object, "Int", Size, "Ptr", Buffer)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getobject

    /*
        Retrieves information for the specified graphics object.
        Parameters:
            Object:
                A handle to the graphics object of interest.
            Size:
                The number of bytes of information to be written to the buffer.
        Return value:
            If the function succeeds, the return value is a Buffer object.
            If the function fails, the return value is zero.
    */
    static GetObject2(Object, Size := -1)
    {
        local Buffer := BufferAlloc(Size<0?DllCall("Gdi32.dll\GetObject","Ptr",Object,"Int",0,"Ptr",0):Size)
        return DllCall("Gdi32.dll\GetObject", "Ptr", Object, "Int", Buffer.Size, "Ptr", Buffer)
             ? Buffer  ; Ok.
             : 0       ; Error.
    }
}





class Gdi extends GdiBase
{
    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    #Include Bitmap.ahk      ; Extends GdiBase.
    #Include SolidBrush.ahk  ; Extends GdiBase.
    #Include Pen.ahk         ; Extends GdiBase.
    #Include Font.ahk        ; Extends GdiBase.

    #Include Classes\BeginPaint.ahk
}
