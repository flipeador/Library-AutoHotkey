#Warn
#Include ..\Subprocess.ahk


expr := InputBox("Enter an expression to evaluate as a new script.",,, "A_InitialWorkingDir")
if ErrorLevel
    ExitApp

; Create a child process.
Process := new Subprocess(Format("`"{}`" /CP65001 /ErrorStdOut *",A_AhkPath))
if !Process
{
    MsgBox("CreateProcessW Error " . A_LastError)
    ExitApp
}

; Write the code to the pipe for the child's STDIN.
Process.StdIn.Encoding := "UTF-8"  ; Use UTF-8 to support unicode characters.
Process.StdIn.Write(Format("try`nFileAppend({},'*','{}')`ncatch`nExitApp(1)",expr,"UTF-8-RAW"))

; Close the pipe handle so the child process stops reading.
Process.StdIn.Close()

; Read all the output data from the child process's pipe for STDOUT.
; Stop when there is no more data.
Process.StdOut.Encoding := "UTF-8"
StdOut   := Process.StdOut.ReadAll()
; The current thread will continue when the child process terminates.

; Get the child process exit code.
ExitCode := Process.GetExitCode()
if ExitCode == -1
{
    MsgBox("GetExitCodeProcess Error " . A_LastError)
    ExitApp
}

; Close all Handles.
; Once the process has terminated and all its Handles have been closed, it will no longer be possible to obtain the exit code.
Process.Close()

; Show a message box with the current working directory and the result.
MsgBox(A_WorkingDir . "`n`n" . (ExitCode ? "ERROR" : StdOut))
ExitApp
