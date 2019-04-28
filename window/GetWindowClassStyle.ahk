/*
    Recupera el estilo de clase de la ventana espesificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
        Si tuvo éxito devuelve el estilo, caso contrario devuelve una cadena vacía.
*/
GetWindowClassStyle(hWnd)
{
    If (A_PtrSize == 4)
        Local R := DllCall('User32.dll\GetClassLongW', 'Ptr', hWnd, 'Int', -26, 'UInt')
    Else
        Local R := DllCall('User32.dll\GetClassLongPtrW', 'Ptr', hWnd, 'Int', -26, 'UPtr')

    Return (!R && A_LastError ? '' : R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633581(v=vs.85).aspx
