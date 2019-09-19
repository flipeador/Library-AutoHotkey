; AutoHotkey v2.0-a104-3e7a969d.

/*
    Encapsulates the creation and manipulation of tooltips for controls in a class.
    Remarks:
        DllCall is used instead of SendMessage to improve performance.
        Include this file in the Auto-execute Section of the script.
    Requirements:
        Windows Vista or later.
    Tooltip Control Reference:
        https://docs.microsoft.com/es-es/windows/win32/controls/tooltip-control-reference
    Thanks to / Credits:
        just me - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2598
*/
class IGuiControlTips  ; https://github.com/flipeador  |  https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=60315
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Type         := "GuiControlTips"    ; A string with the control type name.
    static ClassName    := "tooltips_class32"  ; A string with the control class name.
    static Instance     := Map()               ; Instances of this control (ctrl_handle:this).


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Gui          := 0         ; The Gui object associated with this control.
    hWnd         := 0         ; The control Handle.
    TTTOOLINFO   := 0         ; The TTTOOLINFO structure contains information about a tool in a tooltip control.
    IsActivated  := TRUE      ; The control state. TRUE/FALSE (Activated/Deactivated).
    CtrlList     := Map()     ; The list of attached controls (ctrl_handle:0).


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Creates a tooltip control and associates it with the specified GUI window. The GuiControlTips function can be used to create the control.
        Parameters:
            Gui:
                The GUI window object. This object must be previously created by a call to the GuiCreate function.
                The Tooltip will be associated with this window. Using the Add method you can configure the tooltip for the controls.
        Remarks:
            You can create more than one Tooltip for the same window, useful to have different font and title for each control.
            An existing Tooltip control object can be retrieved by means of its handle using the GuiTooltipFromHwnd function.
    */
    __New(Gui)
    {
        if (Type(this.Gui:=Gui) !== "Gui")
            throw Exception("IGuiControlTips.New() - Invalid parameter #1.", -1)

        this.hWnd := DllCall("User32.dll\CreateWindowEx", "UInt", 0x00000008                 ; dwExStyle       WS_EX_TOPMOST.
                                                        , "WStr", IGuiControlTips.ClassName  ; lpClassName     ClassName.
                                                        , "UPtr", 0                          ; lpWindowName    NULL.
                                                        , "UInt", 0x80000002                 ; dwStyle         WS_POPUP|TTS_NOPREFIX.
                                                        ,  "Int", 0x80000000                 ; x               CW_USEDEFAULT.
                                                        ,  "Int", 0x80000000                 ; y               CW_USEDEFAULT.
                                                        ,  "Int", 0x80000000                 ; nWidth          CW_USEDEFAULT.
                                                        ,  "Int", 0x80000000                 ; nHeight         CW_USEDEFAULT.
                                                        , "UPtr", this.Gui.Hwnd              ; hWndParent      HWND.
                                                        , "UPtr", 0                          ; hMenu           NULL.
                                                        , "UPtr", 0                          ; hInstance       NULL.
                                                        , "UPtr", 0                          ; lpParam         NULL.
                                                        , "UPtr")                            ; ReturnType      HWND.
        if (this.hWnd == 0)
            throw Exception(Format("IGuiControlTips.New() - CreateWindowExW error 0x{:08X}",A_LastError), -1)

        ; TTTOOLINFOW structure.
        ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfow.
        ; We initialize only one structure to use with all methods, to improve performance and for convenience.
        this.TTTOOLINFO := BufferAlloc(24+6*A_PtrSize)

        NumPut("UInt", this.TTTOOLINFO.Size, this.TTTOOLINFO)     ; cbSize    Size of this structure, in bytes.
        NumPut("UPtr", This.Gui.Hwnd       , this.TTTOOLINFO, 8)  ; hwnd      Handle to the window that contains the tool.

        ; TTM_SETMAXTIPWIDTH message.
        ; https://docs.microsoft.com/en-us/windows/win32/controls/ttm-setmaxtipwidth.
        SendMessage(0x418,, 0, this)  ; Sets the maximum width for a tooltip control (0 to allow any width).

        ; TTM_SETDELAYTIME message.
        ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-setdelaytime.
        SendMessage(0x403, 0, -1, this)  ; Reset all three delay times to their default values.

        IGuiControlTips.Instance[this.Ptr:=this.hWnd] := this
    }

    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Destroys the control and releases all associated resources.
        This method is automatically called when the parent window is destroyed.
    */
    Destroy()
    {
        local GuiControl
        for GuiControl in this.CtrlList.Clone()
            this.Remove(GuiControl)
        this.CtrlList := ""
        DllCall("Gdi32.dll\DeleteObject", "Ptr", SendMessage(0x31,,,this))  ; Deletes the current assigned font.
        IGuiControlTips.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this)
    }

    /*
        Registers a control with this Tooltip control.
        Parameters:
            GuiControl:
                The Gui Control object or handle.
                The control must belong to the window in which this tooltip was associated.
            Text:
                A string with the tooltip text for the specified control.
            Flags:
                Flags that control the tooltip display. This parameter can be a combination of the following values.
                0x0002  TTF_CENTERTIP    Centers the tooltip window below the specified control.
        Return value:
            Returns TRUE if it succeeded, or FALSE otherwise.
        Remarks:
            If the specified control is already registered, it is deregistered and re-registered with the new parameters.
    */
    Add(GuiControl, Text, Flags := 0)
    {
        GuiControl := IsObject(GuiControl) ? GuiControl.Hwnd : GuiControl
        if !DllCall("User32.dll\GetParent", "Ptr", GuiControl, "Ptr")
            throw Exception("IGuiControlTips.Add() - Invalid parameter #1.", -1)

        DetectHiddenWindows(TRUE)
        if  (WinGetClass("ahk_id" . GuiControl) == "Static")
        && !(WinGetStyle("ahk_id" . GuiControl)  &    0x100)  ; SS_NOTIFY.
            WinSetStyle("+0x100", "ahk_id" . GuiControl)

        NumPut("UInt", 0x11|Flags, this.TTTOOLINFO, 4)               ; uFlags    TTDT_RESHOW | TTF_SUBCLASS.
        NumPut("UPtr", GuiControl, this.TTTOOLINFO, 8+A_PtrSize)     ; uId       Application-defined identifier of the tool.
        NumPut("UPtr", &Text     , this.TTTOOLINFO, 24+3*A_PtrSize)  ; lpszText  Pointer to the buffer that contains the text for the tool.

        if this.CtrlList.Has(GuiControl)  ; Checks if the control is already registered.
        {
            ; TTM_DELTOOL message.
            ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-deltool.
            DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x433, "Ptr", 0, "Ptr", this.TTTOOLINFO, "Ptr")
            this.CtrlList.Delete(GuiControl)  ; Removes the control from the list of registered controls.
        }

        ; TTM_ADDTOOL message.
        ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-addtool.
        if !DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x432, "Ptr", 0, "Ptr", this.TTTOOLINFO, "Ptr")
            return FALSE

        this.CtrlList[GuiControl] := 0  ; Adds the control to the list of registered controls.
        return TRUE
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-addtool

    /*
        Removes a control previously registered.
        Parameters:
            GuiControl:
                The Gui Control object or handle.
        Return value:
            Returns TRUE if it succeeded, or FALSE otherwise.
    */
    Remove(GuiControl)
    {
        GuiControl := IsObject(GuiControl) ? GuiControl.Hwnd : GuiControl
        if !this.CtrlList.Has(GuiControl)  ; Checks if the control is not registered.
            return FALSE

        NumPut("UPtr", GuiControl, this.TTTOOLINFO, 8+A_PtrSize)  ; uId  Application-defined identifier of the tool.

        ; TTM_DELTOOL message.
        ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-deltool.
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x433, "Ptr", 0, "Ptr", this.TTTOOLINFO, "Ptr")

        this.CtrlList.Delete(GuiControl)  ; Removes the control from the list of registered controls.
        return TRUE
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-deltool

    /*
        Activates or deactivates the Tooltip control.
        Parameters:
            Mode:
                -1    Toggles the current state.
                 0    The tooltip control is activated (it can be any value evaluated as false).
                 1    The tooltip control is deactivated (it can be any value evaluated as true except -1).
        Return value:
            The return value for this method is not used.
    */
    Activate(Mode)
    {
        Mode := Mode == -1 ? (this.IsActivated := !this.IsActivated) : (this.IsActivated := !!Mode)
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x401, "Ptr", Mode, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/ttm-activate

    /*
        Retrieves the initial, pop-up, and reshow durations currently set for the Tooltip control.
        Return value:
            Returns an object with the properties Initial, AutoPop and ReShow.
    */
    GetDelayTimes()
    {
        Return { Initial:  SendMessage(0x0415,3,,this)    ; TTDT_INITIAL = 3. TTDT_AUTOMATIC = 0. TTM_GETDELAYTIME message.
               , AutoPop:  SendMessage(0x0415,2,,this)    ; TTDT_AUTOPOP = 2.
               ,  ReShow:  SendMessage(0x0415,1,,this) }  ; TTDT_RESHOW  = 1.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-getdelaytime

    /*
        Sets the initial, pop-up, and reshow durations for a tooltip control.
        Parameters:
            Initial:
                Set the amount of time a pointer must remain stationary within a tool's bounding rectangle before the tooltip window appears.
            AutoPop:
                Set the amount of time the tooltip remains visible if the pointer is stationary within a tool's bounding rectangle.
            ReShow:
                Set the amount of time it takes for subsequent tooltip windows to appear as the pointer moves from one tool to another.
        Return value:
            The return value for this method is not used.
        Remarks:
            If you specify an empty string in some parameter, the current value is not modified.
            Delay times are specified in milliseconds.
    */
    SetDelayTimes(Initial := "", AutoPop := "", ReShow := "")
    {
        loop parse, ReShow . A_Tab . AutoPop . A_Tab . Initial, A_Tab  ; TTDT_RESHOW | TTDT_AUTOPOP | TTDT_INITIAL.
            if (A_LoopField !== "")
                DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x403, "Ptr", A_Index, "Ptr", A_LoopField, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-setdelaytime

    /*
        Adds or removes the title for this tooltip.
        Parameters:
            Title:
                A string with the title to be displayed for this tooltip.
                If this parameter is an empty string, no title will be shown.
            Icon:
                Specify the icon to be displayed for this tooltip. You must specify one of the following values.
                0  TTI_NONE              No icon.
                1  TTI_INFO              Info icon.
                2  TTI_WARNING           Warning icon.
                3  TTI_ERROR             Error Icon.
                4  TTI_INFO_LARGE        Large info Icon.
                5  TTI_WARNING_LARGE     Large warning Icon.
                6  TTI_ERROR_LARGE       Large error Icon.
                This parameter can be an icon handle (HICON). Any value greater than 6 (TTI_ERROR_LARGE) is assumed to be an HICON.
        Remarks:
            The title of a tooltip appears above the text, in a different font. It is not sufficient to have a title; the tooltip must have text as well, or it is not displayed.
            When 'Icon' contains an HICON, a copy of the icon is created by the tooltip window.
            The string specified in 'Title' must not exceed 99 characters in length.
        Return value:
            The return value for this method is not used.
    */
    SetTitle(Title, Icon) => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x421, "Ptr", Icon, "Str", Title, "Ptr")
    ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-settitle

    /*
        Sets the text font typeface, size and style of the Tooltip control.
        Parameters:
            Options:
                A string with the font size and style.
                Available options: sN (size), wiN (width), wN (weight), qN (quality), cN (charSet), Bold (w700), Italic, Underline, Strike.
            FontName:
                The typeface name of the font. The length of this string must not exceed 31 characters.
                If this parameter is an empty string, the first font that matches the other specified attributes is used.
        Return value:
            The return value for this method is not used.
    */
    SetFont(Options, FontName)
    {
        DllCall("Gdi32.dll\DeleteObject", "Ptr", SendMessage(0x31,,,this))  ; Deletes the current assigned font.

        local hDC        := DllCall("Gdi32.dll\CreateDCW", "Str", "DISPLAY", "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
        local LOGPIXELSY := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 90)  ; Number of pixels per logical inch along the screen height.

        local t, Size := RegExMatch(Options,"i)s([\d]+)",t) ? t[1] : 10  ; 10 = Default size.
        local hFont := DllCall("Gdi32.dll\CreateFontW",  "Int", -Round((Abs(Size)*LOGPIXELSY)/72)                                          ; int     cHeight.
                                                      ,  "Int", RegExMatch(Options,"i)wi([\-\d]+)",t) ? t[1] : 0                           ; int     cWidth.
                                                      ,  "Int", 0                                                                          ; int     cEscapement.
                                                      ,  "Int", !DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC)                                 ; int     cOrientation.
                                                      ,  "Int", RegExMatch(Options,"i)w([\-\d]+)",t) ? t[1] : (Options~="i)Bold"?700:400)  ; int     cWeight.
                                                      , "UInt", Options ~= "i)Italic"    ? TRUE : FALSE                                    ; DWORD   bItalic.
                                                      , "UInt", Options ~= "i)Underline" ? TRUE : FALSE                                    ; DWORD   bUnderline.
                                                      , "UInt", Options ~= "i)Strike"    ? TRUE : FALSE                                    ; DWORD   bStrikeOut.
                                                      , "UInt", RegExMatch(Options,"i)c([\d]+)",t) ? t[1] : 1                              ; DWORD   iCharSet.
                                                      , "UInt", 4                                                                          ; DWORD   iOutPrecision.
                                                      , "UInt", 0                                                                          ; DWORD   iClipPrecision.
                                                      , "UInt", RegExMatch(Options,"i)q([0-5])",t) ? t[1] : 5                              ; DWORD   iQuality.
                                                      , "UInt", 0                                                                          ; DWORD   iPitchAndFamily.
                                                      , "UPtr", &FontName                                                                  ; LPCWSTR pszFaceName.
                                                      , "UPtr")

        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x30, "Ptr", hFont, "Ptr", TRUE, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/winmsg/wm-setfont
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
OnMessage(0x02, "IGuiControlTips_OnMessage")  ; WM_DESTROY.

IGuiControlTips_OnMessage(wParam, lParam, Message, hWnd)
{
    global IGuiControlTips
    local

    switch Message
    {
    case 0x0002:  ; WM_DESTROY.
        for ctrl_hwnd, ctrl_obj in IGuiControlTips.Instance.Clone()
        {
            if (ctrl_obj.Gui.Hwnd == hWnd)
            {
                ctrl_obj.Destroy()
            }
        }
    }
}

GuiControlTips(Gui)
{
    return IGuiControlTips.New(Gui)
}

GuiTooltipFromHwnd(Hwnd)
{
    return IGuiControlTips.Instance[IsObject(Hwnd)?Hwnd.hWnd:Hwnd]
}
