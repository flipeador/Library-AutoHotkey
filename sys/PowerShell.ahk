/*
    Observaciones:
        PowerShell esta habilitado por defecto en WIN_8+.
    Cmdlets:
        https://technet.microsoft.com/en-us/library/hh849827.aspx
*/
PowerShell(Script, WorkingDir := "", Options := "", Params := "-ExecutionPolicy Bypass")
{
    Run("PowerShell.exe " . Params . " -Command &{./'" . Script . "'}", WorkingDir, Options, PID)
    Return PID
}

/*
DirCreate(A_Temp . "\a b")
FileOpen(A_Temp . "\a b\p s1test.ps1", "w").Write("write-host `"Press any key to continue...`"`n[void][System.Console]::ReadKey($true)")
MsgBox PowerShell("p s1test.ps1", A_Temp . "\a b")

Run "PowerShell.exe Start-Process -FilePath notepad"
*/
