/*
    Muestra un diálogo para pedirle al usuario que seleccione un icono.
    Parámetros:
        Owner   : El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
        FileName: La ruta a un archivo que contenga iconos.
        Icon    : El índice del icono en el archivo. El valor por defecto es 1.
    Return:
        Si tuvo éxito devuelve un objeto con las claves FileName|Icon, caso contrario devuelve 0.
    Ejemplo:
        If (Result := ChooseIcon())
            MsgBox('FileName: ' . Result.FileName . ',' . Result.Icon)
*/
ChooseIcon(Owner := 0, FileName := '', Icon := 1)
{
    Local Buffer
    VarSetCapacity(Buffer, 4000)
    StrPut(FileName, &Buffer, 'UTF-16')

    Local OutputVar := 0
    If (DllCall('Shell32.dll\PickIconDlg', 'Ptr', Owner, 'UPtr', &Buffer, 'UInt', 2000, 'IntP', --Icon))
    {
        OutputVar := { FileName: StrGet(&Buffer, 'UTF-16')
                     , Icon    : Icon + 1                }

        If (SubStr(OutputVar.FileName, 2, 1) != ':')
            OutputVar.FileName := StrReplace(OutputVar.FileName, '%SystemRoot%', A_WinDir,, 1)
    }

    Return (OutputVar)
}
