ComByteArrayToBitmap(ComByteArray)
{
    if Type(ComByteArray) !== "ComObjArray"
        throw Exception("ComByteArrayToBitmap function, invalid parameter #1.", -1, "Type: " . Type(ComByteArray))

    ; Creates a Vector object.
    ; https://docs.microsoft.com/en-us/previous-versions/windows/desktop/wiaaut/-wiaaut-vector.
    local Vector := ComObjCreate("WIA.Vector")

    ; Sets the Vector of bytes as an array of bytes.
    ; https://docs.microsoft.com/en-us/previous-versions/windows/desktop/wiaaut/-wiaaut-ivector-binarydata.
    Vector.BinaryData := ComByteArray

    ; Retrieves a Microsoft Visual Basic picture object.
    ; https://docs.microsoft.com/en-us/previous-versions/windows/desktop/wiaaut/-wiaaut-ivector-picture.
    local Picture := Vector.Picture

    ; Creates a copy of the image.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-copyimage.
    local hBitmap := DllCall("User32.dll\CopyImage", "UPtr", Picture.Handle  ; HANDLE hImage.
                                                   , "UInt", 0               ; UINT   uType.      IMAGE_BITMAP (Copies a bitmap).
                                                   , "Int" , 0               ; INT    cxDesired.
                                                   , "Int" , 0               ; INT    cyDesired.
                                                   , "UInt", 0x2000|0x8|0x4  ; UINT   fuFlags.    LR_CREATEDIBSECTION|LR_COPYDELETEORG|LR_COPYRETURNORG.
                                                   , "UPtr")                 ; HANDLE ReturnType.

    return hBitmap
}
