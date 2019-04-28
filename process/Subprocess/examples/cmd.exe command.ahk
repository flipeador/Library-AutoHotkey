#Warn
#Include ..\Subprocess.ahk

; Create a child process.
; chcp 65001 = Use UTF-8.
; CREATE_NO_WINDOW = 0x08000000. Hides the console window.
Process := new Subprocess(Format("`"{}`" /C chcp 65001 >nul && tasklist",A_ComSpec),, 0x08000000)
if !Process
{
    MsgBox("CreateProcessW Error " . A_LastError)
    ExitApp
}

; Close the pipe handle so the child process stops reading.
Process.StdIn.Close()

; Read all the output data from the child process's pipe for STDOUT.
; Stop when there is no more data.
Process.StdOut.Encoding := "UTF-8"
StdOut   := Process.StdOut.ReadAll()
; The current thread will continue when the child process terminates.

; Close all Handles.
Process.Close()

; Show a message box with the result.
MsgBox(StdOut)
ExitApp
