/*
    Recupera información sobre la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
            0 = Ha ocurrido un eror al intentar recuperar la información.
        [obj] = Si tuvo éxito devuelve un objeto con la información de la ventana. Ver función para las claves disponibles.
    Ejemplo:
        For Key, Info in GetWindowInfo(WinExist('A'))
            str .= Key . ':`t' . Info . '`n'
        MsgBox(str)
    Credits:
        By justme - https://autohotkey.com/board/topic/69254-func-api-getwindowinfo-ahk-l/
*/
GetWindowInfo(hWnd)
{
    Local WINDOWINFO

    VarSetCapacity(WINDOWINFO, 60, 0)
    If (!DllCall('User32.dll\GetWindowInfo', 'Ptr', Hwnd, 'UPtr', &WINDOWINFO))
        Return (FALSE)

    Local WinInfo := {}
            WinInfo.X       := NumGet(&WINDOWINFO +  4, 'Int')                        ; X coordinate of the window
            WinInfo.Y       := NumGet(&WINDOWINFO +  8, 'Int')                        ; Y coordinate of the window
            WinInfo.W       := NumGet(&WINDOWINFO + 12, 'Int')    - WinInfo.X         ; Width of the window
            WinInfo.H       := NumGet(&WINDOWINFO + 16, 'Int')    - WinInfo.Y         ; Height of the window
            WinInfo.ClientX := NumGet(&WINDOWINFO + 20, 'Int')                        ; X coordinate of the client area
            WinInfo.ClientY := NumGet(&WINDOWINFO + 24, 'Int')                        ; Y coordinate of the client area
            WinInfo.ClientW := NumGet(&WINDOWINFO + 28, 'Int')    - WinInfo.ClientX   ; Width of the client area
            WinInfo.ClientH := NumGet(&WINDOWINFO + 32, 'Int')    - WinInfo.ClientY   ; Height of the client area
            WinInfo.Style   := NumGet(&WINDOWINFO + 36, 'UInt')                       ; The window styles.
            WinInfo.ExStyle := NumGet(&WINDOWINFO + 40, 'UInt')                       ; The extended window styles.
            WinInfo.State   := NumGet(&WINDOWINFO + 44, 'UInt')                       ; The window status (1 = active).
            WinInfo.BorderW := NumGet(&WINDOWINFO + 48, 'UInt')                       ; The width of the window border, in pixels.
            WinInfo.BorderH := NumGet(&WINDOWINFO + 52, 'UInt')                       ; The height of the window border, in pixels.
            WinInfo.Type    := NumGet(&WINDOWINFO + 56, 'UShort')                     ; The window class atom.
            WinInfo.Version := NumGet(&WINDOWINFO + 58, 'UShort')                     ; The Windows version of the application.

    Return (WinInfo)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633516(v=vs.85).aspx
