class Bitmap extends GdiBase
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
    Creates a bitmap compatible with the device that is associated with the specified device context.
    Parameters:
        hDC:
            A handle to a device context.
        Width / Height:
            The bitmap width/height, in pixels.
    Return value:
        If the method succeeds, the return value is a a handle to the DIB section.
        If the method fails, the return value a handle to the compatible bitmap (DDB).
*/
static CreateBitmap(hDC := "", Width := 1, Height := 1, BitCount := 32, Planes := 1, pBits := 0)
{
    return (hDC == "")
         ? DllCall("Gdi32.dll\CreateBitmap", "Int", Width, "Int", Height, "UInt", Planes, "UInt", BitCount, "Ptr", pBits, "UPtr")
         : DllCall("Gdi32.dll\CreateCompatibleBitmap", "Ptr", hDC, "Int", Width, "Int", Height, "UPtr")
} ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createcompatiblebitmap

static Bitmap(hDC := "", Width := 1, Height := 1, BitCount := 32, Planes := 1, pBits := 0)
{
    return Gdi.Bitmap.New(Gdi.CreateBitmap(hDC,Width,Height,BitCount,Planes,pBits))
}

/*
    Creates a DIB that applications can write to directly.
    Parameters:
        hDC:
            A handle to a device context.
            If the value of «Usage» is DIB_PAL_COLORS, the function uses this device context's logical palette to initialize the DIB colors.
            If this parameter us zero, the method creates a temporary DC for the entire screen.
        BITMAPINFO:
            A BITMAPINFO structure that specifies various attributes of the DIB, including the bitmap dimensions and colors.
            -----------------------------------------------------------------------------------
            This parameter can be an object with properties W/Width, H/Height, BitCount and pColors.
            Width and Height are mandatory. BitCount defaults to 32.
        Usage:
            The type of data contained in the bmiColors array member of the BITMAPINFO structure (either logical palette indexes or literal RGB values).
            The following values are defined:
                0  DIB_RGB_COLORS    The BITMAPINFO structure contains an array of literal RGB values.
                1  DIB_PAL_COLORS    The bmiColors member is an array of 16-bit indexes into the logical palette of the device context.
        pBits:
            A pointer to a variable that receives a pointer to the location of the DIB bit values.
        hSection:
            A handle to a file-mapping object that the function will use to create the DIB.
        Offset:
            The offset from the beginning of the file-mapping object where storage for the bitmap bit values is to begin.
            The bitmap bit values are aligned on doubleword boundaries, so «Offset» must be a multiple of the size of a DWORD.
    Return value:
        If the method succeeds, the return value is a a handle to the DIB section.
        If the method fails, the return value is zero.
    Remarks:
        You cannot paste a DIB section from one application into another application.
        ---------------------------------------------------------------------------------------
        CreateDIBSection does not use biXPelsPerMeter or biYPelsPerMeter and will not provide resolution information in the BITMAPINFO structure.
        ---------------------------------------------------------------------------------------
        You need to guarantee that the GDI subsystem has completed any drawing to a bitmap created by CreateDIBSection before you draw to the bitmap yourself.
        Access to the bitmap must be synchronized. Do this by calling the GdiFlush function.
        This applies to any use of the pointer to the bitmap bit values, including passing the pointer in calls to functions such as SetDIBits.
        ---------------------------------------------------------------------------------------
        No color management is done.
    CreateCompatibleBitmap vs CreateDIBSection:
        https://social.msdn.microsoft.com/Forums/en-US/20d9d053-4af1-417e-989f-80efb227e4dd/createcompatiblebitmap-vs-createdibsection-for-drawing?forum=vcmfcatl.
*/
static CreateDIBSection(hDC, BITMAPINFO, Usage := 0, pBits := 0, hSection := 0, Offset := 0)
{
    local DC := hDC || DllCall("User32.dll\GetDC", "Ptr", 0)

    if (IsObject(BITMAPINFO)
        && (BITMAPINFO is ISizeBase)
        || (BITMAPINFO is IRectBase)
        || (!BITMAPINFO.HasOwnProp("Ptr")))
    {
        local Buffer := BufferAlloc(44+A_PtrSize, 0)  ; BITMAPINFO structure.
        NumPut("UInt"  , 44                                                         ; BITMAPINFO::BITMAPINFOHEADER::biSize.
             , "Int"   , BITMAPINFO.HasOwnProp("W")?BITMAPINFO.W:BITMAPINFO.Width   ; BITMAPINFO::BITMAPINFOHEADER::biWidth.
             , "Int"   , BITMAPINFO.HasOwnProp("H")?BITMAPINFO.H:BITMAPINFO.Height  ; BITMAPINFO::BITMAPINFOHEADER::biHeight.
             , "UShort", 1                                                          ; BITMAPINFO::BITMAPINFOHEADER::biPlanes.
             , "UShort", BITMAPINFO.HasOwnProp("BitCount")?BITMAPINFO.BitCount:32   ; BITMAPINFO::BITMAPINFOHEADER::biBitCount.
             , Buffer)
        NumPut("UPtr", BITMAPINFO.HasOwnProp("pColors")&&BITMAPINFO.pColors, Buffer, 44)  ; BITMAPINFO::bmiColors[].
        BITMAPINFO := Buffer
    }

    local hDIB := DllCall("Gdi32.dll\CreateDIBSection", "Ptr", DC, "Ptr", BITMAPINFO, "UInt", Usage, "Ptr", pBits, "Ptr", hSection, "UInt", Offset, "UPtr")

    if (!hDC)
        DllCall("User32.dll\ReleaseDC", "Ptr", 0, "Ptr", DC)

    return hDIB
} ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createdibsection

static DIBSection(hDC, BITMAPINFO, Usage := 0, pBits := 0, hSection := 0, Offset := 0)
{
    return Gdi.Bitmap.New(Gdi.CreateDIBSection(hDC,BITMAPINFO,Usage,pBits,hSection,Offset))
}
