/*
    Thanks to:
        just me - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2598.
*/
class ToolTip    ; WIN_V+
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Type         := "ToolTip"           ; The type of the control.
    static Instance     := { }                 ; Instances of this window {hwnd:obj}.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    hWnd           := 0                     ; The control handle.
    TOOLINFO       := ""                    ; The TOOLINFO structure contains information about a tool in a tooltip control.
    pTOOLINFO      := 0                     ; A pointer to the TOOLINFO structure.
    Timer          := 0                     ; Tooltip timer.
    
    
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Creates a tooltip control.
        https://docs.microsoft.com/es-es/windows/desktop/Controls/tooltip-control-reference
    */
    __New()
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632680(v=vs.85).aspx
        This.hWnd := DllCall("User32.dll\CreateWindowExW", "UInt", 0x00000008          ; dwExStyle         WS_EX_TOPMOST.
                                                         , "Str" , "tooltips_class32"  ; lpClassName       https://msdn.microsoft.com/en-us/library/windows/desktop/bb760250(v=vs.85).aspx.
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
        ToolTip.Instance[this.hWnd] := this

        ; https://docs.microsoft.com/en-us/windows/desktop/api/commctrl/ns-commctrl-tagtoolinfoa
        local size := A_PtrSize == 4 ? 48 : 72
        this.SetCapacity("TOOLINFO", size)
        this.pTOOLINFO := this.GetAddress("TOOLINFO")

        NumPut(size         , this.pTOOLINFO               , "UInt")  ; cbSize        Size of this structure, in bytes.
        NumPut(0x1|0x20|0x80, this.pTOOLINFO+4             , "UInt")  ; uFlags        TTDT_RESHOW | TTF_TRACK | TTF_ABSOLUTE.
        NumPut(This.hWnd    , this.pTOOLINFO+8             , "UPtr")  ; hwnd          Handle to the window that contains the tool.
        NumPut(This.hWnd    , this.pTOOLINFO+8+A_PtrSize   , "UPtr")  ; uId           Application-defined identifier of the tool.
        NumPut(&A_Space     , this.pTOOLINFO+24+3*A_PtrSize, "UPtr")  ; lpszText      Pointer to the buffer that contains the text for the tool.

        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-addtool
        SendMessage(0x432,, this.pTOOLINFO, this)  ; Registers a tool with a tooltip control.
        
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760408(v=vs.85).aspx
        SendMessage(0x418,, 0, this)  ; Sets the maximum width for a tooltip window (0 to allow any width).

        this.Timer := ObjBindMethod(this, "Show", "")
    }
    
    
    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Destroy()
    {
        SetTimer(this.Timer, "Delete")
        this.Timer := ""

        ToolTip.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", This.hWnd, "Int")

        local hFont := DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x31, "Ptr", 0, "Ptr", 0, "Ptr")
        if ( hFont )
            DllCall("Gdi32.dll\DeleteObject", "Ptr", hFont, "Int")
    }

    /*
        Shows or hides this tooltip.
        Parameters:
            Text:
                The text for this tooltip. The text is only modified if necessary (to avoid flickering).
                If an empty string is specified, the tooltip will be hidden.
            X / Y:
               The coordinates where to show this tooltip.
               If you specify an empty string, the current coordinates of the cursor are used. The coordinates are affected by A_CoordModeMouse.
               When some coordinate is omitted, it is automatically adjusted on the screen, so that the ToolTip is always visible on it.
            Duration:
                See the 'SetTimer' method.
    */
    Show(ByRef Text, X := "", Y := "", Duration := 0)
    {
        local

        if ( Text == "" )
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-trackactivate
            return DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x411, "Int", FALSE, "Ptr", this.pTOOLINFO, "Ptr")

        if ( this.GetText() !== Text )
            this.SetText( Text )

        SetTimer(this.Timer, Duration?-abs(Duration):"Off")
       ,DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x411, "Int", TRUE, "Ptr", this.pTOOLINFO, "Ptr")

        if ( X == "" || Y == "" )
        {
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-getbubblesize
            size := DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x41E, "Ptr", 0, "Ptr", this.pTOOLINFO, "UInt")
           
           ,MouseGetPos(X2, Y2)
            if (X == "")
                W := size&0xFFFF, X := X2 + 10, X := X + W > (VW:=SysGet(78)) ? X - (X + W - VW) : X
            if (Y == "")
                H := (size>>16)&0xFFFF, Y := Y2 + 10, Y := Y + H > SysGet(79) ? Y - H - 10 : Y
        }

        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-trackposition
        DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x412, "Ptr", 0, "UInt", (X&0xFFFF)|((Y&0xFFFF)<<16), "Ptr")
    }

    /*
        Determines the visibility state of this tooltip.
    */
    IsVisible()
    {
        return DllCall("User32.dll\IsWindowVisible", "Ptr", This.hWnd, "Int")
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-iswindowvisible

    /*
        Forces the current tooltip to be redrawn.
    */
    Update()
    {
        DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x412, "Ptr", 0, "UInt", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-update

    /*
        Sets a timer for this tooltip.
        Parameters:
            Duration:
                The duration, in milliseconds, in which to automatically hide this tooltip.
                You must specify an integer greater than or equal to zero. A value of zero deactivates the timer.
    */
    SetTimer(Duration)
    {
        if ( Type(Duration) !== "Integer" || Duration < 0 )
            throw Exception("Class ToolTip method SetTimer invalid parameter #1.", -1)
        SetTimer(this.Timer, Duration?-Duration:"Off")
    }

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
        Gets the text of this tooltip.
    */
    GetText()
    {
        local Buffer := ""
        VarSetCapacity(Buffer, 10000)
       ,NumPut(&Buffer, this.pTOOLINFO+24+3*A_PtrSize, "Ptr")
       ,DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x438, "Ptr", 5000, "Ptr", this.pTOOLINFO, "Ptr")
       ,VarSetCapacity(Buffer, -1)
        return Buffer
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-gettext

    /*
        Sets the text of this tooltip.
        Parameters:
            Text:
                The text to be set.
    */
    SetText(ByRef Text)
    {
        NumPut(&Text, this.pTOOLINFO+24+3*A_PtrSize, "Ptr")
       ,DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x439, "Ptr", 0, "Ptr", this.pTOOLINFO, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/ttm-updatetiptext

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
