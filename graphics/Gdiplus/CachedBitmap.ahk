/*
    A CachedBitmap object stores a bitmap in a format that is optimized for display on a particular device.
    To display a cached bitmap, call the Gdiplus::Graphics::DrawCachedBitmap method.

    CachedBitmap Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-cachedbitmap
*/
class CachedBitmap extends Gdiplus.Image
{
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
            DllCall("Gdiplus.dll\GdipDeleteCachedBitmap", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-cachedbitmap-flat
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a CachedBitmap object based on a Bitmap object and a Graphics object.
    The cached bitmap takes the pixel data from the Bitmap object and stores it in a format that is optimized for the display device associated with the Graphics object.
    Parameters:
        Bitmap:
            A Bitmap object.
        Graphics:
            A Graphics object.
    Return value:
        If the method succeeds, the return value is a CachedBitmap object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    Remarks:
        You can display a cached bitmap by passing a CachedBitmap object to the DrawCachedBitmap method of a Gdiplus::Graphics object.
        Use the Gdiplus::Graphics object that was passed to this method or another Gdiplus::Graphics object that represents the same device.
*/
CachedBitmap(Bitmap, Graphics)
{
    local pCachedBitmap := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateCachedBitmap", "Ptr", Bitmap, "Ptr", Graphics, "UPtrP", pCachedBitmap)
    return Gdiplus.CachedBitmap.New(pCachedBitmap)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-cachedbitmap-cachedbitmap(constcachedbitmap_)
