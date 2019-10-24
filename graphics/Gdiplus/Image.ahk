/*
    The Image class provides methods for loading and saving raster images (bitmaps) and vector images (metafiles).
    An Image object encapsulates a bitmap or a metafile and stores attributes that you can retrieve by calling various Get methods.
    You can construct Image objects from a variety of file types including BMP, ICON, GIF, JPEG, Exif, PNG, TIFF, WMF, and EMF.

    Image Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nl-gdiplusheaders-image

    Image Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-image-flat

    Using Image Encoders and Decoders:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-using-image-encoders-and-decoders-use
*/
class Image extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Ptr)
            DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-image-flat


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    static GetRotatedDimension(Width, Height, Angle)
    {
        return SizeF(Abs(Width*Cos(Angle*=(Acos(-1)/180)))+Abs(Height*Sin(Angle))
                   , Abs(Width*Sin(Angle))+Abs(Height*Cos(Angle)))
    } ; https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk

    static GetRotatedTranslation(Width, Height, Angle)
    {
        local Bound := Angle>=0 ? Mod(Angle,360) : 360-Mod(-Angle,-360)
        Angle *= (Acos(-1) / 180)
        return Bound >=   0 && Bound <=  90 ? [(Height*Sin(Angle))                   ,                                       0]
             : Bound  >  90 && Bound <= 180 ? [(Height*Sin(Angle))-(Width*Cos(Angle)), -(Height*Cos(Angle))                   ]
             : Bound  > 180 && Bound <= 270 ? [                   -(Width*Cos(Angle)), -(Height*Cos(Angle))-(Width*Sin(Angle))]
             : Bound  > 270 && Bound <= 360 ? [                                     0,                     -(Width*Sin(Angle))]
             : 0
    } ; https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk

    static GetRotatedDimTrans(Width, Height, Angle)
    {
        return {Dimension  : Gdiplus.Image.GetRotatedDimension(Width,Height,Angle)
              , Translation: Gdiplus.Image.GetRotatedTranslation(Width,Height,Angle)
              , Size       : SizeF(Width,Height)
              , Angle      : Angle}
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Creates a new Image object and initializes it with the contents of this Image object.
        Return value:
            If the method succeeds, the return value is a new Bitmap object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pImage := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneImage", "Ptr", this, "UPtrP", pImage)
        return Gdiplus.Bitmap.New(pImage)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-clone

    /*
        Saves this image to a file or stream.
        Parameters:
            FileOrStream:
                If this parameter is a string, specifies the path name for the saved image.
                If this parameter is an integer, specifies a pointer to a IStream interface (COM).
                The implementation of IStream must include the Seek, Read, Write, and Stat methods.
            ClsidEncoder:
                A CLSID that specifies the encoder to use to save the image.
                This parameter must be a memory address or a Buffer-like object.
            EncoderParameters:
                A EncoderParameters object that holds parameters used by the encoder. This parameter can be zero.
                This parameter is used, for example, to specify the quality of JPG, JPEG, JPE or JFIF images (defaults to 75%).
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            GDI+ does not allow you to save an image to the same file that you used to construct the image.
            Do not save an image to the same stream that was used to construct the image. Doing so might damage the stream.
    */
    Save(FileOrStream, ClsidEncoder, EncoderParameters := 0)
    {
        if (Type(FileOrStream) == "String")
            ; https://docs.microsoft.com/en-us/previous-versions//ms535407(v=vs.85)
            return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSaveImageToFile", "Ptr", this, "Ptr", &FileOrStream, "Ptr", ClsidEncoder, "Ptr", EncoderParameters))
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-save(inistream_inconstclsid_inconstencoderparameters)
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSaveImageToStream", "Ptr", this, "Ptr", FileOrStream, "Ptr", ClsidEncoder, "Ptr", EncoderParameters))
    }

    /*
        Saves this image to a file.
        Parameters:
            FileName:
                A string that specifies the path name for the saved image.
                The default extension if not specified is JPG.
            Quality:
                Quality for JPG/JPEG/JPE/JFIF images. This value must be an integer between 0 and 100.
                A value of zero indicates the worst quality. A value of 100 indicates the best quality.
            ColorDepth:
                Color depth for TIFF images. This value can be 24 or 32.
            Compression:
                Compression for TIFF images.
                2    LZW compression.
                3    CCITT3 compression.
                4    CCITT4 compression.
                5    RLE compression.
                6    No compression.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SaveToFile(FileName, Quality := 100, ColorDepth := 24, Compression := 2)
    {
        local t, ImageCodecInfo, EncoderParameters := 0
        local FileExt := RegExMatch(FileName,"\.(\w+)$",t) ? t[1] : 0
        FileName := FileExt ? FileName : RTrim(FileName,".") . ".jpg"
        if (ImageCodecInfo := Gdiplus.GetImageEncoder(FileExt||"jpg"))
        {
            switch (ImageCodecInfo.MimeType)
            {
            case "image/jpeg":
                ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-setting-jpeg-compression-level-use
                EncoderParameters := Gdiplus.EncoderParameters(1)
                EncoderParameters[1].SetData(Gdiplus.EncoderQuality, 1, Gdiplus.EncoderParameterValueType.Long, BufferAlloc(4))
                NumPut("UInt", Quality>99?100:Quality<1?0:Quality, EncoderParameters[1].Value)
            case "image/tiff":
                EncoderParameters := Gdiplus.EncoderParameters(2)
                EncoderParameters[1].SetData(Gdiplus.EncoderColorDepth, 1, Gdiplus.EncoderParameterValueType.Long, BufferAlloc(4))
                NumPut("UInt", ColorDepth, EncoderParameters[1].Value)
                EncoderParameters[2].SetData(Gdiplus.EncoderCompression, 1, Gdiplus.EncoderParameterValueType.Long, BufferAlloc(4))
                NumPut("UInt", Compression, EncoderParameters[2].Value)
            }
        }
        return this.Save(FileName, ImageCodecInfo&&ImageCodecInfo.Clsid, EncoderParameters)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-save(inconstwchar_inconstclsid_inconstencoderparameters)

    /*
        Gets a list of the parameters supported by a specified image encoder.
        Parameters:
            ClsidEncoder:
                A CLSID that specifies the image encoder.
                This parameter must be a memory address or a Buffer-like object.
        Return value:
            If the method succeeds, the return value is a EncoderParameters object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetEncoderParameterList(ClsidEncoder)
    {
        local Buffer, Size := 0  ; The size, in bytes, of the parameter list for the specified image encoder.
        DllCall("Gdiplus.dll\GdipGetEncoderParameterListSize", "Ptr", this, "Ptr", ClsidEncoder, "UIntP", Size)
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetEncoderParameterList", "Ptr", this, "Ptr", ClsidEncoder, "UInt", Size, "Ptr", Buffer:=BufferAlloc(Size)))
             ? 0                                  ; Error.
             : Gdiplus.EncoderParameters(Buffer)  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getencoderparameterlist

    /*
        Selects the frame in this Image object specified by a dimension and an index.
        Parameters:
            DimensionID:
                A GUID that specifies the frame dimension. See Predefined multi-frame dimension IDs (Enumerations\FrameDimension.ahk).
                This parameter must be a memory address or a Buffer-like object.
            FrameIndex:
                Specifies the index of the frame within the specified frame dimension.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            When you call this method, all changes that you made to the previously active frame are discarded.
            If you want to retain changes that you make to a frame, call the Save method before you switch to a different frame.
            Among all the image formats currently supported by GDI+, the only formats that support multiple-frame images are GIF and TIFF.
            When you call this method on a GIF image, you should use FrameDimensionTime.
            When you call this method on a TIFF image, you should use FrameDimensionPage.
    */
    SelectActiveFrame(DimensionID, FrameIndex)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipImageSelectActiveFrame", "Ptr", this, "Ptr", DimensionID, "UInt", FrameIndex))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-selectactiveframe

    /*
        Gets the identifiers for the frame dimensions of this Image object.
        Return value:
            If the method succeeds, the return value is a Buffer object containing the identifiers (16 bytes each).
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            This method returns information about multiple-frame images, which come in two styles: multiple page and multiple resolution.
            A multiple-page image is an image that contains more than one image. Each page contains a single image (or frame). These pages (or images, or frames) are typically displayed in succession to produce an animated sequence, such as in an animated GIF file.
            A multiple-resolution image is an image that contains more than one copy of an image at different resolutions.
            Windows GDI+ can support an arbitrary number of pages (or images, or frames), as well as an arbitrary number of resolutions.
    */
    GetFrameDimensionsList()
    {
        local Buffer, Count := 0  ; The number of frame dimensions in this Image object.
        DllCall("Gdiplus.dll\GdipImageGetFrameDimensionsCount", "Ptr", this, "UIntP", Count)
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipImageGetFrameDimensionsList", "Ptr", this, "Ptr", Buffer:=BufferAlloc(Count*16), "UInt", Count))
             ? 0       ; Error.
             : Buffer  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getframedimensionslist

    /*
        Gets the number of frames in a specified dimension of this Image object.
        Parameters:
            DimensionID:
                A GUID that specifies the frame dimension. See Predefined multi-frame dimension IDs.
                This parameter must be a memory address or a Buffer-like object.
        Return value:
            Returns the number of frames in the specified dimension of this Image object.
    */
    GetFrameCount(DimensionID)
    {
        local Count := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipImageGetFrameCount", "Ptr", this, "Ptr", DimensionID, "UIntP", Count)
        return Count
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getframecount

    /*
        Gets a specified property item (piece of metadata) from this Image object.
        Parameters:
            PropID:
                Integer that identifies the property item to be retrieved.
        Return value:
            If the method succeeds, the return value is a Buffer object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetPropertyItem(PropID)
    {
        local Buffer, Size := 0
        DllCall("Gdiplus.dll\GdipGetPropertyItemSize", "Ptr", this, "UInt", PropID, "UIntP", Size)
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetPropertyItem", "Ptr", this, "UInt", PropID, "UInt", Size, "Ptr", Buffer:=BufferAlloc(Size)))
             ? 0       ; Error.
             : Buffer  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getpropertyitem

    /*
        Rotates and flips this image.
        Parameters:
            RotateFlipType:
                Specifies the type of rotation and the type of flip.
                This parameter must be a value from the RotateFlipType Enumeration.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    RotateFlip(RotateFlipType)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipImageRotateFlip", "Ptr", this, "Int", RotateFlipType))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-rotateflip

    /*
        Gets a globally unique identifier (GUID) that identifies the format of this Image object.
        Return value:
            If the method succeeds, the return value is a Buffer object containing a GUID (16 bytes).
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetRawFormat()
    {
        local GUID := BufferAlloc(16)
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetImageRawFormat", "Ptr", this, "Ptr", GUID))
             ? 0     ; Error.
             : GUID  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getrawformat


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the width, in pixels, of this image.
    */
    Width[]
    {
        get {
            local Width := 0
            DllCall("Gdiplus.dll\GdipGetImageWidth", "Ptr", this, "UIntP", Width)
            return Width
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getwidth
    }

    /*
        Gets the height, in pixels, of this image.
    */
    Height[]
    {
        get {
            local Height := 0
            DllCall("Gdiplus.dll\GdipGetImageHeight", "Ptr", this, "UIntP", Height)
            return Height
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getheight
    }

    /*
        Gets the width and height, in pixels, of this image.
        Returns a ISizeF object that contains the width and height of this image.
    */
    Dimension[]
    {
        get {
            local Width := 0, Height := 0
            DllCall("Gdiplus.dll\GdipGetImageDimension", "Ptr", this, "FloatP", Width, "FloatP", Height)
            return SizeF(Width, Height)
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getphysicaldimension
    }

    /*
        Gets the bounding rectangle for this image.
        Returns a IRectF object. The Unit property indicates the unit of measure for the bounding rectangle (Unit Enumeration).
        Remarks:
            The bounding rectangle for a metafile does not necessarily have (0,0) as its upper-left corner.
            The coordinates of the upper-left corner can be negative or positive, depending on the drawing commands that were issued during the recording of the metafile.
    */
    Bounds[]
    {
        get {
            local Unit := 0, RectF := RectF()
            DllCall("Gdiplus.dll\GdipGetImageBounds", "Ptr", this, "Ptr", RectF, "UIntP", Unit)
            RectF.Unit := Unit  ; Unit Enumeration.
            return RectF        ; IRectF object.
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getbounds
    }

    /*
        Gets the horizontal resolution, in dots per inch, of this image.
    */
    HorizontalResolution[]
    {
        get {
            local Resolution := 0
            DllCall("Gdiplus.dll\GdipGetImageHorizontalResolution", "Ptr", this, "FloatP", Resolution)
            return Resolution
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-gethorizontalresolution
    }

    /*
        Gets the vertical resolution, in dots per inch, of this image.
    */
    VerticalResolution[]
    {
        get {
            local Resolution := 0
            DllCall("Gdiplus.dll\GdipGetImageVerticalResolution", "Ptr", this, "FloatP", Resolution)
            return Resolution
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getverticalresolution
    }

    /*
        Gets the type of this Image object.
        Returns an element of the ImageType Enumeration that indicates the image type.
    */
    Type[]
    {
        get {
            local ImageType := 0
            DllCall("Gdiplus.dll\GdipGetImageType", "Ptr", this, "IntP", ImageType)
            return ImageType
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-gettype
    }

    /*
        Gets a set of flags that indicate certain attributes of this Image object.
        Returns an element of the ImageFlags Enumeration that holds a set of single-bit flags.
    */
    Flags[]
    {
        get {
            local Flags := 0
            DllCall("Gdiplus.dll\GdipGetImageFlags", "Ptr", this, "UIntP", Flags)
            return Flags
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getflags
    }

    /*
        Gets the pixel format of this Image object.
        Returns an integer that indicates the pixel format of this Image object.
        For more information about pixel format constants, see Image Pixel Format Constants.
    */
    PixelFormat[]
    {
        get {
            local PixelFormat := 0
            DllCall("Gdiplus.dll\GdipGetImagePixelFormat", "Ptr", this, "UIntP", PixelFormat)
            return PixelFormat
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-getpixelformat
    }

    /*
        Creates a Graphics object that is associated with this Image object.
    */
    Graphics[] => Gdiplus.Graphics(this)  ; Graphics object.
}
