#Warn
#SingleInstance Force

#Include RichEdit.ahk


Gui := GuiCreate()

RE := CreateRichEdit(Gui, "x0 y0 w550 h300 Multi", "Hola Mundo!")

Gui.OnEvent("Close", "ExitApp")
Gui.Show()
return




F1::ToolTip(RE.SetPlainText("hola mundo!"))

