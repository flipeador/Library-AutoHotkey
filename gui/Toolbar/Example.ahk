#Warn
#SingleInstance Force

#Include Toolbar.ahk


; -------------------------------------------------------------------------------
; Create the GUI Window.                                                        -
; -------------------------------------------------------------------------------
Gui := GuiCreate()
Gui.MarginX := 12
Gui.MarginY := 14
Gui.BackColor := 0xFFFFFF  ; White background color.
Gui.SetFont("s9", "Segoe UI")

; -------------------------------------------------------------------------------
; Create the first Toolbar control.                                             -
; -------------------------------------------------------------------------------
TB1 := CreateToolbar(Gui, "h40 Border Flat Trans")

; We are going to use system-defined button images.
TB1.LoadImages(0)  ; IDB_STD_SMALL_COLOR: Standard bitmaps in small size.
loop 10
{
    TB1.Add(, A_Index, "Item #" . A_Index, A_Index-1)
    if (A_Index !== 10)
        TB1.Add()  ; Adds a separator.
}
TB1.SetButtonSize(55, 40)
TB1.Ctrl.Move("w" . TB1.GetIdealSize())

; -------------------------------------------------------------------------------
; Create the second Toolbar control.                                            -
; -------------------------------------------------------------------------------
TB2 := CreateToolbar(Gui, "w100 Border Vertical List Trans")
TB2.LoadImages(8)  ; IDB_HIST_SMALL_COLOR: Windows Explorer bitmaps in small size.
loop 5
{
    TB2.Add(, A_Index, "Item #" . A_Index, A_Index-1, 0x04|0x20)  ; TBSTATE_ENABLED|TBSTATE_WRAP.
    if (A_Index !== 5)
        TB2.Add()
}
TB2.SetButtonSize(100, 32)
TB2.Ctrl.Move("h" . TB2.GetIdealSize())

; -------------------------------------------------------------------------------
; Create the third Toolbar control.                                             -
; -------------------------------------------------------------------------------
TB3 := CreateToolbar(Gui, "yp xp+112 w" . (TB1.Ctrl.Pos.W-112) . " h" . TB2.Ctrl.Pos.H . " Border Wrapable List ToolTips Trans")
TB3.SetExStyle(0x8)  ; TBSTYLE_EX_MIXEDBUTTONS (https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-extended-styles).
                     ; This is to enable the ToolTips and hide the button's text (The 'List' and 'ToolTips' options are necessary).
TB3.LoadImages(4)  ; IDB_VIEW_SMALL_COLOR: View bitmaps in small size.
i := 0
loop 10
{
    loop DllCall("Comctl32.dll\ImageList_GetImageCount", "Ptr", TB3.GetImageList(), "Int")
        TB3.Add(, ++i, "Item #" . i, A_Index-1)
}

; -------------------------------------------------------------------------------
; Register events and show the GUI window.                                      -
; -------------------------------------------------------------------------------
TB1.OnEvent(-2, "TB1_Events")  ; NM_CLICK.
TB2.OnEvent(-2, "TB2_Events")  ; NM_CLICK.

Gui.OnEvent("Close", "ExitApp")

Gui.Show("AutoSize")
return


; -------------------------------------------------------------------------------
; Functions.                                                                    -
; -------------------------------------------------------------------------------
TB1_Events(GuiControl, lParam)
{
    global IToolbar
    local  ; Force-local mode: Avoid interfering with super-global variables.

    ; «GuiControl» is the AHK's Custom control object.
    ; «Toolbar» is our Toolbar control class object.
    Toolbar := ToolbarFromHwnd(GuiControl)

    ; 'lParam' is a pointer to a structure, which depends on the type of message.
    ; The first member is always the NMCHAR structure: https://docs.microsoft.com/en-us/windows/win32/api/richedit/ns-richedit-nmhdr.
    Code := NumGet(lParam+2*A_PtrSize,"Int")  ; NMHDR.code: the notification code (EventName).

    /*
        Sent by a toolbar control when the user clicks an item with the left mouse button.
        lParam is a pointer to an NMMOUSE structure that contains additional information about this notification.
        Return value:
            Return TRUE to indicate that the mouse click was handled and suppress default processing by the system.
            Return FALSE to allow default processing of the click.
    */
    if (Code == -2)  ; NM_CLICK.
    {
        ItemSpec := NumGet(lParam+3*A_PtrSize, "Ptr")  ; NMMOUSE.dwItemSpec: the item identifier of the button that was clicked.
        ToolTip(Toolbar.GetButtonText(Toolbar.CommandToIndex(ItemSpec)))  ; Shows the button's text.
        SetTimer("ToolTip", -500)
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/nm-click-toolbar
}

TB2_Events(GuiControl, lParam)
{
    global IToolbar
    local

    Toolbar := ToolbarFromHwnd(GuiControl)
    Code    := NumGet(lParam+2*A_PtrSize,"Int")

    if (Code == -2)  ; NM_CLICK.
    {
        ItemSpec := NumGet(lParam+3*A_PtrSize, "Ptr")
        Toolbar.SetButtonState(Toolbar.CommandToIndex(ItemSpec), 0x01, -1)  ; TBSTATE_CHECKED.
    }
}
