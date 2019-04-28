/*
    Elimina el icono especificado.
    Parámetros:
        hIcon: El identificador del icono.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
DeleteIcon(hIcon)
{
    Return DllCall('User32.dll\DestroyIcon', 'Ptr', hIcon)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648063(v=vs.85).aspx




/*
    Copia el icono especificado.
    Parámetros:
        hIcon: El identificador del icono.
    Return:
        Si tuvo éxito devuelve el identificador del nuevo icono, caso contrario devuelve 0.
*/
CopyIcon(hIcon)
{
    Return DllCall('User32.dll\CopyIcon', 'Ptr', hIcon, 'Ptr')    ; DllCall('Shell32.dll\DuplicateIcon', 'Ptr', 0, 'Ptr', hIcon)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648058(v=vs.85).aspx




/*
    Determina si el identificador del icono es válido
    Parámetros:
        hIcon: El identificador a probar.
    Return:
        Devuelve 1 si es un icono, caso contrario devuelve 0.
*/
IsIcon(hIcon)
{
    Return DllCall('User32.dll\DestroyIcon', 'Ptr', DllCall('User32.dll\CopyIcon', 'Ptr', hIcon, 'Ptr'))
}




/*
    Recupera información del icono especificado.
    Parámetros:
        hIcon   : El identificador del icono.
        ICONINFO: Devuelve la estructura ICONINFO.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Observaciones:
        Debe eliminar los miembros «hbmMask» y «hbmColor» llamando a la función «DeleteObject» cuando no los utilize más.
*/
GetIconInfo(hIcon, ByRef ICONINFO)
{
    VarSetCapacity(ICONINFO, 12 + A_PtrSize*2, 0)

    Return DllCall('User32.dll\GetIconInfo', 'Ptr', hIcon, 'UPtr', &ICONINFO)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648070(v=vs.85).aspx




/*
    Recupera las dimensiones del icono especificado.
    Parámetros:
        hIcon: El identificador del icono.
    Return:
        Si tuvo éxito devuelve un objeto con las claves W y H, caso contrario devuelve cero.
    Ejemplo:
        hIcon := LoadPicture(FileSelect(,,, '(*.ico)'),, ImageType) ;ImageType=1
        Size  := GetIconSize(hIcon), DeleteIcon(hIcon)
        MsgBox(Size.W . 'x' . Size.H)
*/
GetIconSize(hIcon)
{
    Local ICONINFO
    If (!GetIconInfo(hIcon, ICONINFO))
        Return (FALSE)

    DllCall('Gdi32.dll\DeleteObject', 'Ptr', NumGet(&ICONINFO + 8 +   A_PtrSize, 'Ptr'))
    DllCall('Gdi32.dll\DeleteObject', 'Ptr', NumGet(&ICONINFO + 8 + A_PtrSize*2, 'Ptr'))

    Return {W: NumGet(&ICONINFO + 4, 'UInt'), H: NumGet(&ICONINFO + 8, 'UInt')}
}




/*
    Carga un icono predefinido.
    Parámetros:
        ID: El identificador del icono prefedinido a cargar, debe ser uno de los siguientes valores:
            32512 (IDI_APPLICATION) = Icono de la aplicación predeterminada.
            32516 (IDI_INFORMATION) = Icono de información.
            32513 (IDI_ERROR)       = Icono de error.
            32515 (IDI_WARNING)     = Icono de advertencia.
            32518 (IDI_SHIELD)      = Icono de escudo.
            32514 (IDI_QUESTION)    = Icono de pregunta.
        W : El ancho deseado. Cero para un icono pequeño. -1 para un icono grande.
        H : El alto deseado. Cero para un icono pequeño. -1 para un icono grande.
    Return:
        Si tuvo éxito devuelve el identificador del icono, caso contrario devuelve cero.
    Ejemplo:
        Gui := GuiCreate(), Gui.AddPic(, 'HICON:' . LoadPredefinedIcon(32513)), Gui.Show(), WinWaitClose('ahk_id' . Gui.Hwnd), ExitApp()
*/
LoadPredefinedIcon(ID, W := -1, H := -1)
{
    DllCall('Comctl32.dll\LoadIconWithScaleDown', 'Ptr', 0, 'Ptr', ID, 'Int', W==-1?SysGet(11):W?W:SysGet(49), 'Int', H==-1?SysGet(11):H?H:SysGet(49), 'PtrP', HICON)
    Return HICON
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775703(v=vs.85).aspx




/*
    Recupera la cantidad de iconos en el archivo especificado (1 si es ICO). Si el archivo es un ejecutable o DLL devuelve el número de recursos RT_GROUP_ICON.
    Parámetros:
        FilePath: La ruta y nombre del archivo.
    Return:
        Si tuvo éxito devuelve la cantidad de iconos, caso contrario devuelve 0.
*/
GetIconFileCount(FilePath)
{
    Return DllCall('Shell32.dll\ExtractIconW', 'Ptr', 0, 'UPtr', &FilePath, 'Int', -1)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648068(v=vs.85).aspx




/*
    Recupera información del archivo icono especificado.
    Parámetros:
        IconPath: La ruta del archivo icono.
    Return:
        0       = El archivo especificado es inválido.
        [array] = Si tuvo éxito devuelve un array de objetos con la información de cada icono disponible. Las claves disponibles son: W, H, ColorCount, Planes y BitCount.
    Ejemplo:
        For Each, Icon in GetIconFileInfo(FileSelect())
            Str .= 'Icon #' . A_Index . '  [W:' . Icon.W . ' | H:' . Icon.H . ' | BC:' . Icon.BitCount . '`n'
        MsgBox(Str)
*/
GetIconFileInfo(IconPath)
{
    Local File
    If (!(File := FileOpen(IconPath, 'r')))
        Return (FALSE)

    ; Comprobamos que el archivo sea un ícono.
    File.Seek(2)
    If (File.ReadUShort() != 1) ;ICONDIR.idType --> Resource Type (1 for icons)
        Return (FALSE)

    ; Leemos la cantidad de iconos en el archivo (distintas dimensiones y profundidad de bits).
    Local Count
    If (!(Count := File.ReadUShort()))
        Return (FALSE)

    ; Comprobamos que el archivo no esté corrupto.
    If (File.Length < 6 + 16 * Count)
        Return (FALSE)

    ; Recuperamos información de cada icono.
    Local Obj
        , Info := []
    Loop (Count)
    {
        File.Seek(6 + 16 * A_Index) ;ICONDIR + (ICONDIRENTRY * A_Index)

        Obj            := {}
        Obj.W          := File.ReadUChar()
        Obj.H          := File.ReadUChar()
        Obj.ColorCount := File.ReadUChar()
        File.Seek(1, 1)
        Obj.Planes     := File.ReadUShort()
        Obj.BitCount   := File.ReadUShort()

        Info.Push(Obj)
    }

    Return (Info)
} ;https://msdn.microsoft.com/en-us/library/ms997538.aspx
