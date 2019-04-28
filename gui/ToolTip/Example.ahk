#Warn
#Include ToolTip.ahk

CoordMode("Mouse", "Screen")

; ------------------------------------------------------------------------------------

MyTT := new ToolTip()

TT1 := new ToolTip()
TT1.SetTitle("ToolTip #1", 1)
TT1.SetFont("s12 Italic Underline", "Courier New")

TT2 := new ToolTip()
TT2.SetTitle("ToolTip #2", 2)

TT3 := new ToolTip()
TT3.SetFont("s12", "Arial Black")
TT3.Show("This will disappear in 5 seconds!", A_ScreenWidth//2, A_ScreenHeight//2, 5000)

loop
{
    TT1.Show("My ToolTip Text")

    WinGetPos(X, Y, W, H, "ahk_id" . TT1.hWnd)
    TT2.Show("X: " . X . ", Y: " . Y . "`nW: " . W . ", H: " . H, 5, 5)

    sleep(50)
}
until GetKeyState("Esc")  ; ESC = EXITAPP
ExitApp

; ------------------------------------------------------------------------------------
