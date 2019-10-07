#Warn
#SingleInstance Force

#Include GuiControlTips.ahk


Gui := GuiCreate()

CTT1 := GuiControlTips(Gui, "GuiControlTips", 1)
CTT1.SetFont("Italic", "Courier New")

CTT2 := GuiControlTips(Gui, "GuiControlTips", 2)
CTT2.SetFont("Underline", "Segoe UI")

Button := Gui.AddButton("w200", "Activate/Deactivate")
Button.OnEvent("Click", (*)=>CTT1.Activate(-1) . CTT2.Activate(-1))
CTT1.Add(Button, "Activates or deactivates the ToolTip.")

Text := Gui.AddText("w200 Border", "Text!`nLine 2 ...")
CTT1.Add(Text, "Gui Control Text.`nMultiline ...")

DDL := Gui.AddDDL("w200 R3", "Item 1||Item 2|Item 3")
CTT2.Add(DDL, "Gui Control DDL.")

Gui.OnEvent("Close", "ExitApp")
Gui.Show()
return
