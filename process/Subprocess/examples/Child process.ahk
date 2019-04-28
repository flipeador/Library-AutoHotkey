#Warn


StdIn  := FileOpen("*", "r")
StdOut := FileOpen("*", "w")
StdErr := FileOpen("**", "w")

if !StdIn || !StdOut || !StdErr
{
    MsgBox("Error!`nThis script is the child process that is executed by 'Example - Parent process.ahk'",, 0x1010)
    ExitApp
}

MsgBox("Child Proces: STDIN`n`n" . StdIn.Read())

StdOut.Write("Test StdOut!")
StdOut.Read(0)

StdErr.Write("Test StdErr!")
StdErr.Read(0)

ExitApp
