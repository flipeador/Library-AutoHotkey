/*
    Establece los colores RGB especificados con degradado al control Picture especificado.
    Parámetros:
           Pic: El objeto control Picture.
        Colors: Los colores RGB a utilizar. Los colores deben ser especificados como una cadena sin prefijo y en hexadecimal.
    Return:
        La función no devuelve ningún valor. Si ocurre algún error devuelve una Excepción.
    Ejemplo:
        CreateGradient((Gui:=GuiCreate()).AddPic("x0 y0 w500 h350"), "3399FF", "FF3399", "3399FF"), Gui.Show("w500 h350")
*/
CreateGradient(Pic, Colors*)
{
    If (!IsObject(Pic) || SubStr(Type(Pic), 1, 3) != "Gui" || Pic.Type != "Pic")
        Throw Exception("Function CreateGradient invalid parameter #1.",, IsObject(Pic) ? "Type " . Type(Pic) : "!Object")

    If (ObjLength(Colors) == 0)
        Throw Exception("Function CreateGradient invalid parameter #2",, "!ObjLength")

    Local Size := VarSetCapacity(BITS, ObjLength(Colors) * 2 * 4, 0), pBITS := &BITS
    Loop (ObjLength(Colors))
        pBITS := NumPut("0x" . Colors[A_Index], NumPut("0x" . Colors[A_Index], pBITS, "UInt"), "UInt")

    ; CreateBitmap function
    ; https://msdn.microsoft.com/en-us/library/dd183485(v=vs.85).aspx
    Local hBitmap := DllCall("Gdi32.dll\CreateBitmap",  "Int", 2                  ; _In_        int      nWidth (the bitmap width, in pixels)
                                                     ,  "Int", ObjLength(Colors)  ; _In_        int     nHeight (the bitmap height, in pixels)
                                                     , "UInt", 1                  ; _In_       UINT     cPlanes (the number of color planes used by the device)
                                                     , "UInt", 32                 ; _In_       UINT cBitsPerPel (the number of bits required to identify the color of a single pixel)
                                                     , "UPtr", 0                  ; _In_ const VOID    *lpvBits (pointer to an array of color data used to set the colors in a rectangle of pixels)
                                                     ,  "Ptr")                    ; Return value                (handle to a bitmap | NULL)

    ; CopyImage function
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031(v=vs.85).aspx
    hBitmap := DllCall("User32.dll\CopyImage",  "Ptr", hBitmap  ; _In_ HANDLE    hImage         (handle to the image to be copied)
                                             , "UInt", 0        ; _In_   UINT     uType               (type of image to be copied)      0 = IMAGE_BITMAP
                                             ,  "Int", 0        ; _In_    int cxDesired   (desired width, in pixels, of the image)      0 = Same width as the original
                                             ,  "Int", 0        ; _In_    int cyDesired  (desired height, in pixels, of the image)      0 = Same height as the original
                                             , "UInt", 0x2008   ; _In_   UINT   fuFlags                                            0x2000 = LR_CREATEDIBSECTION         | 0x00000008 = LR_COPYDELETEORG
                                             ,  "Ptr")          ; Return value          (handle to the newly created image | NULL)

    ; SetBitmapBits function
    ; https://msdn.microsoft.com/en-us/library/dd162962(v=vs.85).aspx
    DllCall("Gdi32.dll\SetBitmapBits",  "Ptr", hBitmap  ; _In_       HBITMAP    hbmp                       (handle to the bitmap to be set)
                                     , "UInt", Size     ; _In_         DWORD  cBytes                    (number of bytes pointed to lpBits)
                                     , "UPtr", &BITS)   ; _In_ const    VOID *lpBits (pointer to an array of bytes that contain color data)

    hBitmap := DllCall("User32.dll\CopyImage", "Ptr", hBitmap, "UInt", 0, "Int", Pic.Pos.W, "Int", Pic.Pos.H, "UInt", 0x2008, "Ptr")

    ; STM_SETIMAGE message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760782(v=vs.85).aspx
    Pic.Value := "HBITMAP:" . hBitmap . " *w0 *h0"
} ; https://autohotkey.com/boards/viewtopic.php?f=9&t=31773&p=150407
