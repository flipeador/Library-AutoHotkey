/*
    The Bitmap class inherits from the Image class.
    The Image class provides methods for loading and saving vector images (metafiles) and raster images (bitmaps).
    The Bitmap class expands on the capabilities of the Image class by providing additional methods for creating and manipulating raster images.

    Bitmap Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-bitmap

    Bitmap Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-bitmap-flat
*/
class Bitmap extends Gdiplus.Image
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
        Creates a Bitmap object based on an image file.
        Parameters:
            FileName:
                A string with the path name of the image file.
                The graphics file formats supported by GDI+ are BMP, GIF, JPEG, PNG, TIFF, Exif, WMF, and EMF.
                This method additionally supports files: EXE (executable), DLL, CUR (cursor) and ANI (animated cursor).
            Options:
                Options passed to the built-in LoadPicture function if the file is EXE, DLL, CUR or ANI.
            UseEmbeddedColorManagement:
                Boolean value that specifies whether the new Bitmap object applies color correction according to color management information that is embedded in the image file.
                Embedded information can include International Color Consortium (ICC) profiles, gamma values, and chromaticity information.
                TRUE specifies that color correction is enabled, and FALSE specifies that color correction is not enabled. The default value is FALSE.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromFile(FileName, Options := "", UseEmbeddedColorManagement := FALSE)
    {
        local Bitmap := 0  ; GDI+ Bitmap.
        switch (Format("{:L}",SubStr(FileName,-3)))  ; File extension.
        {
        case "exe","dll","cur","ani":
            Bitmap := Gdiplus.Bitmap.FromHBITMAP(LoadPicture(FileName,Options),,2)
        default:
            local pBitmap := 0
            Gdiplus.LastStatus := UseEmbeddedColorManagement
                                ? DllCall("Gdiplus.dll\GdipCreateBitmapFromFileICM", "Ptr", &FileName, "UPtrP", pBitmap)
                                : DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "Ptr", &FileName, "UPtrP", pBitmap)
            Bitmap := Gdiplus.Bitmap.New(pBitmap)
        }
        return Bitmap
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(inconstwchar_inbool)

    /*
        Creates a Bitmap object based on an IStream COM interface.
        Parameters:
            Stream:
                An IStream COM interface.
            UseEmbeddedColorManagement:
                Boolean value that specifies whether the new Bitmap object applies color correction according to color management information that is embedded in the stream (represented by the stream parameter).
                Embedded information can include International Color Consortium (ICC) profiles, gamma values, and chromaticity information.
                TRUE specifies that color correction is enabled, and FALSE specifies that color correction is not enabled. The default value is FALSE.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromStream(Stream, UseEmbeddedColorManagement := FALSE)
    {
        local pBitmap := 0
        Gdiplus.LastStatus := UseEmbeddedColorManagement
                            ? DllCall("Gdiplus.dll\GdipCreateBitmapFromStreamICM", "Ptr", Stream, "UPtrP", pBitmap)
                            : DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", Stream, "UPtrP", pBitmap)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(inistream_inbool)

    /*
        Creates a Bitmap object based on an HGLOBAL memory handle.
        Parameters:
            Memory:
                A memory handle allocated by the Kernel32\GlobalAlloc function.
                The handle must be allocated as moveable and nondiscardable.
            UseEmbeddedColorManagement:
                See the FromStream method.
            DeleteOnRelease:
                A value that indicates whether the specified memory handle should be automatically freed when the stream object is released.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromHGLOBAL(Memory, UseEmbeddedColorManagement := FALSE, DeleteOnRelease := FALSE)
    {
        local pStream := 0
        DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", Memory, "Int", DeleteOnRelease, "PtrP", pStream)
        local Bitmap := Gdiplus.Bitmap.FromStream(pBitmap, UseEmbeddedColorManagement)
        if (pStream)
            ObjRelease(pStream)  ; Release the stream object.
        return Bitmap
    } ; https://docs.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-createstreamonhglobal

    /*
        Creates a Bitmap object based on an application or DLL instance handle and the name of a bitmap resource.
        Parameters:
            hInstance:
                Handle to an instance of a module whose executable file contains a bitmap resource.
            BitmapName:
                A string that specifies the path name of the bitmap resource to be loaded.
                Alternatively, this parameter can consist of the resource identifier.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromResource(hInstance, BitmapName)
    {
        local pBitmap := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateBitmapFromResource", "Ptr", hInstance
            , "Ptr", Type(BitmapName)=="String"?&BitmapName:BitmapName, "UPtrP", pBitmap)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(inhinstance_inconstwchar)

    /*
        Creates a Bitmap object based on a Graphics object, a width, and a height.
        Parameters:
            Graphics:
                A Graphics object that contains information used to initialize certain properties (for example, dots per inch) of the new Bitmap object.
            Width / Height:
                Integer that specifies the width/height, in pixels, of the bitmap.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromGraphics(Graphics, Width, Height)
    {
        local pBitmap := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateBitmapFromGraphics", "Int", Width, "Int", Height, "Ptr", Graphics, "UPtrP", pBitmap)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(inint_inint_ingraphics)

    /*
        Creates a Bitmap object based on a handle to a Windows Windows Graphics Device Interface (GDI) bitmap and a handle to a GDI palette.
        Parameters:
            hBitmap:
                Handle to a GDI bitmap.
            hPalette:
                Handle to a GDI palette used to define the bitmap colors if hbm is not a device-independent bitmap (DIB).
            DeleteBitmap:
                Specifies whether to delete the GDI bitmap.
                0    Specifies that the GDI bitmap should not be deleted.
                1    Specifies that the GDI bitmap should only be deleted if the method was successful.
                2    Specifies that the GDI bitmap must be deleted before returning, regardless of whether the method was successful or not.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromHBITMAP(hBitmap, hPalette := 0, DeleteBitmap := 0)
    {
        local pBitmap := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", hPalette, "UPtrP", pBitmap)
        if ((hBitmap && (DeleteBitmap == 2)) || (pBitmap && (DeleteBitmap == 1)))
            DllCall("Gdi32.dll\DeleteObject", "Ptr", hBitmap)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(inhbitmap_inhpalette)

    /*
        Creates a Bitmap object based on an icon.
        Parameters:
            hIcon:
                Handle to a GDI icon.
            DeleteIcon:
                Specifies whether to delete the GDI icon.
                0    Specifies that the GDI icon should not be deleted.
                1    Specifies that the GDI icon should only be deleted if the method was successful.
                2    Specifies that the GDI icon must be deleted before returning, regardless of whether the method was successful or not.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static FromHICON(hIcon, DeleteIcon := 0)
    {
        local pBitmap := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateBitmapFromHICON", "Ptr", hIcon, "UPtrP", pBitmap)
        if ((hIcon && (DeleteIcon == 2)) || (pBitmap && (DeleteIcon == 1)))
            DllCall("User32.dll\DestroyIcon", "Ptr", hIcon)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(inhicon)


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Creates a GDI bitmap from this Bitmap object.
        Parameters:
            BackgroundColor:
                Specifies the ARGB background color.
                This parameter is ignored if the bitmap is totally opaque.
        Return value:
            If the method succeeds, the return value is a handle to the GDI bitmap.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    CreateHBITMAP(BackgroundColor := 0xFFFFFFFF)
    {
        local hBitmap := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", this, "UPtrP", hBitmap, "UInt", BackgroundColor)
        return hBitmap
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-gethbitmap

    /*
        Creates a GDI icon from this Bitmap object.
        Return value:
            If the method succeeds, the return value is a handle to the icon.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    CreateHICON()
    {
        local hIcon := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateHICONFromBitmap", "Ptr", this, "UPtrP", hIcon)
        return hIcon
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-gethicon

    /*
        Creates a new Bitmap object by copying a portion of this bitmap.
        Parameters:
            X / Y:
                Real number that specifies the x/y-coordinate of the upper-left corner of the rectangle that specifies the portion of this bitmap to copy.
            Width / Height:
                Real number that specifies the width/height of the rectangle that specifies the portion of this bitmap to copy.
        Return value:
            If the method succeeds, the return value is a Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    CloneArea(X, Y, Width, Height)
    {
        local pBitmap := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneBitmapArea", "Float", X, "Float", Y, "Float", Width, "Float", Height, "Ptr", this, "UPtrP", pBitmap)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-clone(inreal_inreal_inreal_inreal_inpixelformat)

    /*
        Locks a rectangular portion of this bitmap and provides a temporary buffer that you can use to read or write pixel data in a specified format.
        Any pixel data that you write to the buffer is copied to the Bitmap object when you call the UnlockBits method.
        Parameters:
            Rect:
                A rectangle that specifies the portion of the bitmap to be locked.
                If this parameter is zero, the entire bitmap is used.
            BitmapData:
                A BitmapData object (https://docs.microsoft.com/en-us/previous-versions/ms534421(v=vs.85)).
                -----------------------------------------------------------------------------------
                If the ImageLockModeUserInputBuf flag of the flags parameter is cleared, then lockedBitmapData serves only as an output parameter.
                In that case, the Scan0 data member of the BitmapData object receives a pointer to a temporary buffer, which is filled with the values of the requested pixels.
                The other data members of the BitmapData object receive attributes (width, height, format, and stride) of the pixel data in the temporary buffer.
                If the pixel data is stored bottom-up, the Stride data member is negative.
                If the pixel data is stored top-down, the Stride data member is positive.
                -----------------------------------------------------------------------------------
                If the ImageLockModeUserInputBuf flag of the flags parameter is set, then lockedBitmapData serves as an input parameter (and possibly as an output parameter).
                In that case, the caller must allocate a buffer for the pixel data that will be read or written.
                The caller also must create a BitmapData object, set the Scan0 data member of that BitmapData object to the address of the buffer, and set the other data members of the BitmapData object to specify the attributes (width, height, format, and stride) of the buffer.
                -----------------------------------------------------------------------------------
                This parameter is optional and can be zero.
                In such case, this method allocates a BitmapData object and returns it if successful.
                - When the last reference to the BitmapData object is destroyed, the UnlockBits method is automatically called.
                - BitmapData.Bitmap contains a reference to this Bitmap object. It can be set to zero to avoid calling the UnlockBits method automatically.
            LockMode:
                Set of flags that specify whether the locked portion of the bitmap is available for reading or for writing and whether the caller has already allocated a buffer.
                Individual flags are defined in the ImageLockMode Enumeration. The default value is (ImageLockModeRead|ImageLockModeWrite).
            PixelFormat:
                Integer that specifies the format of the pixel data in the temporary buffer.
                The pixel format of the temporary buffer does not have to be the same as the pixel format of this Bitmap object.
                For more information about pixel format constants, see Image Pixel Format Constants.
                GDI+ version 1.0 does not support processing of 16-bits-per-channel images, so you should not set this parameter equal to PixelFormat48bppRGB, PixelFormat64bppARGB, or PixelFormat64bppPARGB.
        Return value:
            If the method succeeds, the return value is «BitmapData», or a BitmapData object if «BitmapData» is omited.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    LockBits(Rect := 0, BitmapData := 0, LockMode := 3, PixelFormat := 0x26200A)
    {
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapLockBits", "Ptr", this, "Ptr", Rect?ToRect(Rect):Rect(0,0,this.Width,this.Height)
            , "UInt", LockMode, "Int", PixelFormat, "Ptr", BitmapData:=(BitmapData||Gdiplus.BitmapData(this))))
              ? 0           ; Error.
              : BitmapData  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-lockbits

    /*
        Unlocks a portion of this bitmap that was previously locked by a call to the LockBits method.
        Parameters:
            BitmapData:
                A BitmapData object that was previously passed or returned by the LockBits method.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If when calling the LockBits method, the «BitmapData» parameter was omitted, it is not necessary to call this method.
            - This method is automatically called when the last reference to the BitmapData object returned by the LockBits method is destroyed.
    */
    UnlockBits(BitmapData)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapUnlockBits", "Ptr", this, "Ptr", BitmapData))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-unlockbits

    /*
        Gets the color of a specified pixel in this bitmap.
        Parameters:
            X / Y:
                Integer that specifies the x/y-coordinate (column/row) of the pixel.
        Return value:
            Returns the ARGB color of the specified pixel.
        Remarks:
            Depending on the format of the bitmap, this method might not return the same value as was set by the SetPixel method.
            For example, if you call the SetPixel method on a Bitmap object whose pixel format is 32bppPARGB, the RGB components are premultiplied.
            - A subsequent call to this method might return a different value because of rounding.
    */
    GetPixel(X, Y)
    {
        local Color := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapGetPixel", "Ptr", this, "Int", X, "Int", Y, "UIntP", Color)
        return Color
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-getpixel

    /*
        Sets the color of a specified pixel in this bitmap.
        Parameters:
            Color:
                Specifies the ARGB color to set.
            X / Y:
                Integer that specifies the x/y-coordinate (column/row) of the pixel.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If you call this method on a Bitmap whose color depth is 16 bits per pixel, information could be lost in the conversion from 32 to 16 bits,
            - and a subsequent call to the GetPixel method might return a different value.
    */
    SetPixel(Color, X, Y)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapSetPixel", "Ptr", this, "Int", X, "Int", Y, "UInt", Color))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-setpixel

    /*
        Sets the resolution of this Bitmap object.
        Parameters:
            DpiX / DpiY:
                Real number that specifies the horizontal/vertical resolution in dots per inch.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetResolution(DpiX, DpiY)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapSetResolution", "Ptr", this, "Float", DpiX, "Float", DpiY))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-setresolution

    /*
        Alters this Bitmap object by applying a specified effect.
        Parameters:
            Effect:
                An instance of a descendant of the Effect class.
                The descendant (for example, a Effect::Blur object) specifies the effect that is applied.
            Rect:
                Specifies a rectangle with the portion of the input bitmap to which the effect is applied.
                If this parameter is zero, the effect applies to the entire input bitmap.
        Return value:
            If the method succeeds, the return value is «Effect».
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    ApplyEffect(Effect, Rect := 0)
    {
        local AuxData := 0, AuxDataSize := 0
        if (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapApplyEffect",  "Ptr", this, "Ptr", Effect.FreeAuxData(), "Ptr", ToRect(Rect)
                                                                             ,  "Int", Effect.UseAuxData, "UPtrP", AuxData, "IntP", AuxDataSize))
            return 0
        Effect.SetAuxData(AuxData, AuxDataSize)
        return Effect
    } ; https://docs.microsoft.com/en-us/previous-versions//ms536321(v=vs.85)

    /*
        Creates a new Bitmap object by applying a specified effect to this Bitmap object.
        Parameters:
            Effect:
                An instance of a descendant of the Effect class.
                The descendant (for example, a Blur object) specifies the effect that is applied.
            Rect:
                Specifies a rectangle with the portion of the input bitmap that is used.
                If this parameter is zero, the effect applies to the entire input bitmap.
            OutRect:
                Specifies a rectangle that receives the portion of the input bitmap that was used.
                If the rectangle specified by «Rect» lies entirely within the input bitmap, the rectangle returned in «OutRect» is the same as «Rect».
                If part of rectangle specified by «Rect» lies outside the input bitmap, then the rectangle returned in «OutRect» is the portion of «Rect» that lies within the input bitmap.
                This parameter is optional and can be zero if you do not want to receive the output rectangle.
        Return value:
            If the method succeeds, the return value is a new Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    ApplyEffect2(Effect, Rect := 0, OutRect := 0)
    {
        local pBitmap := 0, AuxData := 0, AuxDataSize := 0
        if (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipBitmapCreateApplyEffect", "PtrP", this.Ptr, "Int", 1, "Ptr", Effect.FreeAuxData()
            , "Ptr", ToRect(Rect), "Ptr", OutRect, "UPtrP", pBitmap, "Int", Effect.UseAuxData, "UPtrP", AuxData, "IntP", AuxDataSize))
            return 0
        Effect.SetAuxData(AuxData, AuxDataSize)
        return Gdiplus.Bitmap.New(pBitmap)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-applyeffect(inbitmap_inint_ineffect_inrect_outrect_outbitmap)

    /*
        Alters this Bitmap object by applying a pixelate effect. See the Pixelate2 method.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Pixelate(BlockSize, Rect := 0)
    {
        return !!Gdiplus.SwapPtr(this, this.Pixelate2(BlockSize,Rect))
    }

    /*
        Creates a new Bitmap object by applying pixelate effect to this Bitmap object.
        Return value:
            If the method succeeds, the return value is a new Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Pixelate2(BlockSize, Rect := 0)
    {
        Rect := Rect ? ToRect(Rect) : Rect(0,0,this.Width,this.Height)
        if (BlockSize<1 || BlockSize>Rect.W || BlockSize>Rect.H)
            return !(Gdiplus.LastStatus := 2)  ; InvalidParameter.
        local PixelatedBitmap := this.Clone()
        local BitmapDataSrc   := this.LockBits(Rect)             ; Source.
        local BitmapDataDst   := PixelatedBitmap.LockBits(Rect)  ; Dest.
        DllCall(Gdiplus_GdipBitmapPixelate, "Ptr", BitmapDataSrc.Scan0, "Ptr", BitmapDataDst.Scan0, "Int", Rect.W, "Int", Rect.H, "Int", BitmapDataSrc.Stride, "Int", BlockSize)
        return (Gdiplus.LastStatus := 0) || PixelatedBitmap
    }

    /*
        Rotates this bitmap given a specific angle. See the Rotate2 method.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Rotate(Angle, InterpolationMode := 0, ImageAttributes := 0)
    {
        return !!Gdiplus.SwapPtr(this, this.Rotate2(Angle,InterpolationMode,ImageAttributes))
    }

    /*
        Creates a new Bitmap object by rotating this Bitmap object given a specific angle.
        Return value:
            If the method succeeds, the return value is a new Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Rotate2(Angle, InterpolationMode := 0, ImageAttributes := 0)
    {
        local Rotated  := Gdiplus.Image.GetRotatedDimTrans(this.Width, this.Height, Angle)
        local Graphics := Gdiplus.Graphics(Gdiplus.Bitmap(Rotated.Dimension.W,Rotated.Dimension.H))
        if (!Graphics)
            return 0
        Graphics.InterpolationMode := InterpolationMode
        return Graphics.TranslateTransform(Rotated.Translation[1], Rotated.Translation[2])
            && Graphics.RotateTransform(Angle)
            && Graphics.DrawImage2(this, Rotated.Size,, ImageAttributes)
            && Graphics.ResetTransform()
            && Graphics.Image  ; Rotated bitmap.
    }

    /*
        Resizes this bitmap. See the Resize2 method.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Resize(Width, Height, InterpolationMode := 0, ImageAttributes := 0)
    {
        return !!Gdiplus.SwapPtr(this, this.Resize2(Width,Height,InterpolationMode,ImageAttributes))
    }

    /*
        Creates a new Bitmap object by resizing this Bitmap object.
        Return value:
            If the method succeeds, the return value is a new Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Return value:
            If the method succeeds, the return value is a new Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If the interpolation mode is set to another value than the default one (LowQuality), an unwanted border may appear when resizing the image.
            To 'fix' this, you can pass an ImageAttributes object with the wrap mode set to TileFlipXY.
            Reference: <https://stackoverflow.com/questions/1890605/ghost-borders-ringing-when-resizing-in-gdi>.
    */
    Resize2(Width, Height, InterpolationMode := 0, ImageAttributes := 0)
    {
        local Dimension := this.Dimension
        Width  := Width  == "" ? Dimension.W / ( Dimension.H / Height ) : Width
        Height := Height == "" ? Dimension.H / ( Dimension.W / Width  ) : Height
        local Graphics := Gdiplus.Graphics(Gdiplus.Bitmap(Width,Height))
        if (!Graphics)
            return 0
        Graphics.InterpolationMode := InterpolationMode
        return Graphics.DrawImage2(this,, Dimension, ImageAttributes)
            && Graphics.Image
    }

    Crop(X, Y, Width, Height, InterpolationMode := 0, ImageAttributes := 0)
    {
        return !!Gdiplus.SwapPtr(this, this.Crop2(X,Y,Width,Height,InterpolationMode,ImageAttributes))
    }

    Crop2(X, Y, Width, Height, InterpolationMode := 0, ImageAttributes := 0)
    {
        local Graphics := Gdiplus.Graphics(Gdiplus.Bitmap(Width,Height))
        if (!Graphics)
            return 0
        Graphics.InterpolationMode := InterpolationMode
        return Graphics.DrawImage2(this,, RectF(X,Y,Width,Height), ImageAttributes)
            && Graphics.Image
    }

    /*
        Finds the color of a pixel and returns the coordinates.
        Parameters:
            Color:
                Specifies the ARGB color to look for.
        Return value:
            If the method succeeds, the return value is a IPoint object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    FindPixel(Color, Rect := 0)
    {
        local X := 0, Y := 0, BitmapData := this.LockBits(Rect:=(Rect?ToRect(Rect):Rect(0,0,this.Width,this.Height)))
        return (Gdiplus.LastStatus := DllCall(Gdiplus_GdipBitmapFindPixel, "Ptr", BitmapData.Scan0, "Int", Rect.W, "Int", Rect.H, "Int", BitmapData.Stride, "UInt", Color, "IntP", X, "IntP", Y))
             ? 0           ; Error.
             : Point(X,Y)  ; Ok.
    } ; https://autohotkey.com/board/topic/79077-gdip-pixelsearch/

    /*
        Gets the number of pixels that match the specified color.
        Parameters:
            Color:
                Specifies the ARGB color to look for.
        Return value:
            Returns the number of pixels that match the specified color.
    */
    CountPixel(Color, Rect := 0)
    {
        local BitmapData := this.LockBits(Rect:=(Rect?ToRect(Rect):Rect(0,0,this.Width,this.Height)))
        return DllCall(Gdiplus_GdipBitmapCountPixel, "Ptr", BitmapData.Scan0, "Int", Rect.W, "Int", Rect.H, "Int", BitmapData.Stride, "UInt", Color, "UInt64")
    } ; https://autohotkey.com/board/topic/79077-gdip-pixelsearch/

    /*
        Gets the coordinates of all pixels that match the specified color.
        Parameters:
            Color:
                Specifies the ARGB color to look for.
        Return value:
            Returns an array of points.
    */
    FindPixels(Color, Rect := 0, Point := 0)
    {
        Point := Point || PointAlloc(this.CountPixel(Color,Rect))
        local BitmapData := this.LockBits(Rect:=(Rect?ToRect(Rect):Rect(0,0,this.Width,this.Height)))
        DllCall(Gdiplus_GdipBitmapFindPixels, "Ptr", BitmapData.Scan0, "Int", Rect.W, "Int", Rect.H, "Int", BitmapData.Stride, "UInt", Color, "Ptr", Point)
        return Point
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a Bitmap object based on an array of bytes along with size and format information.
    Parameters:
        Width / Height:
            Integer that specifies the width/height, in pixels, of the bitmap.
        Stride:
            Integer that specifies the byte offset between the beginning of one scan line and the next.
            This is usually (but not necessarily) the number of bytes in the pixel format (for example, 2 for 16 bits per pixel) multiplied by the width of the bitmap.
            The value passed to this parameter must be a multiple of four.
        Format:
            Integer that specifies the pixel format of the bitmap. The default value is PixelFormat32bppARGB.
            For more information about pixel format constants, see Image Pixel Format Constants.
        PixelData:
            An array of bytes that contains the pixel data.
            This parameter must be a memory address or a Buffer-like object.
            The caller is responsible for allocating and freeing the block of memory pointed to by this parameter.
    Return value:
        If the method succeeds, the return value is a Bitmap object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Bitmap(Width, Height, Stride := 0, Format := 0x0026200A, PixelData := 0)
{
    local pBitmap := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", Width, "Int", Height, "Int", Stride, "UInt", Format, "Ptr", PixelData, "UPtrP", pBitmap)
    return Gdiplus.Bitmap.New(pBitmap)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(int_int_int_pixelformat_byte)
