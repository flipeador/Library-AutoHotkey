#DllLoad Gdiplus.dll  ; Loads Gdiplus.dll before the script starts executing (to improve performance).

#Include Functions\GdipBitmapCountPixel.ahk
#Include Functions\GdipBitmapFindPixel.ahk
#Include Functions\GdipBitmapFindPixels.ahk
#Include Functions\GdipBitmapPixelate.ahk





/*
    Wraps the functions in the GDI+ flat API for ease of use. Also provides additional functionality using machine code.

    Gdiplus Flat API:
        https://docs.microsoft.com/es-es/windows/desktop/gdiplus/-gdiplus-flatapi-flat

    Gdiplus Classes (C++):
        https://docs.microsoft.com/es-es/windows/desktop/gdiplus/-gdiplus-class-classes

    GdiplusBase Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbase/nl-gdiplusbase-gdiplusbase

    Memory Functions:
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-memory-flat

    Remarks:
        To start Gdiplus you must call the static method Gdiplus::Startup.
        You must call the static method Gdiplus::Shutdown after every successful call to the static method Gdiplus::Startup.
        -------------------------------------------------------------------------------------------
        An array of Point/Size/Rect/Color objects can be created using the Point(F)/Size(F)/Rect(F)/Color function.
        When a method expects a point in a parameter, use the Point/PointF function.
        When a method expects a rectangle in a parameter, use the Rect/RectF function.
        When a method expects a non-ahk array in a parameter, use the ArrayBlock function.
        -------------------------------------------------------------------------------------------
        Certain methods throw an exception if an error is detected with the parameters; Otherwise, Gdiplus.LastStatus is set to an error code of the Status Enumeration and the method returns zero.
        Normally dynamic properties do not set Gdiplus.LastStatus nor throw exceptions.
        -------------------------------------------------------------------------------------------
        Class objects are constructed by a function of the same name.
        For example, we use Gdiplus.Graphics() instead of Gdiplus.Graphics.New() to construct a Gdiplus::Graphics object.
        Additional constructors are static methods of the class object. For example, Gdiplus.Graphics.FromDC().
        -------------------------------------------------------------------------------------------
        Include this file in the Auto-execute Section of the script.

    Minimum requirements:
        AutoHotkey_L v2.0-a105-acb6f3cb.
        Windows XP with Service Pack 3.

    Thanks to:
        tariqporter (TIC) | https://autohotkey.com/boards/viewtopic.php?f=6&t=6517 | https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=60258
            - https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk
            - https://www.dropbox.com/s/0e9gdfetbfa8v0o/Gdip_All.ahk
*/
class GdiplusBase  ; https://github.com/flipeador
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static pToken              := 0  ; Token returned by function GdiplusStartup.
    static RefCount            := 0  ; Reference count.
    static Version             := 1  ; Specifies the version of GDI+. Must be 1.
    static LastStatus          := 0  ; Last status error code.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(*)
    {
        Gdiplus.LastStatus := 6  ; NotImplemented.
        throw Exception("0x00000006", -1, "Class GdiplusBase - This class object cannot be constructed.")
    }


    ; ===================================================================================================================
    ; PRIVATE STATIC METHODS
    ; ===================================================================================================================
    static MCode(x32, x64)
    {
        local Size := 0, Code := A_PtrSize == 4 ? x32 : x64
        DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", Code, "UInt", 0, "UInt", 1, "Ptr", 0, "UIntP", Size, "Ptr", 0, "Ptr", 0)
        local Ptr := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0, "Ptr", Size, "Ptr")
        if (A_PtrSize == 8)
            DllCall("Kernel32.dll\VirtualProtect", "Ptr", Ptr, "Ptr", Size, "UInt", 0x40, "UIntP", 0)
        DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", Code, "UInt", 0, "UInt", 1, "Ptr", Ptr, "UIntP", Size, "Ptr", 0, "Ptr", 0)
        return Ptr
    } ; https://autohotkey.com/boards/viewtopic.php?t=32

    static SwapPtr(Obj1, Obj2)
    {
        if (!IsObject(Obj1) || !IsObject(Obj2))
            return 0
        local TmpPtr := Obj1.Ptr
        Obj1.Ptr := Obj2.Ptr
        Obj2.Ptr := TmpPtr
        return Obj1
    }


    ; ===================================================================================================================
    ; STATIC METHODS
    ; ===================================================================================================================
    /*
        Initializes Windows GDI+.
        Return value:
            Returns the current reference count.
        Remarks:
            This method must be called to start using Gdiplus, before making any other GDI+ calls.
            Method Shutdown must be called when you have finished using GDI+.
            An exception is thrown if an error occurs.
    */
    static Startup()
    {
        if (Gdiplus.RefCount == 0)
        {
            ; GdiplusStartupInput structure.
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput
            local GdiplusStartupInput := BufferAlloc(A_PtrSize==4?16:24, 0)
            NumPut("UInt", Gdiplus.Version, GdiplusStartupInput)  ; GdiplusStartupInput.GdiplusVersion.

            ; GdiplusStartup function.
            ; https://docs.microsoft.com/es-es/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
            local pToken := 0
            if (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdiplusStartup", "UPtrP", pToken, "Ptr", GdiplusStartupInput, "Ptr", 0, "UInt"))
                throw Exception(Format("0x{:08x}",Gdiplus.LastStatus), -1, "Could not start Gdiplus (Gdiplus.dll\GdiplusStartup).")
            Gdiplus.pToken := pToken
        }

        return ++Gdiplus.RefCount
    }

    /*
        Cleans up resources used by Windows GDI+.
        Return value:
            Returns the current reference count.
        Remarks:
            Each call to the Startup method should be paired with a call to this method.
    */
    static Shutdown()
    {
        if (Gdiplus.RefCount && !--Gdiplus.RefCount)
        {
            ; GdiplusShutdown function.
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusshutdown
            DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", Gdiplus.pToken)
            Gdiplus.pToken := 0
        }

        return Gdiplus.RefCount
    }

    /*
        Allocates memory for one Windows GDI+ object.
        Parameters:
            Size:
                The size, in bytes, of the object for which memory is to be allocated.
        Return value:
            This method returns a pointer to the object.
    */
    static Alloc(Size)
    {
        return DllCall("Gdiplus.dll\GdipAlloc", "Ptr", Size, "UPtr")
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbase/nf-gdiplusbase-gdiplusbase-operatornew

    /*
        Deallocates memory for one Windows GDI+ object.
        Parameters:
            Object:
                The object to be deallocated.
                This parameter must be a memory address or a Buffer-like object.
        Return value:
            This method does not return a value.
    */
    static Free(Object)
    {
        DllCall("Gdiplus.dll\GdipFree", "Ptr", Object, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbase/nf-gdiplusbase-gdiplusbase-operatordelete

    /*
        Retrieves an array of ImageCodecInfo objects that contain information about the available image encoders.
        Return value:
            If the method succeeds, the return value is an array of ImageCodecInfo objects. See the Gdip_BuildImageCodecInfo function.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static GetImageEncoders()
    {
        local NumEncoders := 0, Size := 0
        if Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetImageEncodersSize", "UIntP", NumEncoders, "UIntP", Size, "UInt")
            return 0

        local Buffer := BufferAlloc(Size)
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetImageEncoders", "UInt", NumEncoders, "UInt", Size, "Ptr", Buffer, "UInt")

        return Gdip_BuildImageCodecInfo(NumEncoders, Gdiplus.LastStatus?0:Buffer)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimagecodec/nf-gdiplusimagecodec-getimageencoders

    /*
        Retrieves an array of ImageCodecInfo objects that contain information about the available image decoders.
        Return value:
            If the method succeeds, the return value is an array of ImageCodecInfo objects. See the Gdip_BuildImageCodecInfo function.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    static GetImageDecoders()
    {
        local NumEncoders := 0, Size := 0
        if Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetImageDecodersSize", "UIntP", NumEncoders, "UIntP", Size, "UInt")
            return 0

        local Buffer := BufferAlloc(Size)
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetImageDecoders", "UInt", NumEncoders, "UInt", Size, "Ptr", Buffer, "UInt")

        return Gdip_BuildImageCodecInfo(NumEncoders, Gdiplus.LastStatus?0:Buffer)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimagecodec/nf-gdiplusimagecodec-getimagedecoders

    /*
        Receives the MIME type and/or file-name extension of an encoder and returns the ImageCodecInfo object of that encoder.
        Return value:
            If the method succeeds, the return value is a ImageCodecInfo object. See the Gdip_BuildImageCodecInfo function.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
            If this method returns zero and «Gdiplus.LastStatus» is zero, it indicates that the specified codec has not been found.
    */
    static GetImageEncoder(FileExt := "", MimeType := "")
    {
        local ImageCodecInfo
        for ImageCodecInfo in (Gdiplus.GetImageEncoders() || [])
            if (FileExt == "" || InStr(ImageCodecInfo.FilenameExtension,"*." . FileExt))
                if (MimeType == "" || !StrCompare(ImageCodecInfo.MimeType,MimeType))
                    return ImageCodecInfo
        return 0
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-retrieving-the-class-identifier-for-an-encoder-use
}





class Gdiplus extends GdiplusBase
{
    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    #Include Image.ahk         ; Extends GdiplusBase.
    #Include Bitmap.ahk        ; Extends Gdiplus::Image.
    #Include CachedBitmap.ahk  ; Extends Gdiplus::Image.

    #Include Graphics.ahk      ; Extends GdiplusBase.
    #Include GraphicsPath.ahk  ; Extends GdiplusBase.

    #Include FontFamily.ahk    ; Extends GdiplusBase.
    #Include Font.ahk          ; Extends GdiplusBase.
    #Include StringFormat.ahk  ; Extends GdiplusBase.

    #Include Brush.ahk                ; Extends GdiplusBase.
    #Include SolidBrush.ahk           ; Extends Gdiplus::Brush.
    #Include HatchBrush.ahk           ; Extends Gdiplus::Brush.
    #Include TextureBrush.ahk         ; Extends Gdiplus::Brush.
    #Include PathGradientBrush.ahk    ; Extends Gdiplus::Brush.
    #Include LinearGradientBrush.ahk  ; Extends Gdiplus::Brush.

    #Include Pen.ahk  ; Extends GdiplusBase.

    #Include Effect\Effect.ahk  ; Extends GdiplusBase.

    #Include Matrix.ahk  ; Extends GdiplusBase.

    #Include Region.ahk  ; Extends GdiplusBase.

    #Include ImageAttributes.ahk  ; Extends GdiplusBase.

    #Include Classes\ColorMatrix.ahk
    #Include Classes\EncoderParameters.ahk
    #Include Classes\BitmapData.ahk

    #Include Enumerations\BrushType.ahk
    #Include Enumerations\CombineMode.ahk
    #Include Enumerations\CompositingMode.ahk
    #Include Enumerations\CompositingQuality.ahk
    #Include Enumerations\EncoderParameterValueType.ahk
    #Include Enumerations\FillMode.ahk
    #Include Enumerations\FlushIntention.ahk
    #Include Enumerations\FontStyle.ahk
    #Include Enumerations\FrameDimension.ahk
    #Include Enumerations\HatchStyle.ahk
    #Include Enumerations\ImageFlags.ahk
    #Include Enumerations\ImageLockMode.ahk
    #Include Enumerations\ImageType.ahk
    #Include Enumerations\InterpolationMode.ahk
    #Include Enumerations\LinearGradientMode.ahk
    #Include Enumerations\MatrixOrder.ahk
    #Include Enumerations\PenAlignment.ahk
    #Include Enumerations\PixelOffsetMode.ahk
    #Include Enumerations\RotateFlipType.ahk
    #Include Enumerations\SmoothingMode.ahk
    #Include Enumerations\Status.ahk
    #Include Enumerations\StringAlignment.ahk
    #Include Enumerations\StringFormatFlags.ahk
    #Include Enumerations\StringTrimming.ahk
    #Include Enumerations\TextRenderingHint.ahk
    #Include Enumerations\Unit.ahk
    #Include Enumerations\WrapMode.ahk

    #Include Constants\ImageEncoder.ahk
    #Include Constants\PixelFormat.ahk
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
/*
    NOTE: This function will be removed and replaced by a class.
    An ImageCodecInfo object contains the following properties:
        Clsid, FormatID, CodecName, DllName, FormatDescription, FilenameExtension, MimeType, Flags, Version, SigCount, SigSize, SigPattern, SigSize.
    Clsid and FormatID are a memory address each 16 bytes long.
*/
Gdip_BuildImageCodecInfo(Count, Buffer)  ; Private.
{
    local sImageCodecInfo := 48 + 7*A_PtrSize  ; sizeof(ImageCodecInfo).
    local aImageCodecInfo := Array()           ; Array of ImageCodecInfo objects.

    loop (Buffer ? Count : 0)
    {
        local Offset   := sImageCodecInfo * (A_Index-1)
        local pDllName := NumGet(Buffer,32+A_PtrSize+Offset)  ; Can be a null pointer.
        aImageCodecInfo.Push({"Buffer"           : Buffer                    ; A reference of the buffer, to prevent it from being freed.
                            , "Clsid"            : Buffer.Ptr + Offset       ; Codec identifier.
                            , "FormatID"         : Buffer.Ptr + 16 + Offset  ; File format identifier. GUIDs that identify various file formats (ImageFormatBMP, ImageFormatEMF, and the like) are defined in Gdiplusimaging.h.
                            , "CodecName"        : StrGet(NumGet(Buffer,32+Offset))              ; Pointer to a null-terminated string that contains the codec name.
                            , "DllName"          : pDllName == 0 ? "" : StrGet(pDllName)         ; Pointer to a null-terminated string that contains the path name of the DLL in which the codec resides. If the codec is not in a DLL, this pointer is NULL.
                            , "FormatDescription": StrGet(NumGet(Buffer,32+2*A_PtrSize+Offset))  ; Pointer to a null-terminated string that contains the name of the file format used by the codec.
                            , "FilenameExtension": StrGet(NumGet(Buffer,32+3*A_PtrSize+Offset))  ; Pointer to a null-terminated string that contains all file-name extensions associated with the codec. The extensions are separated by semicolons.
                            , "MimeType"         : StrGet(NumGet(Buffer,32+4*A_PtrSize+Offset))  ; Pointer to a null-terminated string that contains the mime type of the codec.
                            , "Flags"            : NumGet(Buffer, 32+5*A_PtrSize+Offset, "UInt")    ; Combination of flags from the ImageCodecFlags enumeration.
                            , "Version"          : NumGet(Buffer, 36+5*A_PtrSize+Offset, "UInt")    ; Integer that indicates the version of the codec.
                            , "SigCount"         : NumGet(Buffer, 40+5*A_PtrSize+Offset, "UInt")    ; Integer that indicates the number of signatures used by the file format associated with the codec.
                            , "SigSize"          : NumGet(Buffer, 44+5*A_PtrSize+Offset, "UInt")    ; Integer that indicates the number of bytes in each signature.
                            , "SigPattern"       : NumGet(Buffer, 48+5*A_PtrSize+Offset, "UPtr")    ; Pointer to an array of bytes that contains the pattern for each signature.
                            , "SigSize"          : NumGet(Buffer, 48+6*A_PtrSize+Offset, "UPtr")})  ; Pointer to an array of bytes that contains the mask for each signature.
    }

    return Buffer ? aImageCodecInfo : 0
} ; https://docs.microsoft.com/en-us/previous-versions/ms534466(v=vs.85)
