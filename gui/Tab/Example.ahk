#Warn
#Include Tab.ahk

Gui := GuiCreate()
Gui.MarginX := 12
Gui.MarginY := 14
Gui.SetFont("s9", "Segoe UI")

TB := new Tab(Gui, "w500 h350 choose1", "Tab #1", "Tab #2", "Tab #3")

Gui.OnEvent("Close", "ExitApp")

Gui.Show()
return
