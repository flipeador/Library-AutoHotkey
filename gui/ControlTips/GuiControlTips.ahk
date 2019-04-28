/*
    Credits / Thanks to:
        just me - http://ahkscript.org/boards/viewtopic.php?f=6&t=2598.
    Tooltip Control Reference:
        https://docs.microsoft.com/en-us/windows/desktop/controls/tooltip-control-reference.
    Tooltip Styles:
        https://docs.microsoft.com/en-us/windows/desktop/controls/tooltip-styles.
*/
class GuiControlTips
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Type         := "ControlTips"       ; The control type.
    static ClassName    := "tooltips_class32"  ; The control class.
    static Instance     := { }                 ; The control instances: {hwnd:obj}.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Gui            := 0                     ; The Gui Object.
    hGui           := 0                     ; The Gui handle.
    hWnd           := 0                     ; The control handle.
    IsActivated    := TRUE                  ; The control state. TRUE/FALSE = Activated/Deactivated.
    CtrlList       := { }                   ; The list of attached controls: {ctrl_hwnd:this}.
    TOOLINFO       := ""                    ; A TOOLINFO structure.
    pTOOLINFO      := 0                     ; Pointer to the TOOLINFO structure.
    
    
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Attaches a ToolTip control to the specified GUI window.
        Parameters:
            Gui:
                The GUI window object or handle.
        Remarks:
            The control is automatically destroyed when the specified Gui window is destroyed.
    */
    __New(Gui)
    {
        this.hGui := IsObject(Gui) ? Gui.hWnd : Gui
        if Type(this.Gui:=GuiFromHwnd(this.hGui)) !== "Gui"
            throw Exception("GuiControlTips class invalid parameter #1.", -1)

        this.hWnd := DllCall("User32.dll\CreateWindowEx", "UInt", 0x00000008                ; dwExStyle       WS_EX_TOPMOST.
                                                        , "WStr", GuiControlTips.ClassName  ; lpClassName     ClassName.
                                                        , "UPtr", 0                         ; lpWindowName    NULL.
                                                        , "UInt", 0x80000002                ; dwStyle         WS_POPUP|TTS_NOPREFIX.
                                                        ,  "Int", 0x80000000                ; x               CW_USEDEFAULT.
                                                        ,  "Int", 0x80000000                ; y               CW_USEDEFAULT.
                                                        ,  "Int", 0x80000000                ; nWidth          CW_USEDEFAULT.
                                                        ,  "Int", 0x80000000                ; nHeight         CW_USEDEFAULT.
                                                        , "UPtr", this.hGui                 ; hWndParent      HWND.
                                                        , "UPtr", 0                         ; hMenu           NULL.
                                                        , "UPtr", 0                         ; hInstance       NULL.
                                                        , "UPtr", 0                         ; lpParam         NULL.
                                                        , "UPtr")                           ; ReturnType      HWND.
        if !this.hWnd
            throw Exception("GuiControlTips class CreateWindowEx error " . A_LastError . ".", -1, "The control couldn't be created.")

        if ( GuiControlTips.Instance.Count() == 0 )
            OnMessage(0x02, "GuiControlTips_OnMessage")  ; WM_DESTROY.

        GuiControlTips.Instance[this.hWnd] := this

        local size := A_PtrSize == 4 ? 48 : 72
        this.SetCapacity("TOOLINFO", size)
        this.pTOOLINFO := this.GetAddress("TOOLINFO")

        NumPut(size     , this.pTOOLINFO  , "UInt")  ; cbSize        Size of this structure, in bytes.
        NumPut(this.hGui, this.pTOOLINFO+8, "UPtr")  ; hwnd          Handle to the window that contains the tool.

        ; TTM_SETMAXTIPWIDTH message.
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-setmaxtipwidth.
        SendMessage(0x418,, -1, this)  ; Maximum tooltip window width, -1 to allow any width.

        ; TTM_SETDELAYTIME message.
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-setdelaytime.
        SendMessage(0x403, 0, -1, this)  ; Return all three delay times to their default values.
    }

    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Destroys the control.
    */
    Destroy()
    {
        GuiControlTips.Instance.Delete(this.hWnd)
        this.CtrlList := ""
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd, "Int")

        local hFont := SendMessage(0x31,,,this)
        if ( hFont )
            DllCall("Gdi32.dll\DeleteObject", "Ptr", hFont, "Int")

        if ( GuiControlTips.Instance.Count() == 0 )
            OnMessage(0x02, "GuiControlTips_OnMessage", 0)  ; WM_DESTROY.
    }

    /*
        Registers a control with this tooltip control.
        Parameters:
            Control:
                The Gui Control object or handle.
                The control must belong to the window in which this tooltip was attached.
            Text:
                The tooltip text for the specified control.
            Flags:
                Flags that control the tooltip display. This member can be a combination of the following values.
                0x0002 (TTF_CENTERTIP)         Centers the tooltip window below the tool specified by the uId member.
        Return value:
            Returns TRUE if it succeeded, or FALSE otherwise.
        Remarks:
            If the control is already registered, it only updates the ToolTip text for this control.
            Returns an exception if the control is invalid.
    */
    Attach(Control, Text, Flags := 0)
    {
        Control := IsObject(Control) ? Control : GuiCtrlFromHwnd(Control)
        if !( Type(Control) ~= "^Gui.+" )  ; Checks if the control is valid.
            throw Exception("GuiControlTips.Attach() invalid parameter #1.", -1, "Invalid Gui Control.")
        if ( Control.Gui.hWnd !== this.hGui )  ; Checks if the control belongs to the Gui window associated with this object.
            throw Exception("GuiControlTips.Attach() invalid parameter #1.", -1, "The control does not belong to the Gui window associated with this object.")

        if  ( WinGetClass("ahk_id" . Control.hWnd) == "Static" )
        && !( WinGetStyle("ahk_id" . Control.hWnd)  & 0x100    )
            WinSetStyle("+0x100", "ahk_id" . Control.hWnd)

        NumPut(0x11|Flags  , this.pTOOLINFO+4             , "UInt")
        NumPut(Control.hWnd, this.pTOOLINFO+8+A_PtrSize   , "UPtr")
        NumPut(&Text       , this.pTOOLINFO+24+3*A_PtrSize, "UPtr")

        if this.CtrlList.HasKey(Control.hWnd)  ; Checks if the control is already registered.
            return 0*SendMessage(0x439,,this.pTOOLINFO,this) + 1  ; TTM_UPDATETIPTEXT message.

        if !SendMessage(0x432,, this.pTOOLINFO, this)
            return FALSE
        this.CtrlList[Control.hWnd] := this
        return TRUE
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-addtool
    
    /*
        Removes a control previously registered.
        Parameters:
            Control:
                The Gui Control object or handle.
                The control must belong to the window in which this tooltip was attached.
        Return value:
            Returns TRUE if the control was successfully removed, or FALSE if the control is not registered.
    */
    Detach(Control)
    {
        Control := IsObject(Control) ? Control.hWnd : Control
        if !this.CtrlList.HasKey(Control)  ; Checks if the control is not registered.
            return FALSE

        if ( WinGetClass("ahk_id" . Control) == "Static" )
        && ( WinGetStyle("ahk_id" . Control)  & 0x100    )
            WinSetStyle("-0x100", "ahk_id" . Control)

        NumPut(Control, this.pTOOLINFO+8+A_PtrSize, "Ptr")
        SendMessage(0x433,, this.pTOOLINFO, this)
        this.CtrlList.Delete(Control)
        return TRUE
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-deltool

    /*
        Activates or deactivates this tooltip control.
        Parameters:
            Mode:
                -1         Toggles the current state.
                 0         The tooltip control is activated (it can be any value evaluated as false).
                 1         The tooltip control is deactivated (it can be any value evaluated as true except -1).
    */
    Activate(Mode)
    {
        Mode := Mode == -1 ? (this.IsActivated := !this.IsActivated) : (this.IsActivated := !!Mode)
        SendMessage(0x401, Mode,, this)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760326(v=vs.85).aspx
    
    /*
        Retrieves the initial, pop-up, and reshow durations currently set for a tooltip control.
        Return value:
            Returns an object with the keys 'Initial', 'AutoPop' and 'ReShow'.
            For the description of these keys, see the SetDelayTimes method.
    */
    GetDelayTimes()
    {
        Return { Initial:  SendMessage(0x0415,3,,this)
               , AutoPop:  SendMessage(0x0415,2,,this)
               ,  ReShow:  SendMessage(0x0415,1,,this) }
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-getdelaytime

    /*
        Sets the initial, pop-up, and reshow durations for a tooltip control.
        Parameters:
            Initial:
                Set the amount of time a pointer must remain stationary within a tool's bounding rectangle before the tooltip window appears.
            AutoPop:
                Set the amount of time the tooltip remains visible if the pointer is stationary within a tool's bounding rectangle.
            ReShow:
                Set the amount of time it takes for subsequent tooltip windows to appear as the pointer moves from one tool to another.
        Remarks:
            If you specify an empty string in some parameter, the current value is not modified.
            Delay times are specified in milliseconds.
    */
    SetDelayTimes(Initial := "", AutoPop := "", ReShow := "")
    {
        loop parse, ReShow . "|" . AutoPop . "|" . Initial, "|"
            if A_LoopField !== ""
                SendMessage(0x0403, A_Index, Integer(A_LoopField), this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-setdelaytime

    /*
        Adds or removes the title for this tooltip.
        Parameters:
            Title:
                The title to be displayed for this tooltip. An empty string does not show any title.
                This parameter can be a pointer to a null terminated string.
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
    */
    SetTitle(Title, Icon := 0)
    {
        SendMessage(0x421, Icon, type(Title)="integer"?Title:&Title, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-settitle

    /*
        Sets the text font for this tooltip.
    */
    SetFont(Options, FontName)
    {
        local

        ; https://docs.microsoft.com/es-es/windows/desktop/winmsg/wm-getfont
        if ( hFont := SendMessage(0x31,,,this) )
            DllCall("Gdi32.dll\DeleteObject", "Ptr", hFont, "Int")

        hDC := DllCall("Gdi32.dll\CreateDCW", "Str", "DISPLAY", "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
        R   := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 90, "Int")
        DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC, "Int")
            
        Size      := RegExMatch(Options, "i)s([\-\d\.]+)(p*)", t) ? t[1] : 10
        Height    := Round((Abs(Size) * R) / 72) * -1
        Quality   := RegExMatch(Options, "i)q([\-\d\.]+)(p*)", t) ? t[1] : 5
        Weight    := RegExMatch(Options, "i)w([\-\d\.]+)(p*)", t) ? t[1] : (InStr(Options, "Bold") ? 700 : 400)
        Italic    := !!InStr(Options, "Italic")
        Underline := !!InStr(Options, "Underline")
        Strike    := !!InStr(Options, "Strike")
        
        SendMessage(0x30
                  , DllCall("Gdi32.dll\CreateFontW","Int",Height,"Int",0,"Int",0,"Int",0,"Int",Weight,"UInt",Italic,"UInt",Underline,"UInt",Strike,"UInt",1,"UInt",4,"UInt",0,"UInt",Quality,"UInt",0,"Ptr",&FontName,"Ptr")
                  , TRUE, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/winmsg/wm-setfont
}





GuiControlTips_OnMessage(wParam, lParam, Msg, hWnd)
{
    global GuiControlTips
    local

    if ( Msg == 0x02 )  ; WM_DESTROY.
    {
        for ctrl_hwnd, ctrl_obj in GuiControlTips.Instance.Clone()
            if ( ctrl_obj.hGui == hWnd )
                ctrl_obj.Destroy()
    }
}
