#Include ..\..\..\process\Subprocess\Subprocess.ahk
#Include ..\ExecScript.ahk


/*
    Ex. ErrorLevel = 1:
        X+1               Type mismatch.
    Ex. ErrorLevel = 2:
        f()               Call to nonexistent function.
        #                 Illegal character in expression.
*/
expr := InputBox("Enter an expression to evaluate as a new script.",,, "Ord('*')")
if ErrorLevel
    ExitApp

result := AHK_Eval(expr)

MsgBox((ErrorLevel ? "ERROR! " . ErrorLevel . "`n`n" : "") .  result)
ExitApp




/*
    Evals an expression using the AutoHotkey interpreter.
    Parameters:
        expr:
            The expression to evaluate.
    Return value:
        If the execution was successful, the return value is the StdOut text.
        If the execution was unsuccessful, the return value is the StdErr text.
    ErrorLevel:
        0      The execution was successful.
        1      An unhandled error has occurred (exception).
        2      Syntax error.
*/
AHK_Eval(expr)
{
    local

    ahk      := ExecScript("OnError((e)=>(_:=FileOpen('**','w','UTF-8-RAW')).Write('Error: ' . e.Message) . _.Read(0) . ExitApp(1))"
              . "`nFileAppend(" .  expr . ",'*','UTF-8-RAW')`nExitApp")
    if !ahk
        throw Exception("AHK_Eval function: ExecScript.", -1)

    result   := ahk.StdOut.ReadAll()

    ErrorLevel := ahk.GetExitCode()
    if ErrorLevel == -1
        throw Exception("AHK_Eval function: Subprocess.GetExitCode.", -1)

    return ErrorLevel ? ahk.StdErr.ReadAll() : result
}
