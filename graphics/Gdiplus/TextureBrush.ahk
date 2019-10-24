/*
    The TextureBrush class defines a Brush object that contains an Image object that is used for the fill.
    The fill image can be transformed by using the local Matrix object contained in the Brush object.

    TextureBrush Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nl-gdiplusbrush-texturebrush

    TextureBrush Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-texturebrush-flat
*/
class TextureBrush extends Gdiplus.Brush
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Gets the transformation matrix of this texture brush.
        Return value:
            If the method succeeds, the return value is a Matrix object that receives the transformation matrix.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetTransform()
    {
        local pMatrix := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetTextureTransform", "Ptr", this, "UPtrP", pMatrix)
        return Gdiplus.Matrix.New(pMatrix)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-gettransform

    /*
        Sets the transformation matrix of this texture brush.
        Parameters:
            Matrix:
                A Matrix object that specifies the transformation matrix to use.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetTransform(Matrix)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetTextureTransform", "Ptr", this, "Ptr", Matrix))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-settransform

    /*
        Resets the transformation matrix of this texture brush to the identity matrix. This means that no transformation takes place.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    ResetTransform()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipResetTextureTransform", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-resettransform

    /*
        Updates this brush's transformation matrix with the product of itself and another matrix.
        Parameters:
            Matrix:
                The matrix to be multiplied by this brush's current transformation matrix.
            MatrixOrder:
                Element of the MatrixOrder Enumeration that specifies the order of multiplication. The default value is MatrixOrderPrepend.
                MatrixOrderPrepend specifies that the passed matrix is on the left.
                MatrixOrderAppend specifies that the passed matrix is on the right.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    MultiplyTransform(Matrix, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipMultiplyTextureTransform", "Ptr", this, "Ptr", Matrix, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-multiplytransform

    /*
        Updates this brush's current transformation matrix with the product of itself and a translation matrix.
        Parameters:
            X / Y:
                Real number that specifies the horizontal/vertical component of the translation.
            MatirxOrder:
                Element of the MatrixOrder enumeration that specifies the order of the multiplication. The default value is MatrixOrderPrepend.
                MatrixOrderPrepend specifies that the translation matrix is on the left.
                MatrixOrderAppend specifies that the translation matrix is on the right.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    TranslateTransform(X, Y, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipTranslateTextureTransform", "Ptr", this, "Float", X, "Float", Y, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-translatetransform

    /*
        Updates this texture brush's current transformation matrix with the product of itself and a scaling matrix.
        Parameters:
            SX / SY:
                Real number that specifies the amount to scale in the X/Y direction.
            MatrixOrder:
                Element of the MatrixOrder enumeration that specifies the order of the multiplication. The default value is MatrixOrderPrepend.
                MatrixOrderPrepend specifies that the scaling matrix is on the left.
                MatrixOrderAppend specifies that the scaling matrix is on the right.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    ScaleTransform(SX, SY, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipScaleTextureTransform", "Ptr", this, "Float", SX, "Float", SY, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-scaletransform

    /*
        Updates this texture brush's current transformation matrix with the product of itself and a rotation matrix.
        Parameters:
            Angle:
                Real number that specifies the angle, in degrees, of rotation.
            MatrixOrder:
                Element of the MatrixOrder enumeration that specifies the order of the multiplication. The default value is MatrixOrderPrepend.
                MatrixOrderPrepend specifies that the rotation matrix is on the left.
                MatrixOrderAppend specifies that the rotation matrix is on the right.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    RotateTransform(Angle, MatrixOrder := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipRotateTextureTransform", "Ptr", this, "Float", Angle, "Int", MatrixOrder))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-rotatetransform


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the wrap mode of this texture brush.
    */
    WrapMode[]
    {
        get {
            local WrapMode := 0
            DllCall("Gdiplus.dll\GdipGetTextureWrapMode", "Ptr", this, "IntP", WrapMode)
            return WrapMode
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-getwrapmode
        set => DllCall("Gdiplus.dll\GdipSetTextureWrapMode", "Ptr", this, "Int", Value)
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-setwrapmode
    }

    /*
        Gets the Image object that is defined by this texture brush.
    */
    Image[]
    {
        get {
            local pImage := 0
            DllCall("Gdiplus.dll\GdipGetTextureImage", "Ptr", this, "UPtrP", pImage)
            return Gdiplus.Bitmap.New(pImage)
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-getimage
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a TextureBrush object based on an image, a wrap mode, and optionally a defining set of coordinates.
    If coordinates are omitted, the size of the brush defaults to the size of the image, so the entire image is used by the brush.
    Parameters:
        Image:
            An Image object that contains the bitmap of the image to use.
        WrapMode:
            Specifies how repeated copies of an image are used to tile an area when it is painted with this texture brush.
            This parameter must be a value from the WrapMode Enumeration. The default value is WrapModeTile.
            ------------------------------------------------------------------------------
            This parameter can be a ImageAttributes object that contains properties of the image. Can be NULL: {Ptr:0}.
        X / Y / W / H:
            Leftmost coordinate of the image portion to be used by this brush.
            Uppermost coordinate of the image portion to be used by this brush.
            Width of the brush and width of the image portion to be used by the brush.
            Height of the brush and height of the image portion to be used by the brush.
            ------------------------------------------------------------------------------
            Parameter «X» can be a IRect(F) object; in which case Y, W and H are ignored.
    Return value:
        If the method succeeds, the return value is a TextureBrush object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static TextureBrush(Image, WrapMode := 0, X := "", Y := 0, W := 1, H := 1)
{
    local pTextureBrush := 0
    switch Type(X)
    {
    case "IRect":
        if (IsObject(WrapMode))
            ; Creates a TextureBrush object based on an image, a defining rectangle (Integer), and a set of image properties.
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-texturebrush(inimage_inconstrectf__inconstimageattributes)
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTextureIAI", "Ptr", Image, "Ptr", WrapMode, "Int", X.X, "Int", X.Y, "Int", X.W, "Int", X.H, "UPtrP", pTextureBrush)
        else
            ; Creates a TextureBrush object based on an image, a wrap mode, and a defining set of coordinates (Integer).
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-texturebrush(inimage_inwrapmode_inint_inint_inint_inint)
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTexture2I", "Ptr", Image, "Int", WrapMode, "Int", X.X, "Int", X.Y, "Int", X.W, "Int", X.H, "UPtrP", pTextureBrush)
    case "IRectF":
        if (IsObject(WrapMode))
            ; Creates a TextureBrush object based on an image, a defining rectangle (Float), and a set of image properties.
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-texturebrush(inimage_inconstrectf__inconstimageattributes)
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTextureIA", "Ptr", Image, "Ptr", WrapMode, "Float", X.X, "Float", X.Y, "Float", X.W, "Float", X.H, "UPtrP", pTextureBrush)
        else
            ; Creates a TextureBrush object based on an image, a wrap mode, and a defining set of coordinates (Float).
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-texturebrush(inimage_inwrapmode_inreal_inreal_inreal_inreal)
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTexture2", "Ptr", Image, "Int", WrapMode, "Float", X.X, "Float", X.Y, "Float", X.W, "Float", X.H, "UPtrP", pTextureBrush)
    default:
        if (IsObject(WrapMode))
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTextureIA", "Ptr", Image, "Ptr", WrapMode, "Float", X, "Float", Y, "Float", W, "Float", H, "UPtrP", pTextureBrush)
        else {
            if (X == "")
                ; Creates a TextureBrush object based on an image and a wrap mode. The size of the brush defaults to the size of the image, so the entire image is used by the brush.
                ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-texturebrush(inimage_inwrapmode)
                Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTexture", "Ptr", Image, "Int", WrapMode, "UPtrP", pTextureBrush)
            else
                ; Creates a TextureBrush object based on an image, a wrap mode, and a defining set of coordinates (Float).
                ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusbrush/nf-gdiplusbrush-texturebrush-texturebrush(inimage_inwrapmode_inreal_inreal_inreal_inreal)
                Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateTexture2", "Ptr", Image, "Int", WrapMode, "Float", X, "Float", Y, "Float", W, "Float", H, "UPtrP", pTextureBrush)
        }
    }
    return Gdiplus.TextureBrush.New(pTextureBrush)
}
