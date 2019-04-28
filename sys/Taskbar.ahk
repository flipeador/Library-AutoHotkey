/*
    Recupera el identificador del control Toolbar de la bandeja de notificación.
    Return
        Si tuvo éxito devuelve el identificador del control Toolbar; caso contrario devuelve cero.
    ErrorLevel:
        Si tuvo éxito, se establece en el índice ToolbarWindow32; caso contrario se establece en cero.
*/
GetTrayToolbar()
{
    DetectHiddenWindows TRUE
    Local ShellTrayWnd := WinExist('ahk_class Shell_TrayWnd')
        , hToolbar, Index
    Loop
        hToolbar := ControlGetHwnd('ToolbarWindow32' . (Index:=A_Index), 'ahk_id' . ShellTrayWnd)
    Until (!hToolbar || WinGetClass('ahk_id' . DllCall('User32.dll\GetParent', 'Ptr', hToolbar, 'Ptr')) == 'SysPager')
    ErrorLevel := hToolbar ? Index : 0
    Return hToolbar
}




/* SIN TERMINAR POR FALTA DE INTERÉS =P
GetTrayInfo()
{
    ; recuperamos el identificador del control Toolbar
    Local hToolbar1 := GetTrayToolbar()    ; corresponde al Toolbar que contiene los iconos visible
        , hToolbar2 := ControlGetHwnd('ToolbarWindow321', 'ahk_class NotifyIconOverflowWindow')    ; Toolbar que contiene los iconos ocultos
    If (!hToolbar1)
        Return -1

    Local ProcessId := WinGetPID('ahk_id' . hToolbar1)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx
        ; abrimos el proceso para realizar operaciones de lectura y escritura en su memoria
        , hProcess  := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x0010|0x0020|0x0008, 'Int', FALSE, 'UInt', ProcessId, 'Ptr')    ; PROCESS_VM_READ|PROCESS_VM_WRITE|PROCESS_VM_OPERATION
    If (!hProcess)
        Return -2

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366890(v=vs.85).aspx
    ; sizeof(struct TBBUTTON) = x32: 20 | x64: 32
    Local sizeof_TBBUTTON := A_Is64bitOS ? 32 : 20
        , pTBBUTTON := DllCall('Kernel32.dll\VirtualAllocEx', 'Ptr', hProcess, 'UPtr', 0, 'UPtr', sizeof_TBBUTTON, 'UInt', 0x1000, 'UInt', 0x0004, 'UPtr')    ; MEM_COMMIT = 0x1000 | PAGE_READWRITE = 0x0004
    If (!pTBBUTTON && DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess) != '*')
        Return -2

    Local TrayInfo  := []
        , TBBUTTON, Data, Buffer, NumberOfBytesRead
    VarSetCapacity(TBBUTTON, sizeof_TBBUTTON), VarSetCapacity(Data, A_Is64bitOS ? 32 : 24), VarSetCapacity(Buffer, 256)
    For Each, hToolbar in hToolbar2 ? [hToolbar1, hToolbar2] : [hToolbar1]
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787297(v=vs.85).aspx
        ; recupera la cantidad de iconos en el control Toolbar
        Local ButtonCount := DllCall('User32.dll\SendMessageW', 'Ptr', hToolbar, 'UInt', 0x0418, 'Ptr', 0, 'Ptr', 0)    ; TB_BUTTONCOUNT := 0x0418
        If (!ButtonCount)
            Continue

        Loop (ButtonCount)
        {
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787319(v=vs.85).aspx
            DllCall('User32.dll\SendMessageW', 'Ptr', hToolbar, 'UInt', 0x0417, 'Ptr', A_Index-1, 'UPtr', pTBBUTTON)    ; TB_GETBUTTON := 0x0417

            ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms680553(v=vs.85).aspx
            DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr', hProcess, 'UPtr', pTBBUTTON, 'UPtr', &TBBUTTON, 'UPtr', sizeof_TBBUTTON, 'UPtrP', NumberOfBytesRead)

            ;TrayInfo[A_Index] := {Bitmap : NumGet(&TBBUTTON    , 'Int')
            ;                    , Command: NumGet(&TBBUTTON + 4, 'Int')}

            DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr', hProcess, 'UPtr', NumGet(&TBBUTTON + (A_Is64bitOS ? 24 : 16)), 'UPtr', &Buffer, 'UPtr', 256, 'UPtrP', NumberOfBytesRead)
            msgbox StrGet(&Buffer, 'UTF-16')
        }
    }

    DllCall('Kernel32.dll\VirtualFreeEx', 'Ptr', hProcess, 'UPtr', pTBBUTTON, 'Ptr', 0, 'UInt', 0x8000)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return TrayInfo
}
*/
