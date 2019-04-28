#Warn
#Persistent

#Include ..\Subprocess.ahk


Process := new Subprocess("notepad.exe")

Process.RegisterWaitForTermination("WaitOrTimerCallback")

OnExit("Script_OnExit")
return


WaitOrTimerCallback(lpParameter, TimerOrWaitFired)
{
    MsgBox("A_ThisFunc: " . A_ThisFunc . "`nTimerOrWaitFired: " . TimerOrWaitFired,, 0x1000)
    SetTimer("ExitApp", -75)  ; Leave time to return.
    return
}


Script_OnExit(ExitReason, ExitCode)
{
    global Process

    Process.Close()
    MsgBox("ExitApp",, 0x1000)
}
