#Warn
#SingleInstance Force
#NoTrayIcon

#Include ComboBoxEx.ahk


Gui := GuiCreate()
Gui.MarginX := 12
Gui.MarginY := 14
Gui.SetFont("s9", "Segoe UI")

CB1 := CreateComboBox(Gui, "w200 r10 Simple")
CB2 := CreateComboBox(Gui, "y+14 w" . (Gui.MarginX+2*CB1.Ctrl.Pos.W))
DDL := CreateComboBox(Gui, "x" . (2*Gui.MarginX+CB1.Ctrl.Pos.W) . " ys w" . CB1.Ctrl.Pos.W . " DDL")

ImageList := IL_Create()
IL_Add(ImageList, "shell32.dll", 9)  ; HDD.
IL_Add(ImageList, "shell32.dll", 4)  ; File.
IL_Add(ImageList, "shell32.dll", 3)  ; Folder.

CB1.SetImageList(ImageList)
DDL.SetImageList(ImageList)

CB2.SetCueBanner("Put some text here!  :)", TRUE)

DDL.OnEvent("SelChange", "CBN_SELCHANGE")

Gui.OnEvent("Close", "ExitApp")

Gui.Show()

loop parse, DriveGetList()
    if ( InStr("removable|fixed",DriveGetType(A_LoopField)) )
            DDL.Add(, A_LoopField . ":\" . DriveGetLabel(A_LoopField . ":") . " (" . DriveGetFileSystem(A_LoopField . ":") . ") [" . DriveGetSerial(A_LoopField . ":") . "]")
DDL.SetCurSel(0)
CBN_SELCHANGE(DDL)
return





CBN_SELCHANGE(GuiControl)
{
    global CB1, DDL
    local Path := SubStr(DDL.GetItemText(DDL.Selection), 1, 2)

    CB1.DeleteAll()
    loop files, Path . "\*", "FD"
    {
        if InStr(A_LoopFileAttrib, "D")
            CB1.Add(, A_LoopFileName, 1, 1)
        else
            CB1.Add(, A_LoopFileName, 2, 2)
    }
    CB1.Selection := 0
} ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbn-selchange
