/*
    Creates a GDI bitmap from a rectangular region of the virtual screen.
    Parameters:
        Width / Height:
            Specifies the width and height of the output bitmap.
            If omitted, SM_CXVIRTUALSCREEN and SM_CYVIRTUALSCREEN are used.
        XSrc / YSrc:
            Specifies the x/y-coordinate of the upper-left corner of the screen rectangle.
            The default value of both parameters is zero.
        WSrc / HSrc:
            Specifies the width and height of the screen rectangle.
            If omitted, it is set to the value of Width and Height.
        Cursor:
            Specifies whether to capture the cursor.
            TRUE    Capture the cursor and draw it on the output image in the current position.
            FALSE   Do not capture the cursor.
    Remarks:
        The virtual screen is the bounding rectangle of all display monitors.
        SysGet(76)  SM_XVIRTUALSCREEN     Specifies the coordinates for the left side of the virtual screen.
        SysGet(77)  SM_YVIRTUALSCREEN     Specifies the coordinates for the top of the virtual screen.
        SysGet(78)  SM_CXVIRTUALSCREEN    Specifies the width of the virtual screen, in pixels.
        SysGet(79)  SM_CYVIRTUALSCREEN    Specifies the height of the virtual screen, in pixels.
        -------------------------------------------------------------------------------------------
        If WSrc/HSrc do not match Width/Height, the cursor icon will not be drawn on the right coordinates.
*/
ScreenCapture(Width := "", Height := "", XSrc := 0, YSrc := 0, WSrc := "", HSrc := "", Cursor := FALSE)
{
    Width := Width==""?SysGet(78):Width, Height := Height==""?SysGet(79):Height
    local hDeskWnd   := DllCall("User32.dll\GetDesktopWindow", "Ptr")
    local hDDC       := DllCall("User32.dll\GetDC", "Ptr", hDeskWnd, "Ptr")
    local hCDC       := DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr", hDDC, "Ptr")
    local hBitmap    := DllCall("Gdi32.dll\CreateCompatibleBitmap", "Ptr", hDDC, "Int", Width, "Int", Height, "Ptr")
    local hOldBitmap := DllCall("Gdi32.dll\SelectObject", "Ptr", hCDC, "Ptr", hBitmap, "Ptr")

    DllCall("Gdi32.dll\SetStretchBltMode", "Ptr", hCDC, "Int", Cursor?3:4)
    DllCall("Gdi32.dll\StretchBlt", "Ptr", hCDC, "Int", 0, "Int", 0, "Int", Width, "Int", Height, "Ptr", hDDC
        , "Int", XSrc, "Int", YSrc, "Int", WSrc==""?Width:WSrc, "Int", HSrc==""?Height:HSrc, "UInt", 0x00CC0020)

    if (Cursor)
    {
        local CURSORINFO := BufferAlloc(16+A_PtrSize)  ; CURSORINFO structure.
        NumPut("UInt", CURSORINFO.Size, CURSORINFO)  ; CURSORINFO.Size -> sizeof(CURSORINFO).
        if (DllCall("User32.dll\GetCursorInfo", "Ptr", CURSORINFO))
        && (NumGet(CURSORINFO,4,"Int") == 1)  ; CURSOR_SHOWING = 1 (The cursor is showing).
        {
            local hIcon := DllCall("User32.dll\CopyIcon", "Ptr", NumGet(CURSORINFO,8), "Ptr")
            local ICONINFO := BufferAlloc(8+3*A_PtrSize)  ; ICONINFO structure.
            if (DllCall("User32.dll\GetIconInfo", "Ptr", hIcon, "Ptr", ICONINFO))
            {
                DllCall("Gdi32.dll\DeleteObject", "Ptr", NumGet(ICONINFO,8+A_PtrSize))    ; hbmMask.
                DllCall("Gdi32.dll\DeleteObject", "Ptr", NumGet(ICONINFO,8+2*A_PtrSize))  ; hbmColor.
                DllCall("User32.dll\DrawIcon", "Ptr", hCDC
                    , "Int", NumGet(CURSORINFO,8+A_PtrSize,"Int")  - NumGet(ICONINFO,4,"Int") - XSrc
                    , "Int", NumGet(CURSORINFO,12+A_PtrSize,"Int") - NumGet(ICONINFO,8,"Int") - YSrc
                    , "Ptr", hIcon) ;, "Int", 0, "Int", 0, "UInt", 0, "Ptr", 0, "UInt", 3)
            }
            DllCall("User32.dll\DestroyIcon", "Ptr", hIcon)
        }
    }

    DllCall("Gdi32.dll\SelectObject", "Ptr", hCDC, "Ptr", hOldBitmap, "Ptr")
    DllCall("Gdi32.dll\DeleteDC", "Ptr", hCDC)
    DllCall("User32.dll\ReleaseDC", "Ptr", hDeskWnd, "Ptr", hDDC)

    return hBitmap
}
