#Warn

#Include ..\..\..\Process\Subprocess\Subprocess.ahk
#Include ..\..\ExecScript\ExecScript.ahk
#Include ..\AHkInstance.ahk


; We define a global variable.
MyVar := 0

; Create an AHkInstance instance.
; In this case, "p1" is the name that identifies this object.
Inst1 := new AHkInstance("p1")

; Add some code that will be executed later.
Inst1.AddCode("
(C  ; C = Allows semicolon comments inside the continuation section.

    MsgBox("A_InstName: " . A_InstName, A_InstName, 0x1000)  ; Shows this instance name (p1).

    Parent := GetActiveObject()  ; Retrieve the active object of the main script.

    Parent.Call("Fnc1", "Hello World!")
    Parent.G["MyVar"] := 32767

    Parent := ""

)")

; Execute the code and wait for the subprocess to terminate.
Inst1.Exec()
Inst1.Subprocess.WaitClose()

; Close the Inst1 object.
Inst1.Close()

MsgBox("Closed!`n`nMyVar: " . MyVar)
ExitApp




Fnc1(Param1)
{
    MsgBox("A_ThisFunc: " . A_ThisFunc . "`n`nParam1: " . Param1, "Main Script", 0x1000)
}
