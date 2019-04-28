RegisterShellHookWindow()
{
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644947(v=vs.85).aspx
    Static MsgNumber := DllCall("User32.dll\RegisterWindowMessageW", "Str","SHELLHOOK", "UInt")

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644989(v=vs.85).aspx
    If (!MsgNumber || !DllCall("User32.dll\RegisterShellHookWindow", "Ptr", A_ScriptHwnd))
        Return FALSE
    OnMessage(MsgNumber, "WM_SHELLHOOKMESSAGE")
    Return TRUE
}

DeregisterShellHookWindow()
{
    Return DllCall("User32.dll\DeregisterShellHookWindow", "Ptr", A_ScriptHwnd)
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644979(v=vs.85).aspx
