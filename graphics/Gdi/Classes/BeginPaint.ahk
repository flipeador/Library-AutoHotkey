class BeginPaint
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    hWnd        := 0  ; Handle to the window that has been repainted.
    hDC         := 0  ; Handle to the display device context for the window.
    PAINTSTRUCT := 0  ; A PAINTSTRUCT structure that contains the painting information.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(hWnd, hDC, PAINTSTRUCT)
    {
        this.hWnd        := hWnd
        this.hDC         := hDC
        this.PAINTSTRUCT := PAINTSTRUCT
    }

    static New(hWnd, hDC, PAINTSTRUCT)
    {
        return hDC ? base.New(hWnd,hDC,PAINTSTRUCT) : 0
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        DllCall("User32.dll\EndPaint", "Ptr", this.hWnd, "Ptr", this.PAINTSTRUCT)
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Indicates whether the background must be erased.
        This value is nonzero if the application should erase the background.
        The application is responsible for erasing the background if a window class is created without a background brush.
    */
    Erase[] => NumGet(this.PAINTSTRUCT, A_PtrSize, "Int")

    /*
        Gets a pointer to a rectangle that specifies the upper left and lower right corners of the rectangle
        - in which the painting is requested, in device units relative to the upper-left corner of the client area.
    */
    Rect[] => this.PAINTSTRUCT.Ptr + A_PtrSize + 4
}





; #######################################################################################################################
; STATIC METHODS (Gdi)                                                                                                  #
; #######################################################################################################################
/*
    Prepares the specified window for painting and fills a PAINTSTRUCT structure with information about the painting.
    Parameters:
        hWnd:
            Handle to the window to be repainted.
    Return value:
        If the method succeeds, the return value is a BeginPaint object.
        If the method fails, the return value is zero, indicating that no display device context is available.
*/
BeginPaint(hWnd)
{
    local PAINTSTRUCT := BufferAlloc(A_PtrSize==4?64:72)  ; PAINTSTRUCT structure.
    return Gdi.BeginPaint.New(hWnd
                            , DllCall("User32.dll\BeginPaint", "Ptr", hWnd, "Ptr", PAINTSTRUCT, "UPtr")
                            , PAINTSTRUCT)
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-beginpaint
