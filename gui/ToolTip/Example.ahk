#Warn
#SingleInstance Force

#Include ToolTip.ahk


CoordMode("Mouse", "Screen")

TT1 := CreateTooltip("ToolTip #1", 1)
TT1.SetFont("s12 Italic Underline", "Courier New")

TT2 := CreateTooltip("ToolTip #2", 2)

TT3 := CreateTooltip()
TT3.SetFont("s12", "Arial Black")
TT3.Show("This will disappear in 5 seconds!", A_ScreenWidth//2, A_ScreenHeight//2, 5000)

while (!GetKeyState("Esc"))  ; Escape = ExitApp.
{
    TT1.Show("My ToolTip Text")

    WinGetPos(X, Y, W, H, "ahk_id" . TT1.hWnd)
    TT2.Show("X: " . X . ", Y: " . Y . "`nW: " . W . ", H: " . H, 5, 5)

    Sleep(50)
}
ExitApp
