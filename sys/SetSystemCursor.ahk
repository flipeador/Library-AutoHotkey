/*
    Cambia el cursor del sistema. Restaura todos los cursores.
    Parámetros:
        Cursor: Uno de los valores en el objeto “Cursors” definido en la función. Dejar una cadena vacía para restaurar todos los cursores del sistema.
*/
SetSystemCursor(Cursor := '')
{
    Static Cursors := {APPSTARTING: 32650, ARROW: 32512, CROSS: 32515, HAND: 32649, HELP: 32651, IBEAM: 32513, NO: 32648, SIZEALL: 32646, SIZENESW: 32643, SIZENS: 32645, SIZENWSE: 32642, SIZEWE: 32644, UPARROW: 32516, WAIT: 32514}

    If (Cursor == '')
        Return DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0057, 'UInt', 0, 'Ptr', 0, 'UInt', 0)
    Cursor := InStr(Cursor, '3') ? Cursor : Cursors[Cursor]

    Local hCursor
    For Each, ID in Cursors
    {
        hCursor := DllCall('User32.dll\LoadImageW', 'Ptr', 0, 'Int', Cursor, 'UInt', 2, 'Int', 0, 'Int', 0, 'UInt', 0x00008000, 'Ptr')   ; 2 = IMAGE_CURSOR | 0x00008000 = LR_SHARED
        hCursor := DllCall('User32.dll\CopyIcon', 'Ptr', hCursor, 'Ptr')
        DllCall('User32.dll\SetSystemCursor', 'Ptr', hCursor, 'UInt',  ID)
    }
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648395(v=vs.85).aspx
