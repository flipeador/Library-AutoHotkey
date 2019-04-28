#Warn
#Include GuiControlTips.ahk 

Gui := GuiCreate()

CTT1 := new GuiControlTips(Gui)
CTT1.SetTitle("GuiControlTips", 1)
CTT1.SetFont("Italic", "Courier New")

CTT2 := new GuiControlTips(Gui)
CTT2.SetTitle("GuiControlTips", 2)
CTT2.SetFont("Italic", "Courier New")

Button := Gui.AddButton("w200", "Activate/Deactivate")
Button.OnEvent("Click", () => CTT1.Activate(-1) . CTT2.Activate(-1))
CTT1.Attach(Button, "Activates or deactivates the ToolTip.")

Text := Gui.AddText("w200 Border", "Text!`nLine 2 ...")
CTT1.Attach(Text, "Gui Control Text.`nMultiline ...")

DDL := Gui.AddDDL("w200 R3", "Item 1||Item 2|Item 3")
CTT2.Attach(DDL, "Gui Control DDL.")

Gui.OnEvent("Close", "ExitApp")
Gui.Show()
return
