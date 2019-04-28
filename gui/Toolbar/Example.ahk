#Warn
#Include Toolbar.ahk

Gui := GuiCreate()
Gui.MarginX := 12
Gui.MarginY := 14
Gui.BackColor := 0xFFFFFF  ; White.
Gui.SetFont("s9", "Segoe UI")

TB1 := new Toolbar(Gui, "h40 Border Flat Trans")

; We are going to use system-defined button images.
TB1.LoadImages(0)
loop 10
{
    TB1.Add(, A_Index, "Item #" . A_Index, A_Index-1)
    if ( A_Index !== 10 )
        TB1.Add()  ; Adds a separator.
}
TB1.SetButtonSize(55, 40)
TB1.Ctrl.Move("w" . TB1.GetIdealSize(0))

TB2 := new Toolbar(Gui, "w100 Border Vertical List Trans")
TB2.LoadImages(8)
loop 5
{
    TB2.Add(, A_Index, "Item #" . A_Index, A_Index-1, 0x04|0x20)  ; TBSTATE_ENABLED|TBSTATE_WRAP.
    if ( A_Index !== 5 )
        TB2.Add()
}
TB2.SetButtonSize(100, 32)
TB2.Ctrl.Move("h" . TB2.GetIdealSize(1))

TB3 := new Toolbar(Gui, "yp xp+112 w" . (TB1.Ctrl.Pos.W-112) . " h" . TB2.Ctrl.Pos.H . " Border Wrapable List ToolTips Trans")
TB3.SetExStyle(0x8)  ; TBSTYLE_EX_MIXEDBUTTONS (https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-extended-styles).
                     ; This is to enable the ToolTips and hide the button's text (The 'List' and 'ToolTips' options are necessary).
TB3.LoadImages(4)
i := 0
loop 10
{
    loop DllCall("Comctl32.dll\ImageList_GetImageCount", "Ptr", TB3.GetImageList(), "Int")
        TB3.Add(, ++i, "Item #" . i, A_Index-1)
}

TB1.OnEvent(-2, "TB1_Events")  ; NM_CLICK.
TB2.OnEvent(-2, "TB2_Events")  ; NM_CLICK.

Gui.OnEvent("Close", "ExitApp")

Gui.Show("AutoSize")
return

; ------------------------------------------------------------------------------

TB1_Events(GuiControl, lParam)
{
    global Toolbar
    local  ; Force-local mode: Avoid interfering with super-global variables.

    ; GuiControl is the AHK's Custom Control.
    ; TB is our Toolbar class control.
    TB := new Toolbar( GuiControl )

    ; 'lParam' is a pointer to a structure, which depends on the type of message.
    ; The first member is always the NMCHAR structure: https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/ns-commctrl-tagnmchar.
    code := NumGet(lParam+2*A_PtrSize,"Int")  ; NMHDR.code: the notification code (EventName).

    /*
        Sent by a toolbar control when the user clicks an item with the left mouse button.
        Return value:
            Return TRUE to indicate that the mouse click was handled and suppress default processing by the system.
            Return FALSE to allow default processing of the click.
    */
    if ( code == -2 )  ; NM_CLICK.
    {
        ItemSpec := NumGet(lParam+3*A_PtrSize, "Ptr")  ; NMMOUSE.dwItemSpec: the item identifier of the button that was clicked.
        ToolTip( TB.GetText(ItemSpec) )  ; Shows the button's text.
        SetTimer("ToolTip", -500)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/nm-click-toolbar
}

TB2_Events(GuiControl, lParam)
{
    global Toolbar
    local

    TB   := new Toolbar( GuiControl )
    code := NumGet(lParam+2*A_PtrSize,"Int")

    if ( code == -2 )  ; NM_CLICK.
    {
        ItemSpec := NumGet(lParam+3*A_PtrSize, "Ptr")
        TB.SetState(ItemSpec, 0x01, -1)  ; TBSTATE_CHECKED.
    }
}
