/*
    Recupera la posición de la barra de desplazamiento especificada.
    Parámetros:
        hWnd     : El identificador de la ventana.
        ScrollBar: Especificar 1 para la barra vertical. 0 es la barra horizontal.
    Return:
        Devuelve un número entero que indica la posición actual de la barra. Devuelve -1 si hubo un error.
*/
GetScrollPos(hWnd, ScrollBar := 0)
{
    Local SCROLLINFO
    NumPut(VarSetCapacity(SCROLLINFO, 7*4, 0), SCROLLINFO, 0, 'UInt')
    NumPut(0x4, &SCROLLINFO+4, 'UInt')

    If (!DllCall('User32.dll\GetScrollInfo', 'Ptr', hWnd, 'Int', ScrollBar, 'UPtr', &SCROLLINFO))
        Return (-1)
    
    Return (NumGet(&SCROLLINFO+20, 'Int'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb787583(v=vs.85).aspx




/*
    Establece la posición de la barra de desplazamiento especificada.
    Parámetros:
        hWnd     : El identificador de la ventana.
        ScrollBar: Especificar 1 para la barra vertical. 0 es la barra horizontal.
        Pos      : La nueva posición. Debe espesificar un número entero entre el rango actual admitido por la barra de desplazamiento.
        Redraw   : Determina si la barra debe ser redibujada para reflejar los cambios. Por defecto es TRUE.
*/
SetScrollPos(hWnd, ScrollBar, Pos, Redraw := true)
{
    Local SCROLLINFO
    NumPut(VarSetCapacity(SCROLLINFO, 7*4, 0), SCROLLINFO, 0, 'UInt')
    NumPut(0x4, &SCROLLINFO+4, 'UInt')
    NumPut(Pos, &SCROLLINFO+20, 'Int')

    Return (DllCall('User32.dll\SetScrollInfo', 'Ptr', hWnd, 'Int', ScrollBar, 'UPtr', &SCROLLINFO, 'Int', Redraw))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb787595(v=vs.85).aspx
