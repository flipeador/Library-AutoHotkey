; AutoHotkey v2.0-a104-3e7a969d.

/*
    Encapsulates the creation and manipulation by means of messages of a standart Tooltip control in a class.
    Remarks:
        DllCall is used instead of SendMessage to improve performance.
    Requirements:
        Windows Vista or later.
    Tooltip Control Reference:
        https://docs.microsoft.com/es-es/windows/win32/controls/tooltip-control-reference
    Thanks to / Based on:
        just me - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2598
*/
class IToolTip  ; https://github.com/flipeador  |  https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=60315
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Type         := "ToolTip"           ; A string with the control type name.
    static ClassName    := "tooltips_class32"  ; A string with the control class name.
    static Instance     := Map()               ; Instances of this control (ctrl_handle:this).


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    hWnd         := 0         ; The control Handle.
    TTTOOLINFO   := 0         ; The TTTOOLINFO structure contains information about a tool in a tooltip control.
    Timer        := 0         ; Tooltip timer.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Creates a topmost tooltip control. The CreateTooltip function can be used to create the control.
        Remakrs:
            An existing Tooltip control object can be retrieved by means of its handle using the TooltipFromHwnd function.
    */
    __New()
    {
        ; CreateWindowExW function.
        ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexw.
        This.hWnd := DllCall("User32.dll\CreateWindowExW", "UInt", 0x00000008          ; dwExStyle         WS_EX_TOPMOST.
                                                         , "WStr", IToolTip.ClassName  ; lpClassName       https://msdn.microsoft.com/en-us/library/windows/desktop/bb760250(v=vs.85).aspx.
                                                         , "UPtr", 0                   ; lpWindowName      NULL.
                                                         , "UInt", 0x80000003          ; dwStyle           WS_POPUP|TTS_NOPREFIX|TTS_ALWAYSTIP.
                                                         ,  "Int", 0x80000000          ; x                 CW_USEDEFAULT.
                                                         ,  "Int", 0x80000000          ; y                 CW_USEDEFAULT.
                                                         ,  "Int", 0x80000000          ; nWidth            CW_USEDEFAULT.
                                                         ,  "Int", 0x80000000          ; nHeight           CW_USEDEFAULT.
                                                         , "UPtr", 0                   ; hWndParent        NULL (ignored).
                                                         , "UPtr", 0                   ; hMenu             NULL.
                                                         , "UPtr", 0                   ; hInstance         NULL.
                                                         , "UPtr", 0                   ; lpParam           NULL.
                                                         , "UPtr")                     ; ReturnType        HWND.
        if (this.hWnd == 0)
            throw Exception(Format("IToolTip.New() - CreateWindowExW error 0x{:08X}",A_LastError), -1)

        ; TTTOOLINFOW structure.
        ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfow.
        ; We initialize only one structure to use with all methods, to improve performance.
        this.TTTOOLINFO := BufferAlloc(24+6*A_PtrSize)

        NumPut("UInt", this.TTTOOLINFO.Size, this.TTTOOLINFO)                  ; cbSize    Size of this structure, in bytes.
        NumPut("UInt", 0x0001|0x0020|0x0080, this.TTTOOLINFO, 4)               ; uFlags    TTDT_RESHOW | TTF_TRACK | TTF_ABSOLUTE.
        NumPut("UPtr", This.hWnd           , this.TTTOOLINFO, 8)               ; hwnd      Handle to the window that contains the tool.
        NumPut("UPtr", This.hWnd           , this.TTTOOLINFO, 8+A_PtrSize)     ; uId       Application-defined identifier of the tool.
        NumPut("UPtr", &A_Space            , this.TTTOOLINFO, 24+3*A_PtrSize)  ; lpszText  Pointer to the buffer that contains the text for the tool.

        ; TTM_ADDTOOL message.
        ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-addtool.
        SendMessage(0x432,, this.TTTOOLINFO, this)  ; Registers a tool with a tooltip control.

        ; TTM_SETMAXTIPWIDTH message.
        ; https://docs.microsoft.com/en-us/windows/win32/controls/ttm-setmaxtipwidth.
        SendMessage(0x418,, 0, this)  ; Sets the maximum width for a tooltip control (0 to allow any width).

        IToolTip.Instance[this.Ptr:=this.hWnd] := this
        this.Timer := ObjBindMethod(this, "Show", "")  ; Timer to hide the Tooltip control.
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Destroys the control and releases all associated resources.
    */
    Destroy()
    {
        this.Timer := SetTimer(this.Timer, "Delete")  ; Deletes the timer.
        DllCall("Gdi32.dll\DeleteObject", "Ptr", SendMessage(0x31,,,this))  ; Deletes the current assigned font.
        IToolTip.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", This)
    }

    /*
        Show, hide, move or change the text of the Tooltip control.
        Parameters:
            Text:
                A string with the new text for this tooltip. The text is only modified if necessary (to avoid flickering).
                If this parameter is an empty string, the tooltip will be hidden.
                If this parameter is omitted, the text is not changed.
            X / Y:
               The X and Y coordinates where to show this tooltip.
               if an empty string is specified, the current coordinates of the cursor are used. Coordinates are affected by A_CoordModeMouse.
               When some coordinate is omitted, it is automatically adjusted on the screen, so that the ToolTip is always visible on it.
            Duration:
                Specifies the timeout, in milliseconds, of the Tooltip. After this time the Tooltip is hidden.
                If this parameter is zero, the current timer is disabled, if any.
                If this parameter is an empty string, the current timer is not changed, if any.
        Return value:
            The return value for this method is not used.
    */
    Show(Text := "`b", X := "", Y := "", Duration := "")
    {
        local

        if (Text == "")  ; Hides the Tooltip window.
            ; TTM_TRACKACTIVATE message.
            ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-trackactivate.
            return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x411, "Ptr", FALSE, "Ptr", this.TTTOOLINFO, "Ptr")  ; Hide.

        if (Text !== "`b" && Text !== this.Text)  ; Changes the text only if it is not the same as the specified text.
            this.Text := Text

        if (Duration !== "")
            SetTimer(this.Timer, Duration?-Abs(Duration):"Off")
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x411, "Ptr", TRUE, "Ptr", this.TTTOOLINFO, "Ptr")  ; Show.

        if (X == "" || Y == "")
        {
            ; TTM_GETBUBBLESIZE message.
            ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-getbubblesize.
            BSize := DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x41E, "Ptr", !MouseGetPos(X2,Y2)*0, "Ptr", this.TTTOOLINFO, "Ptr")
            if (X == "")
                W := BSize&0xFFFF, X := X2 + 10, X := X + W > (VW:=SysGet(78)) ? X - (X + W - VW) : X
            if (Y == "")
                H := (BSize>>16)&0xFFFF, Y := Y2 + 10, Y := Y + H > SysGet(79) ? Y - H - 10 : Y
        }

        ; TTM_TRACKPOSITION message.
        ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-trackposition.
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x412, "Ptr", 0, "Ptr", (X&0xFFFF)|((Y&0xFFFF)<<16), "Ptr")
    }

    /*
        Sets a timer for this tooltip.
        Parameters:
            Duration:
                Specifies the timeout, in milliseconds, of the Tooltip. After this time the Tooltip is hidden.
                You must specify an integer greater than or equal to zero. A value of zero deactivates the timer.
        Return value:
            The return value for this method is not used.
    */
    SetTimer(Duration) => SetTimer(this.Timer, Duration?-Abs(Duration):"Off")

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
    SetTitle(Title, Icon := 0)
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x421, "Ptr", Icon, "Str", Title, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-settitle

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
        local LOGPIXELSY := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 90, "Int")  ; Number of pixels per logical inch along the screen height.

        local t, Size := RegExMatch(Options,"i)s([\-\d\.]+)(p*)",t) ? t[1] : 10  ; 10 = Default size.
        local hFont := DllCall("Gdi32.dll\CreateFontW",  "Int", -Round((Abs(Size)*LOGPIXELSY)/72)                                          ; int     cHeight.
                                                      ,  "Int", RegExMatch(Options,"i)wi([\-\d]+)",t) ? t[1] : 0                           ; int     cWidth.
                                                      ,  "Int", 0                                                                          ; int     cEscapement.
                                                      ,  "Int", !DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC)                                 ; int     cOrientation.
                                                      ,  "Int", RegExMatch(Options,"i)w([\-\d]+)",t) ? t[1] : (Options~="i)Bold"?700:400)  ; int     cWeight.
                                                      , "UInt", Options ~= "i)Italic"    ? TRUE : FALSE                                    ; DWORD   bItalic.
                                                      , "UInt", Options ~= "i)Underline" ? TRUE : FALSE                                    ; DWORD   bUnderline.
                                                      , "UInt", Options ~= "i)Strike"    ? TRUE : FALSE                                    ; DWORD   bStrikeOut.
                                                      , "UInt", RegExMatch(Options,"i)c([\-\d]+)",t) ? t[1] : 1                            ; DWORD   iCharSet.
                                                      , "UInt", 4                                                                          ; DWORD   iOutPrecision.
                                                      , "UInt", 0                                                                          ; DWORD   iClipPrecision.
                                                      , "UInt", RegExMatch(Options,"i)q([0-5])",t) ? t[1] : 5                              ; DWORD   iQuality.
                                                      , "UInt", 0                                                                          ; DWORD   iPitchAndFamily.
                                                      , "UPtr", &FontName                                                                  ; LPCWSTR pszFaceName.
                                                      , "UPtr")

        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x30, "Ptr", hFont, "Ptr", TRUE, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/winmsg/wm-setfont

    /*
        Forces the current tooltip to be redrawn.
        Return value:
            The return value for this method is not used.
    */
    Update()
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x412, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-update


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Retrieves or changes the Tooltip text.
    */
    Text[]
    {
        get {
            local Buffer := BufferAlloc(5120)  ; Character buffer (up to 2560 characters).
            NumPut("UPtr", Buffer.Ptr, this.TTTOOLINFO, 24+3*A_PtrSize)
           ,DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x438, "Ptr", Buffer.Size//2, "Ptr", this.TTTOOLINFO, "Ptr")
            return StrGet(Buffer)
        } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-gettext
        set {
            NumPut("UPtr", &Value, this.TTTOOLINFO, 24+3*A_PtrSize)
           ,DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x439, "Ptr", 0, "Ptr", this.TTTOOLINFO, "Ptr")
        } ; https://docs.microsoft.com/es-es/windows/win32/controls/ttm-updatetiptext
    }

    /*
        Determines the visibility state of this tooltip.
        Returns TRUE if the control is visible, or FALSE otherwise.
    */
    Visible() => DllCall("User32.dll\IsWindowVisible", "Ptr", this)
    ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iswindowvisible
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
CreateTooltip(Title := "", Icon := 0)
{
    local Tooltip := ITooltip.New()
    Tooltip.SetTitle(Title, Icon)
    return Tooltip
}

TooltipFromHwnd(Hwnd)
{
    return ITooltip.Instance[IsObject(Hwnd)?Hwnd.hWnd:Hwnd]
}
