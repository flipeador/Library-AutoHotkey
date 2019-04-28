#Warn
#Include ..\Subprocess.ahk


Process := new Subprocess(Format("`"{}`" `"{}`"",A_AhkPath,A_ScriptDir . "\Child process.ahk"))

Process.StdIn.Write("Hello World!")
Process.StdIn.Close()

MsgBox("Parent Process: STDOUT`n`n" . Process.StdOut.ReadAll())

MsgBox("Parent Process: STDERR`n`n" . Process.StdErr.ReadAll())

Process.Close()

MsgBox("Parent Process:`n`nExit!")
ExitApp
