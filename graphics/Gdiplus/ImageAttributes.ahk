/*
    An ImageAttributes object contains information about how bitmap and metafile colors are manipulated during rendering.
    An ImageAttributes object maintains several color-adjustment settings, including color-adjustment matrices, grayscale-adjustment matrices, gamma-correction values, color-map tables, and color-threshold values.

    ImageAttributes Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nl-gdiplusimageattributes-imageattributes

    ImageAttributes Functions:
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-imageattributes-flat
*/
class ImageAttributes extends GdiplusBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr := 0  ; Pointer to the object.


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
            DllCall("Gdiplus.dll\GdipDisposeImageAttributes", "Ptr", this)
    } ; https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-imageattributes-flat


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Makes a copy of this ImageAttributes object.
        Return value:
            If the method succeeds, the return value is a new ImageAttributes object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pImageAttributes := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneImageAttributes", "Ptr", this, "UPtrP", pImageAttributes)
        return Gdiplus.ImageAttributes.New(pImageAttributes)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-clone

    /*
        Sets the wrap mode of this ImageAttributes object.
        Parameters:
            WrapMode:
                Specifies how repeated copies of an image are used to tile an area.
                This parameter must be a value of the WrapMode Enumeration.
            Color:
                An ARGB color that specifies the color of pixels outside of a rendered image.
                This color is visible if the wrap mode is set to WrapModeClamp and the source rectangle passed to the Gdiplus::Graphics::DrawImage method is larger than the image itself.
                The default color is black 100% opaque.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetWrapMode(WrapMode, Color := 0xFF000000, Clamp := false)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetImageAttributesWrapMode", "Ptr", this, "Int", WrapMode, "UInt", Color, "Int", Clamp))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-setwrapmode
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates an ImageAttributes object.
    Return value:
        If the method succeeds, the return value is a ImageAttributes object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static ImageAttributes()
{
    local pImageAttributes := 0
    Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateImageAttributes", "UPtrP", pImageAttributes)
    return Gdiplus.ImageAttributes.New(pImageAttributes)
} ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusimageattributes/nf-gdiplusimageattributes-imageattributes-imageattributes(constimageattributes_)
