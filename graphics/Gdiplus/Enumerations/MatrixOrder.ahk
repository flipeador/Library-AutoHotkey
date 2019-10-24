/*
    The MatrixOrder enumeration specifies the order of multiplication when a new matrix is multiplied by an existing matrix.

    MatrixOrder Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-matrixorder
*/
class MatrixOrder
{
    static MatrixOrderPrepend := 0  ; Specifies that the new matrix is on the left and the existing matrix is on the right.
    static MatrixOrderAppend  := 1  ; Specifies that the existing matrix is on the left and the new matrix is on the right.
}
