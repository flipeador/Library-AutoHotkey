/*
    Muestra, restaura (si la ventana esta minimizada), activa, trae al frente y toma el foco del teclado la ventana especificada.
    Parámetros:
        WindowID: El identificador de la ventana que se va activar.
    Return:
        Si tuvo éxito devuelve el identificador de la ventana, caso contrario devuelve cero.
*/
ActivateWindow(WindowID)
{
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633528(v=vs.85).aspx
    If (!DllCall("User32.dll\IsWindow", "Ptr", WindowID))
        Return FALSE

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
    If (!DllCall("User32.dll\IsWindowVisible", "Ptr", WindowID))
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
        DllCall("User32.dll\ShowWindow", "Ptr", WindowID, "UInt", 5)    ; SW_SHOW = 5

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633527(v=vs.85).aspx
    If (DllCall("User32.dll\IsIconic", "Ptr", WindowID))
        DllCall("User32.dll\ShowWindow", "Ptr", WindowID, "UInt", 9)    ; SW_RESTORE = 9

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms683183(v=vs.85).aspx
    Local CurrentThreadId := DllCall("Kernel32.dll\GetCurrentThreadId", "UInt")
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633522(v=vs.85).aspx
        ,  WindowThreadId := DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", WindowId, "UIntP", 0, "UInt")
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms681956(v=vs.85).aspx
    DllCall("User32.dll\AttachThreadInput", "UInt", WindowThreadId, "UInt", CurrentThreadId, "Int", TRUE)
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633539(v=vs.85).aspx
    DllCall("User32.dll\SetForegroundWindow", "Ptr", WindowId)
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646311(v=vs.85).aspx
    DllCall("User32.dll\SetActiveWindow", "Ptr", WindowId)    ; activa la ventana
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632673(v=vs.85).aspx
    DllCall("User32.dll\BringWindowToTop", "Ptr", WindowId)    ; trae al frente la ventana
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646312(v=vs.85).aspx
    DllCall("User32.dll\SetFocus", "Ptr", WindowId)    ; establece el foco en la ventana
    DllCall("User32.dll\AttachThreadInput", "UInt", WindowThreadId, "UInt", CurrentThreadId, "Int", FALSE)

    Return DllCall("User32.dll\GetForegroundWindow", "Ptr") == WindowID ? WindowID : FALSE
}
