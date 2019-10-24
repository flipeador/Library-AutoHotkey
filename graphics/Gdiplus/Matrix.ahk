/*
    A Matrix object represents a 3×3 matrix that, in turn, represents an affine transformation.
    A Matrix object stores only six of the 9 numbers in a 3×3 matrix because all 3×3 matrices that represent affine transformations have the same third column (0,0,1).

    Matrix Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nl-gdiplusmatrix-matrix

    Matrix Functions:
        https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-matrix-flat

    MatrixOrder Enumeration:
        The MatrixOrder enumeration specifies the order of multiplication when a new matrix is multiplied by an existing matrix.
        0  MatrixOrderPrepend    Specifies that the new matrix is on the left and the existing matrix is on the right.
        1  MatrixOrderAppend     Specifies that the existing matrix is on the left and the new matrix is on the right.
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
*/
class Matrix extends GdiplusBase
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
            DllCall("Gdiplus.dll\GdipDeleteMatrix", "Ptr", this)
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-matrix-flat


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Creates a new Matrix object that is a copy of this Matrix object.
        Return value:
            If the method succeeds, the return value is a Matrix object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    Clone()
    {
        local pMatrix := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCloneMatrix", "Ptr", this, "UPtrP", pMatrix)
        return Gdiplus.Matrix.New(pMatrix)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-clone

    /*
        Gets the elements of this matrix.
        The elements are placed in an array in the order m11, m12, m21, m22, m31, m32, where mij denotes the element in row i, column j.
        Return value:
            If the method succeeds, the return value is an array of 6 real numbers.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetElements()
    {
        local Elements := ArrayBlock(6, "Float")
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetMatrixElements", "Ptr", this, "Ptr", Elements))
             ? 0         ; Error.
             : Elements  ; Ok.
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-getelements

    /*
        Sets the elements of this matrix.
        Parameters:
            m11 / m12:
                Real number that specifies the element in the first row, first/second column.
            m21 / m22:
                Real number that specifies the element in the second row, first/second column.
            m31 / m32:
                Real number that specifies the element in the third row, first/second column.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetElements(m11, m12, m21, m22, m31, m32)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetMatrixElements", "Ptr", this, "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", m31, "Float", m32))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-setelements

    /*
        Updates this matrix with the product of itself and another matrix.
        Parameters:
            Matrix:
                A Matrix object that will be multiplied by this matrix.
            Order:
                Specifies the order of the multiplication.
                MatrixOrderPrepend specifies that the passed matrix is on the left.
                MatrixOrderAppend specifies that the passed matrix is on the right.
                This parameter must be a value from the MatrixOrder Enumeration. The default value is MatrixOrderPrepend.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Multiply(Matrix, Order := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipMultiplyMatrix", "Ptr", this, "Ptr", Matrix, "Int", Order))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-multiply

    /*
        Updates this matrix with the product of itself and a translation matrix.
        Parameters:
            OffsetX / OffsetY:
                Real number that specifies the horizontal/vertical component of the translation.
            Order:
                Specifies the order of the multiplication.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Translate(OffsetX, OffsetY, Order := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipTranslateMatrix", "Ptr", this, "Float", OffsetX, "Float", OffsetY, "Int", Order))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-translate

    /*
        Updates this matrix with the product of itself and a scaling matrix.
        Parameters:
            ScaleX / ScaleY:
                Real number that specifies the horizontal/vertical scale factor.
            Order:
                Specifies the order of the multiplication.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Scale(ScaleX, ScaleY, Order := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipScaleMatrix", "Ptr", this, "Float", ScaleX, "Float", ScaleY, "Int", Order))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-scale

    /*
        Updates this matrix with the product of itself and a rotation matrix.
        Parameters:
            Angle:
                Real number that specifies the angle of rotation in degrees. Positive values specify clockwise rotation.
            Order:
                Specifies the order of the multiplication.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Rotate(Angle, Order := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipRotateMatrix", "Ptr", this, "Float", Angle, "Int", Order))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-rotate

    /*
        Updates this matrix with the product of itself and a shearing matrix.
        Parameters:
            ShearX / ShearY:
                Real number that specifies the horizontal/vertical shear factor.
            Order:
                Specifies the order of the multiplication.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    Shear(ShearX, ShearY, Order := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipShearMatrix", "Ptr", this, "Float", ShearX, "Float", ShearY, "Int", Order))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-shear

    /*
        Replaces the elements of this matrix with the elements of its inverse.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
        Remarks:
            If this matrix is not invertible, the method fails and Gdiplus.LastStatus is set to InvalidParameter.
    */
    Invert()
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipInvertMatrix", "Ptr", this))
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-invert

    /*
        Multiplies each point in an array by this matrix. Each point is treated as a row matrix.
        The multiplication is performed with the row matrix on the left and this matrix on the right.
        Parameters:
            Point:
                Specifies an array of points.
                On input, contains the points to be transformed. On output, receives the transformed points.
                Each point in the array is transformed (multiplied by this matrix) and updated with the result of the transformation.
            Count:
                Integer that specifies the number of points to be transformed. The default value is 1.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    TransformPoints(Point, Count := 1)
    {
        return Point is IPoint
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipTransformMatrixPointsI", "Ptr", this, "Ptr", Point, "Int", Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipTransformMatrixPoints", "Ptr", this, "Ptr", Point, "Int", Count))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535321(v=vs.85)

    /*
        Multiplies each vector in an array by this matrix. The translation elements of this matrix (third row) are ignored.
        Each vector is treated as a row matrix. The multiplication is performed with the row matrix on the left and this matrix on the right.
        Parameters:
            Point:
                Specifies an array of points.
                On input, contains the vectors to be transformed. On output, receives the transformed vectors.
                Each vector in the array is transformed (multiplied by this matrix) and updated with the result of the transformation.
                This parameter can be a IPoint(F) object or a Buffer-like object containing an array of floats.
            Count:
                Integer that specifies the number of points to be transformed. The default value is 1.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    TransformVectors(Point, Count := 1)
    {
        return Point is IPoint
             ? !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipVectorTransformMatrixPointsI", "Ptr", this, "Ptr", Point, "Int", Count))
             : !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipVectorTransformMatrixPoints", "Ptr", this, "Ptr", Point, "Int", Count))
    } ; https://docs.microsoft.com/en-us/previous-versions//ms535319(v=vs.85)

    /*
        Determines whether the elements of this matrix are equal to the elements of another matrix.
        Parameters:
            Matrix:
                A Matrix object that is compared with this Matrix object.
        Return value:
            If the elements of the two matrices are the same, this method returns TRUE; otherwise, it returns FALSE.
    */
    Equals(Matrix)
    {
        local bool := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipIsMatrixEqual", "Ptr", this, "Ptr", Matrix, "IntP", bool)
        return bool
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-equals


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Same as methods GetElements and SetElements.
    */
    Elements[]
    {
        get => this.GetElements()
        set => this.SetElements(Value[1], Value[2], Value[3], Value[4], Value[5], Value[6])
    }

    /*
        Gets or sets the horizontal translation value of this matrix, which is the element in row 3, column 1.
        Return value:
            Returns the horizontal translation value of this matrix, which is the element in row 3, column 1.
    */
    OffsetX[]
    {
        get {
            local Elements := BufferAlloc(6*4)
            DllCall("Gdiplus.dll\GdipGetMatrixElements", "Ptr", this, "Ptr", Elements)
            return NumGet(Elements, 16, "Float")  ; m31.
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-offsetx
        set {
            local Elements := BufferAlloc(6*4)
            DllCall("Gdiplus.dll\GdipGetMatrixElements", "Ptr", this, "Ptr", Elements)
            DllCall("Gdiplus.dll\GdipSetMatrixElements", "Ptr", this, "Float", NumGet(Elements,  0, "Float")   ; m11.
                                                                    , "Float", NumGet(Elements,  4, "Float")   ; m12.
                                                                    , "Float", NumGet(Elements,  8, "Float")   ; m21.
                                                                    , "Float", NumGet(Elements, 12, "Float")   ; m22.
                                                                    , "Float", Value                           ; m31.
                                                                    , "Float", NumGet(Elements, 20, "Float"))  ; m32.
        }
    }

    /*
        Gets or sets the vertical translation value of this matrix, which is the element in row 3, column 2.
        Return value:
            This method returns the vertical translation value of this matrix, which is the element in row 3, column 2.
    */
    OffsetY[]
    {
        get {
            local Elements := BufferAlloc(6*4)
            DllCall("Gdiplus.dll\GdipGetMatrixElements", "Ptr", this, "Ptr", Elements)
            return NumGet(Elements, 20, "Float")  ; m32.
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-offsety
        set {
            local Elements := BufferAlloc(6*4)
            DllCall("Gdiplus.dll\GdipGetMatrixElements", "Ptr", this, "Ptr", Elements)
            DllCall("Gdiplus.dll\GdipSetMatrixElements", "Ptr", this, "Float", NumGet(Elements,  0, "Float")  ; m11.
                                                                    , "Float", NumGet(Elements,  4, "Float")  ; m12.
                                                                    , "Float", NumGet(Elements,  8, "Float")  ; m21.
                                                                    , "Float", NumGet(Elements, 12, "Float")  ; m22.
                                                                    , "Float", NumGet(Elements, 16, "Float")  ; m31.
                                                                    , "Float", Value)                         ; m32.
        }
    }

    /*
        Determines whether this matrix is invertible.
    */
    Invertible[]
    {
        get {
            local IsInvertible := 0
            DllCall("Gdiplus.dll\GdipIsMatrixInvertible", "Ptr", this, "IntP", IsInvertible)
            return IsInvertible
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-isinvertible
    }

    /*
        Determines whether this matrix is the identity matrix.
    */
    Identity[]
    {
        get {
            local IsMatrixIdentity := 0
            DllCall("Gdiplus.dll\GdipIsMatrixIdentity", "Ptr", this, "IntP", IsMatrixIdentity)
            return IsMatrixIdentity
        } ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-isidentity
    }
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates and initializes a Matrix object that represents the identity matrix.
    -------------------------------------------------------------------------------------------
    Creates and initializes a Matrix object based on six numbers that define an affine transformation.
    Parameters:
        m11 / m12:
            Real number that specifies the element in the first row, first/second column.
        m21 / m22:
            Real number that specifies the element in the second row, first/second column.
        m31 / m32:
            Real number that specifies the element in the third row, first/second column.
    -------------------------------------------------------------------------------------------
    Creates a Matrix object based on a rectangle and a point.
    Parameters:
        m11 (Rect):
            Specifies a rectangle.
            The X data member of the rectangle specifies the matrix element in row 1, column 1.
            The Y data member of the rectangle specifies the matrix element in row 1, column 2.
            The Width data member of the rectangle specifies the matrix element in row 2, column 1.
            The Height data member of the rectangle specifies the matrix element in row 2, column 2.
            This parameter can be a IRect(F) object or a Buffer-like object containing a rectangle.
        m12 (Point):
            Specifies a point.
            The X data member of the point specifies the matrix element in row 3, column 1.
            The Y data member of the point specifies the matrix element in row 3, column 2.
            This parameter can be a IPoint(F) object or a Buffer-like object containing a rectangle.
    Return value:
        If the method succeeds, the return value is a Matrix object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Matrix(m11 := "", m12 := 0, m21 := 0, m22 := 0, m31 := 0, m32 := 0)
{
    local pMatrix := 0
    switch Type(m11)
    {
    case "IRect":
        ; Creates a Matrix object based on a rectangle and a point (Integer).
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-matrix(inconstrect__inconstpoint)
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateMatrix3I", "Ptr", m11, "Ptr", m12, "UPtrP", pMatrix)
    case "IRectF":
        ; Creates a Matrix object based on a rectangle and a point (Float).
        ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-matrix(inconstrectf__inconstpointf)
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateMatrix3", "Ptr", m11, "Ptr", m12, "UPtrP", pMatrix)
    default:
        if (m11 == "")
            ; Creates and initializes a Matrix object that represents the identity matrix.
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-matrix(constmatrix_)
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateMatrix", "UPtrP", pMatrix)
        else
            ; Creates and initializes a Matrix::Matrix object based on six numbers that define an affine transformation.
            ; https://docs.microsoft.com/en-us/windows/win32/api/gdiplusmatrix/nf-gdiplusmatrix-matrix-matrix(inreal_inreal_inreal_inreal_inreal_inreal)
            Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipCreateMatrix2", "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", m31, "Float", m32, "UPtrP", pMatrix)
    }
    return Gdiplus.Matrix.New(pMatrix)
}
