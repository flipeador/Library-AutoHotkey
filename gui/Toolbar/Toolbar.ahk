/*
    Remarks:
        Item indexes are zero based.
        Items can be identified by their index or their command identifier.
        DllCall is used instead of SendMessage to improve performance.
    Toolbar Control Reference:
        https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-control-reference.
*/
class IToolbar  ; https://github.com/flipeador  |  https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=60315
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Type         := "Toolbar"          ; The type of the control.
    static ClassName    := "ToolbarWindow32"  ; The control class name.
    static Instance     := Map()              ; Instances of this control (hWnd:obj).


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Gui          := 0         ; The Gui object associated with this control.
    Ctrl         := 0         ; This Gui control class object.
    hWnd         := 0         ; The Handle of this control.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Adds a Toolbar control to the specified GUI window. The CreateToolbar function can be used to create the control.
        Parameters:
            Gui:
                The GUI window object. This object must be previously created by a call to the GuiCreate function.
            Options:
                Some specific options for this control. You can specify one or more of the following words.
                Menu          Creates a toolbar that simulates Windows menu.
                Flat          In a flat toolbar, both the toolbar and the buttons are transparent and hot-tracking is enabled. Button text appears under button bitmaps. The separators are shown as bars.
                List          Creates a flat toolbar with button text to the right of the bitmap.
                ToolTips      Creates a tooltip control that an application can use to display descriptive text for the buttons in the toolbar.
                Trans         Creates a transparent toolbar. In a transparent toolbar, the toolbar is transparent but the buttons are not. Button text appears under button bitmaps.
                Wrapable      Creates a toolbar that can have multiple lines of buttons. Toolbar buttons can "wrap" to the next line when the toolbar becomes too narrow to include all buttons on the same line. When the toolbar is wrapped, the break will occur on either the rightmost separator or the rightmost button if there are no separators on the bar. This style must be set to display a vertical toolbar control when the toolbar is part of a vertical rebar control. This style cannot be combined with CCS_VERT.
                Vertical      Causes the control to be displayed vertically.
                Adjustable    Enables a toolbar's built-in customization features, which let the user to drag a button to a new position or to remove a button by dragging it off the toolbar. In addition, the user can double-click the toolbar to display the Customize Toolbar dialog box, which enables the user to add, delete, and rearrange toolbar buttons.
                AltDrag       Allows users to change a toolbar button's position by dragging it while holding down the ALT key. If this style is not specified, the user must hold down the SHIFT key while dragging a button. Note that the CCS_ADJUSTABLE style must be specified to enable toolbar buttons to be dragged.
        Remakrs:
            To use the tooltips, add the "ToolTips" and "List" options to the control. You must also set the extended style TBSTYLE_EX_MIXEDBUTTONS using the SetExStyle method.
            An existing Toolbar control object can be retrieved by means of its handle using the ToolbarFromHwnd function.
    */
    __New(Gui, Options)
    {
        if (Type(this.Gui:=Gui) !== "Gui")
            throw Exception("IToolbar.New() - Invalid parameter #1.", -1)

        ; Toolbar Control Styles (https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-control-and-button-styles).
        ;               WS_CHILD  | WS_CLIPCHILDREN | CCS_NOPARENTALIGN | CCS_NODIVIDER | CCS_NORESIZE
        local style := 0x40000000 |    0x02000000   |     0x00000008    |   0x00000040  |  0x00000004
        style |= (Options ~= "i)\bMenu\b"         ? 0x800|0x1000|0x04000000 : 0)
               | (Options ~= "i)\bAltDrag\b"      ? 0x00400                 : 0)    ; TBSTYLE_ALTDRAG.
               | (Options ~= "i)\bFlat\b"         ? 0x00800                 : 0)    ; TBSTYLE_FLAT.
               | (Options ~= "i)\bList\b"         ? 0x01000                 : 0)    ; TBSTYLE_LIST.
               | (Options ~= "i)\bToolTips\b"     ? 0x00100                 : 0)    ; TBSTYLE_TOOLTIPS.
               | (Options ~= "i)\bTrans\b"        ? 0x08000                 : 0)    ; TBSTYLE_TRANSPARENT.
               | (Options ~= "i)\bWrapable\b"     ? 0x00200                 : 0)    ; TBSTYLE_WRAPABLE.
               | (Options ~= "i)\bVertical\b"     ? 0x00080                 : 0)    ; CCS_VERT.
               | (Options ~= "i)\bAdjustable\b"   ? 0x00020                 : 0)    ; CCS_ADJUSTABLE.

        Options   := RegExReplace(Options, "i)\b(menu|altdrag|flat|list|tooltips|trans|wrapable|vertical|adjustable)\b")
        this.Ctrl := this.Gui.AddCustom("+" . style . A_Space . Options . " Class" . IToolbar.ClassName)
        IToolbar.Instance[this.Ptr:=this.hWnd:=this.Ctrl.hWnd] := this

        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-buttonstructsize.
        SendMessage(0x41E, 8+3*A_PtrSize,, this)  ; Specifies the size of the TBBUTTON structure.

        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setunicodeformat.
        SendMessage(0x2005, TRUE,, this)  ; Sets the Unicode character format flag for the control.
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
        IToolbar.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this)
    }

    /*
        Inserts a new button in this toolbar.
        Parameters:
            Item:
                The zero-based index of a button.
                The method inserts the new button to the left of this button.
                A value of -1 inserts the button at the end.
            CommandID:
                A command identifier that will be associated with the button.
                This identifier is used in a WM_COMMAND message when the button is clicked.
                This identifier can be used with some methods to identify a button.
                This identifier is optional and not necessarily unique.
            Text:
                A string with the text for the button. A backspace (`b) indicates a separator.
                This parameter can be zero or a pointer to a null-terminaed string.
            Image:
                The zero-based index of the button image.
                Set this member to -2 (I_IMAGENONE) to indicate that the button does not have an image. The button layout will not include any space for a bitmap, only text.
                If the button is a separator, «Image» determines the width of the separator, in pixels. The default width is 2.
            State:
                A combination of values indicating the state of the new Toolbar button.
                0x01 TBSTATE_CHECKED          Creates a dual-state push button that toggles between the pressed and nonpressed states each time the user clicks it. The button has a different background color when it is in the pressed state.
                0x02 TBSTATE_PRESSED          The button is being clicked.
                0x04 TBSTATE_ENABLED          The button accepts user input. A button that does not have this state is grayed.
                0x08 TBSTATE_HIDDEN           The button is not visible and cannot receive user input.
                0x10 TBSTATE_INDETERMIN       The button is grayed.
                0x20 TBSTATE_WRAP             The button is followed by a line break. The button must also have the TBSTATE_ENABLED state.
                0x40 TBSTATE_ELLIPSES         The button's text is cut off and an ellipsis is displayed.
                0x80 TBSTATE_MARKED           The button is marked. The interpretation of a marked item is dependent upon the application.
                Toolbar Button States: https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-button-states.
            Style:
                Button style. This member can be a combination of the following values. Not all styles can be combined.
                0x02    BTNS_CHECK            Creates a dual-state push button that toggles between the pressed and nonpressed states each time the user clicks it.
                0x06    BTNS_CHECKGROUP       Creates a button that stays pressed until another button in the group is pressed, similar to option buttons (also known as radio buttons).
                0x08    BTNS_DROPDOWN         Creates a drop-down style button that can display a list when the button is clicked.
                0x10    BTNS_AUTOSIZE         Specifies that the toolbar control should not assign the standard width to the button. Instead, the button's width will be calculated based on the width of the text plus the image of the button.
                0x20    BTNS_NOPREFIX         Specifies that the button text will not have an accelerator prefix associated with it.
                0x40    BTNS_SHOWTEXT         Specifies that button text should be displayed. All buttons can have text, but only those buttons with the BTNS_SHOWTEXT button style will display it. This button style must be used with the TBSTYLE_LIST style and the TBSTYLE_EX_MIXEDBUTTONS extended style. If you set text for buttons that do not have the BTNS_SHOWTEXT style, the toolbar control will automatically display it as a tooltip when the cursor hovers over the button. This feature allows your application to avoid handling the TBN_GETINFOTIP or TTN_GETDISPINFO notification code for the toolbar.
                0x80    BTNS_WHOLEDROPDOWN    Specifies that the button will have a drop-down arrow, but not as a separate section.
                Toolbar Control and Button Styles: https://docs.microsoft.com/es-es/windows/win32/controls/toolbar-control-and-button-styles.
            Data:
                Application-defined value associated with the Toolbar button.
                This value must be any integer number. By default it is zero.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    Add(Item := -1, CommandID := 0, Text := "`b", Image := -2, State := 4, Style := 0, Data := 0)
    {
        local TBBUTTON := BufferAlloc(8+3*A_PtrSize)  ; TBBUTTON structure (https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tbbutton).
        Style |= (Text == "`b"), NumPut("Ptr",Data,"Ptr",type(Text)=="Integer"?Text:&Text,,NumPut("Int"
        ,Style&1?abs(Image):Image,"Int",CommandID,"UCHar",State,"UCHar",Style,TBBUTTON)-2+A_PtrSize)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x443, "Ptr", Item, "Ptr", TBBUTTON, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-insertbutton

    /*
        Deletes the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button to delete.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    Delete(Index)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x416, "Ptr", Index, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-deletebutton

    /*
        Deletes all buttons from the toolbar.
    */
    DeleteAll()
    {
        this.SetRedraw(FALSE)
        while this.Delete(0)
            continue
        this.SetRedraw(TRUE)
    }

    /*
        Retrieves the display text of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose text is to be retrieved.
        Return value:
            Returns a string with the text that is currently displayed by the button.
            An empty string indicates one of the following cases:
                1) The display text of the button is an empty string.
                2) The button has no display text assigned to it (null pointer).
                3) The index of the specified button is invalid.
    */
    GetButtonText(Index)
    {
        local Buffer       := BufferAlloc(1024)                ; Character buffer (Up to 512 characters).
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UPtr", Buffer.Ptr, "Int", Buffer.Size//2, NumPut("UInt",TBBUTTONINFO.Size,"UInt",0x80000002,TBBUTTONINFO)+8+2*A_PtrSize)
       ,NumPut("UShort", 0x0000, Buffer)  ; Write a null character at the beginning, to return an empty string in case of error.
       ,DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43F, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr")
        return StrGet(Buffer)
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-getbuttoninfo

    /*
        Changes the display text of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose text is to be changed.
            Text:
                A string that contains the new text for the button.
                This parameter can be zero or a pointer to a null-terminated string.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetButtonText(Index, Text)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UPtr", type(Text)=="Integer"?Text:&Text,NumPut("UInt",TBBUTTONINFO.Size,"UInt",0x80000002,TBBUTTONINFO)+8+2*A_PtrSize)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x440, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-setbuttoninfo

    /*
        Retrieves the state of the specified button from the toolbar, such as whether it is enabled, pressed, or checked.
        Parameters:
            Index:
                The zero-based index of the button whose state is to be retrieved.
        Return value:
            Returns the button state information if successful, or -1 otherwise.
    */
    GetButtonState(Index)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UInt", TBBUTTONINFO.Size, "UInt", 0x80000004, TBBUTTONINFO)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43F, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr") !== -1
             ? NumGet(TBBUTTONINFO, 16, "UChar")  ; Ok.
             : -1                                 ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-getbuttoninfo

    /*
        Changes the state of the specified button form the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose state is to be changed.
            State:
                A combination of values listed in Toolbar Button States. See the Add method.
            Mode:
                Specifies the mode in which the state is to be set. By default it is replaced.
                -1      Toggles the specified state.
                 1      Adds the specified state.
                 2      Removes the specified state.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    SetButtonState(Index, State, Mode := 0)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        local s            := Mode ? this.GetButtonState(Index) : 0
        NumPut("UChar", Mode==-1?s&State?s&~State:s|State:Mode==1?s|State:Mode==2?s&~State:State
             , NumPut("UInt",TBBUTTONINFO.Size,"UInt",0x80000004,TBBUTTONINFO)+8)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x440, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-setbuttoninfo

    /*
        Retrieves the Style flags of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose style is to be retrieved.
        Return value:
            Returns the button style flags if successful, or -1 otherwise.
    */
    GetButtonStyle(Index)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UInt", TBBUTTONINFO.Size, "UInt", 0x80000008, TBBUTTONINFO)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43F, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr") !== -1
             ? NumGet(TBBUTTONINFO, 17, "UChar")  ; Ok.
             : -1                                 ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-getbuttoninfo

    /*
        Retrieves the application-defined value associated with the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose application-defined value is to be retrieved.
        Return value:
            Returns the application-defined value associated with the button (integer number).
            If the method fails, the return value is an empty string.
    */
    GetButtonData(Index)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UInt", TBBUTTONINFO.Size, "UInt", 0x80000010, TBBUTTONINFO)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43F, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr") !== -1
             ? NumGet(TBBUTTONINFO, 16+A_PtrSize, "UPtr")  ; Ok.
             : ""                                          ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-getbuttoninfo

    /*
        Changes the application-defined value associated with the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose application-defined value is to be changed.
            Data:
                Application-defined value associated with the button (integer number).
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetButtonData(Index, Data)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UPtr", Data, NumPut("UInt",TBBUTTONINFO.Size,"UInt",0x80000010,TBBUTTONINFO)+8+A_PtrSize)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x440, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-setbuttoninfo

    /*
        Retrieves the image index of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose image index is to be retrieved.
        Return value:
            Returns the image index of the button if successful, or an empty string otherwise.
            A value of -2 (I_IMAGENONE) indicates that the button does not have an image.
    */
    GetButtonImage(Index)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UInt", TBBUTTONINFO.Size, "UInt", 0x80000001, TBBUTTONINFO)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43F, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr") !== -1
             ? NumGet(TBBUTTONINFO, 12, "Int")  ; OK.
             : ""                               ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-getbuttoninfo

    /*
        Changes the image index of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose image index is to be changed.
            Image:
                The new image index of the button.
                A value of -2 (I_IMAGENONE) indicates that the button does not have an image. The button layout will not include any space for a bitmap, only text.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetButtonImage(Index, Image)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("Int", Image, NumPut("UInt",TBBUTTONINFO.Size,"UInt",0x80000001,TBBUTTONINFO)+4)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x440, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-setbuttoninfo

    /*
        Moves a button from one index to another.
        Parameters:
            FromIndex:
                The zero-based index of the button to be moved.
            ToIndex:
                The zero-based index where the button will be moved.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    MoveButton(FromIndex, ToIndex)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x452, "Ptr", FromIndex, "Ptr", ToIndex, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-movebutton

    /*
        Retrieves the command identifier of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose command identifier is to be retrieved.
        Return value:
            If the method succeeds, the return value is the command identifier associated with the button.
            If the method fails, the return value is an empty string.
    */
    GetCommandID(Index)
    {
        local TBBUTTONINFO := BufferAlloc(A_PtrSize==4?32:48)  ; TBBUTTONINFOW structure.
        NumPut("UInt", TBBUTTONINFO.Size, "UInt", 0x80000020, TBBUTTONINFO)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43F, "Ptr", Index, "Ptr", TBBUTTONINFO, "Ptr") !== -1
             ? NumGet(TBBUTTONINFO, 8, "Int")  ; Ok.
             : 0                               ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-getbuttoninfo

    /*
        Changes the command identifier of the specified button from the toolbar.
        Parameters:
            Index:
                The zero-based index of the button whose command identifier is to be changed.
            CommandID:
                The new command identifier for this button.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    SetCommandID(Index, CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x42A, "Ptr", Index, "Ptr", CommandID, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-setcmdid

    /*
        Retrieves the zero-based index for the button associated with the specified command identifier.
        Parameters:
            CommandID:
                Command identifier associated with the button.
        Return value:
            Returns the zero-based index for the button or -1 if the specified command identifier is invalid.
    */
    CommandToIndex(CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x419, "Ptr", CommandID, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-commandtoindex

    /*
        Sets the minimum and maximum button widths in the toolbar control.
        Parameters:
            Min:
                Specifies the minimum button width, in pixels. Toolbar buttons will never be narrower than this value.
            Max:
                Specifies the maximum button width, in pixels. If button text is too wide, the control displays it with ellipsis points.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetButtonWidth(Min, Max)
    {
        return SendMessage(0x43B,, (Min&0xFFFF)|((Max&0xFFFF)<<16), this)
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-setbuttonwidth

    /*
        Retrieves the bounding rectangle of a button in the toolbar.
        Parameters:
            Index:
                The zero-based index of the button for which to retrieve information.
        Return value:
            If the method succeeds, the return value is an object with the properties L(eft), T(op), R(ight) and B(ottom).
            If the method fails, the return value is zero.
        Remarks:
            This method does not retrieve the bounding rectangle for buttons whose state is set to the TBSTATE_HIDDEN value.
    */
    GetItemRect(Index)
    {
        local RECT := BufferAlloc(16)  ; RECT structure (https://docs.microsoft.com/en-us/previous-versions/dd162897(v=vs.85)).
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x41D, "Ptr", Index, "Ptr", RECT, "Ptr")
             ? {L:NumGet(RECT,"Int") , T:NumGet(RECT,4,"Int") , R:NumGet(RECT,8,"Int") , B:NumGet(RECT,12,"Int")}  ; OK.
             : 0                                                                                                   ; ERROR.
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getitemrect

    /*
        Retrieves the current width and height of toolbar buttons, in pixels.
        Return value:
            The return value is an object with the properties W(idth) and H(eight).
    */
    GetButtonSize()
    {
        local size := DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43A, "Ptr", 0, "Ptr", 0, "Ptr")
        return { W:size&0xFFFF , H:(size>>16)&0xFFFF }
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getbuttonsize

    /*
        Sets the size of buttons on the toolbar.
        Parameters:
            Width:
                Specifies the width, in pixels, of the buttons.
            Height:
                Specifies the height, in pixels, of the buttons.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetButtonSize(Width, Height)
    {
        return SendMessage(0x41F,, (Width&0xFFFF)|((Height&0xFFFF)<<16), this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setbuttonsize

    /*
        Sets the distance between the toolbar buttons on this toolbar.
        Parameters:
            Value:
                The gap, in pixels, between buttons on the toolbar.
        Remarks:
            Receipt of this message triggers a repaint of the toolbar, if the toolbar is currently visible.
    */
    SetListGap(Value)
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x460, "Ptr", Value, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setlistgap

    /*
        Sets the indentation for the first button in a toolbar control.
        Parameters:
            Value:
                Value specifying the indentation, in pixels.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetIndent(Value)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x42F, "Ptr", Value, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setindent

    /*
        Sets the padding for a toolbar control.
        Parameters:
            Horizontal / vertical:
                Specifies the horizontal and the vertical padding, in pixels.
        Return value:
            Returns an object with the properties H(orizontal) and V(ertical) that contains the previous horizontal and vertical pading, in pixels.
    */
    SetPadding(Horizontal, Vertical)
    {
        local r := SendMessage(0x457,, (Horizontal&0xFFFF)|((Vertical&0xFFFF)<<16), this)
        return { H:r&0xFFFF , V:(r>>16)&0xFFFF }
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setpadding

    /*
        Determines where a point lies in the toolbar control.
        Parameters:
            X / Y:
                The X and Y coordinates of the hit test, respectively.
        Return value:
            If the return value is zero or a positive value, it is the zero-based index of the nonseparator item in which the point lies.
            If the return value is negative, the point does not lie within a button.
            The absolute value of the return value is the index of a separator item or the nearest nonseparator item.
    */
    HitTest(X, Y)
    {
        local POINT := (X & 0xFFFFFFFF) | ((Y & 0xFFFFFFFF) << 32)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x445, "Ptr", 0, "Ptr", POINT, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/tb-hittest

    /*
        Determines whether the specified button in the toolbar is checked.
        Parameters:
            CommandID:
                Command identifier of the button.
        Return value:
            Returns nonzero if the button is checked, or zero otherwise.
    */
    IsButtonChecked(CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40A, "Ptr", CommandID, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonchecked

    /*
        Checks or unchecks a given button in the toolbar.
        Parameters:
            CommandID:
                Command identifier of the button to check.
            Value:
                Indicates whether to check or uncheck the specified button.
                 0          The check is removed.
                 1          The check is added.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
        Remarks:
            When a button is checked, it is displayed in the pressed state.
    */
    CheckButton(CommandID, Value)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x402, "Ptr", CommandID, "Ptr", Value, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-checkbutton

    /*
        Determines whether the specified button in the toolbar is enabled.
        Parameters:
            CommandID:
                Command identifier of the button.
        Return value:
            Returns nonzero if the button is enabled, or zero otherwise.
    */
    IsButtonEnabled(CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x409, "Ptr", CommandID, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonenabled

    /*
        Enables or disables the specified button in the toolbar.
        Parameters:
            CommandID:
                Command identifier of the button to enable or disable.
            Value:
                Indicates whether to enable or disable the specified button.
                0           The button is disabled.
                1           The button is enabled.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
        Remarks:
            When a button has been enabled, it can be pressed and checked.
    */
    EnableButton(CommandID, Value)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x401, "Ptr", CommandID, "Ptr", Value, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-enablebutton

    /*
        Determines whether the specified button in the toolbar is visible.
        Parameters:
            CommandID:
                Command identifier of the button.
        Return value:
            Returns nonzero if the button is visible, or zero otherwise.
    */
    IsButtonVisible(CommandID)
    {
        return !DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40C, "Ptr", CommandID, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonhidden

    /*
        Hides or shows the specified button in the toolbar.
        Parameters:
            CommandID:
                Command identifier of the button to hide or show.
            Value:
                Indicates whether to hide or show the specified button.
                0           The button is hidden.
                1           The button is shown.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    ShowButton(CommandID, Value)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x404, "Ptr", CommandID, "Ptr", !Value, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-hidebutton

    /*
        Checks the highlight state of the toolbar button.
        Parameters:
            CommandID:
                Command identifier for a toolbar button.
        Return value:
            Returns nonzero if the button is highlighted, or zero otherwise.
    */
    IsButtonHighlighted(CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40E, "Ptr", CommandID, "Ptr", 0, "Ptr")
    }

    /*
        Sets the highlight state of a given button in the toolbar control.
        Parameters:
            CommandID:
                Command identifier for the a button.
            Value:
                Indicates the new highlight state.
                0           The button is set to its default state.
                1           The button is highlighted.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    HighlightButton(CommandID, Value)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x406, "Ptr", CommandID, "Ptr", Value, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-markbutton

    /*
        Determines whether the specified button in the toolbar is indeterminate.
        Parameters:
            CommandID:
                Command identifier of the button.
        Return value:
            Returns nonzero if the button is indeterminate, or zero otherwise.
    */
    IsButtonIndeterminate(CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40D, "Ptr", CommandID, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonindeterminate

    /*
        Determines whether the specified button in the toolbar is pressed.
        Parameters:
            CommandID:
                Command identifier of the button.
        Return value:
            Returns nonzero if the button is pressed, or zero otherwise.
    */
    IsButtonPressed(CommandID)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40B, "Ptr", CommandID, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonpressed

    /*
        Presses or releases the specified button in a toolbar.
        Parameters:
            CommandID:
                Command identifier of the button to press or release.
            Value:
                Indicates whether to press or release the specified button.
                0           The button is released.
                1           The button is pressed.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    PressButton(CommandID, Value)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x403, "Ptr", CommandID, "Ptr", Value, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-pressbutton

    /*
        Causes the toolbar to be resized.
        Remarks:
            An application sends the TB_AUTOSIZE message after causing the size of a toolbar to change either by setting the button or bitmap size or by adding strings for the first time.
    */
    AutoSize()
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x421, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-autosize

    /*
        Displays the Customize Toolbar dialog box.
        Remarks:
            The toolbar must handle the TBN_QUERYINSERT and TBN_QUERYDELETE notifications for the Customize Toolbar dialog box to appear.
            If the toolbar does not handle those notifications, TB_CUSTOMIZE has no effect.
        Note:
            See the OnEvent method. You must handle all messages by yourself.
    */
    Customize()
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x41B, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-customize

    /*
        Gets the ideal size of the toolbar.
        Parameters:
            Value:
                Indicates whether to retrieve the ideal height or width of the toolbar.
                0           Retrieve the ideal width.
                1           Retrieve the ideal height.
                2           Retrieve the height if the Toolbar control is vertical, otherwise retrieve the width.
        Return value:
            Receives the height or width at which all buttons would be displayed.
            If an error occurs, the return value is -1.
        Remarks:
            The rectangle dimensions may correspond to viewport extents, window extents, text extents, bitmap dimensions, or the aspect-ratio filter for some extended functions.
    */
    GetIdealSize(Value := 2)
    {
        Value := Value == 2 ? this.GetStyle() & 0x00080 ? 1 : 0 : Value
        local SIZE := BufferAlloc(8)  ; SIZE structure.
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x463, "Ptr", Value, "Ptr", SIZE, "Ptr")
            ? Value ? NumGet(SIZE,4,"Int") : NumGet(SIZE,"Int")  ; OK.
            : -1                                                 ; ERROR.
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getidealsize

    /*
        Retrieves the total size of all of the visible buttons and separators in the toolbar.
        Return value:
            If the method succeeds, the return value is an object with the properties W(idth) and H(eight).
            If the method fails, the return value is zero.
    */
    GetMaxSize()
    {
        local SIZE := BufferAlloc(8)  ; SIZE structure (https://docs.microsoft.com/en-us/previous-versions/dd145106(v=vs.85)).
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x453, "Ptr", 0, "Ptr", SIZE, "Ptr")
             ? { W:NumGet(SIZE,"Int") , H:NumGet(SIZE,4,"Int") }  ; OK.
             : 0                                                  ; FALSE.
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getmaxsize

    /*
        Gets the number of image lists associated with the toolbar.
        Return value:
            Returns the number of image lists.
    */
    GetImageListCount()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x462, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getimagelistcount

    /*
        Gets the image list that the toolbar control uses to display buttons in their default state.
        A toolbar control uses this image list to display buttons when they are not hot or disabled.
        Return value:
            Returns the handle to the image list, or zero if no image list is set.
    */
    GetImageList()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x431, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getimagelist

    /*
        Sets the image list that the toolbar uses to display buttons that are in their default state.
        Parameters:
            ImageList:
                Handle to the image list to set. If this parameter is zero, no images are displayed in the buttons.
            Index:
                The index of the list. If you use only one image list, set 'Index' to zero. See Remarks for details on using multiple image lists.
        Return value:
            Returns the handle to the image list previously used to display buttons in their default state, or zero if no image list was previously set.
        Remarks:
            Your application is responsible for freeing the image list after the toolbar is destroyed.
            Read more: https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setimagelist.
    */
    SetImageList(ImageList, Index := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x430, "Ptr", Index, "Ptr", ImageList, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setimagelist

    /*
        Gets the image list that the toolbar control uses to display buttons in a pressed state.
    */
    GetPressedImageList()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x469, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getpressedimagelist

    /*
        Sets the image list that the toolbar uses to display buttons that are in a pressed state.
    */
    SetPressedImageList(ImageList, Index := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x468, "Ptr", Index, "Ptr", ImageList, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setpressedimagelist

    /*
        Gets the image list that the toolbar control uses to display hot buttons.
    */
    GetHotImageList()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x435, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-gethotimagelist

    /*
        Sets the image list that the toolbar control will use to display hot buttons.
    */
    SetHotImageList(ImageList, Index := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x434, "Ptr", Index, "Ptr", ImageList, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-sethotimagelist

    /*
        Gets the image list that the toolbar control uses to display inactive buttons.
    */
    GetDisabledImageList()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x437, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getdisabledimagelist

    /*
        Sets the image list that the toolbar control will use to display disabled buttons.
    */
    SetDisabledImageList(ImageList, Index := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x436, "Ptr", Index, "Ptr", ImageList, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setdisabledimagelist

    /*
        Loads system-defined button images into the toolbar control's image list.
        Parameters:
            Value:
                Identifier of a system-defined button image list. This parameter can be set to one of the following values.
                 0  IDB_STD_SMALL_COLOR               Standard bitmaps in small size.
                 1  IDB_STD_LARGE_COLOR               Standard bitmaps in large size.
                 4  IDB_VIEW_SMALL_COLOR              View bitmaps in small size.
                 5  IDB_VIEW_LARGE_COLOR              View bitmaps in large size.
                 8  IDB_HIST_SMALL_COLOR              Windows Explorer bitmaps in small size.
                 9  IDB_HIST_LARGE_COLOR              Windows Explorer bitmaps in large size.
                12  IDB_HIST_NORMAL                   Windows Explorer travel buttons and favorites bitmaps in normal state.
                13  IDB_HIST_HOT                      Windows Explorer travel buttons and favorites bitmaps in hot state.
                14  IDB_HIST_DISABLED                 Windows Explorer travel buttons and favorites bitmaps in disabled state.
                15  IDB_HIST_PRESSED                  Windows Explorer travel buttons and favorites bitmaps in pressed state.
        Return value:
            The count of images in the image list. Returns zero if the toolbar has no image list or if the existing image list is empty.
        Remarks:
            For a list of image index values for these preset bitmaps, see Toolbar Standard Button Image Index Values.
            If there is no assigned image list, the system creates one and assigns it to the control.
        Toolbar Standard Button Image Index Values:
            https://docs.microsoft.com/es-es/windows/desktop/Controls/toolbar-standard-button-image-index-values.
    */
    LoadImages(Value)
    {
        return SendMessage(0x432, Value, -1, this)  ; -1 = HINST_COMMCTRL.
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-loadimages

    /*
        Retrieves the styles currently in use for the toolbar control.
        Return value:
            Returns a value that is a combination of toolbar control styles.
        Toolbar Control Styles:
            https://docs.microsoft.com/es-es/windows/desktop/Controls/toolbar-control-and-button-styles.
    */
    GetStyle()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x439, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getstyle

    /*
        Sets the style for the toolbar control.
        Parameters:
            Style:
                Value specifying the styles to be set for the control. This value can be a combination of toolbar control styles.
            Mode:
                Sets the mode in which the style is to be set. By default it is replaced.
                -1      Toggles the specified style.
                 1      Adds the specified style.
                 2      Removes the specified style.
        Return value:
            Returns a value that represents the previous styles. This value can be a combination of styles.
    */
    SetStyle(Style, Mode := 0)
    {
        local cstyle := this.GetStyle()
        Style := Mode == 1 ? cstyle|Style : Mode == 2 ? cstyle&~Style : Mode == -1 ? cstyle&Style?cstyle&~Style:cstyle|Style : Style
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x438, "Ptr", 0, "Ptr", Style, "Ptr")
        return cstyle
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setstyle

    /*
        Retrieves the extended styles for a toolbar control.
        Return value:
            Returns a value that represents the styles currently in use for the toolbar control. This value can be a combination of extended styles.
        Toolbar Control Extended Styles:
            https://docs.microsoft.com/es-es/windows/desktop/Controls/toolbar-extended-styles.
    */
    GetExStyle()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x455, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getextendedstyle

    /*
        Sets the extended styles for a toolbar control.
        Parameters:
            ExStyle:
                Value specifying the new extended styles. This parameter can be a combination of extended styles.
                0x01  TBSTYLE_EX_DRAWDDARROWS         Allows buttons to have a separate dropdown arrow. Buttons that have the BTNS_DROPDOWN style will be drawn with a dropdown arrow in a separate section, to the right of the button.
                                                      If the arrow is clicked, only the arrow portion of the button will depress, and the toolbar control will send a TBN_DROPDOWN notification code to prompt the application to display the dropdown menu.
                                                      If the main part of the button is clicked, the toolbar control sends a WM_COMMAND message with the button's ID. The application normally responds by launching the first command on the menu.
                0x08  TBSTYLE_EX_MIXEDBUTTONS         Allows you to set text for all buttons, but only display it for those buttons with the BTNS_SHOWTEXT button style.
                                                      With this extended style, text that is set but not displayed on a button will automatically be used as the button's tooltip text.
                                                      Your application only needs to handle TBN_GETINFOTIP or or TTN_GETDISPINFO if it needs more flexibility in specifying the tooltip text.
                                                      The TBSTYLE_LIST style must also be set (Specify 'List' in the options when creating the control).
                0x10  TBSTYLE_EX_HIDECLIPPEDBUTTONS   This style hides partially clipped buttons. The most common use of this style is for toolbars that are part of a rebar control.
                                                      If an adjacent band covers part of a button, the button will not be displayed.
                                                      However, if the rebar band has the RBBS_USECHEVRON style, the button will be displayed on the chevron's dropdown menu.
                0x80  TBSTYLE_EX_DOUBLEBUFFER         This style requires the toolbar to be double buffered. Double buffering is a mechanism that detects when the toolbar has changed.
            Mode:
                See the SetStyle method.
        Return value:
            Returns a value that represents the previous extended styles. This value can be a combination of extended styles.
    */
    SetExStyle(ExStyle, Mode := 0)
    {
        local cstyle := this.GetExStyle()
        ExStyle := Mode == 1 ? cstyle|ExStyle : Mode == 2 ? cstyle&~ExStyle : Mode == -1 ? cstyle&ExStyle?cstyle&~ExStyle:cstyle|ExStyle : ExStyle
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x454, "Ptr", 0, "Ptr", ExStyle, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setextendedstyle

    /*
        Retrieves the current insertion mark for the toolbar.
        Return value:
            Returns an object with the properties 'Index' and 'Flags'.
            See the SetInsertMark method for the description of these properties.
    */
    GetInsertMark()
    {
        local TBINSERTMARK := BufferAlloc(8)  ; TBINSERTMARK structure (https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tbinsertmark).
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x44F, "Ptr", 0, "Ptr", TBINSERTMARK, "Ptr")
        return { Index:NumGet(TBINSERTMARK,"Int") , Flags:NumGet(TBINSERTMARK,4,"Int") }
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getinsertmark

    /*
        Sets the current insertion mark for the toolbar.
        Parameters:
            Index:
                The zero-based index of the insertion mark. If this parameter is -1, there is no insertion mark.
            Flags:
                Defines where the insertion mark is in relation to 'Index'. This can be one of the following values:
                0           The insertion mark is to the left of the specified button. This is the default value.
                1           The insertion mark is to the right of the specified button.
    */
    SetInsertMark(Index, Flags := 0)
    {
        local TBINSERTMARK := BufferAlloc(8)  ; TBINSERTMARK structure (https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tbinsertmark).
        NumPut("Int", Index, "UInt", Flags, TBINSERTMARK)
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x450, "Ptr", 0, "Ptr", TBINSERTMARK, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setinsertmark

    /*
        Retrieves the color used to draw the insertion mark for the toolbar.
        Return value:
            Returns a RGB color value that contains the current insertion mark color.
    */
    GetInsertMarkColor()
    {
        local Color := DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x459, "Ptr", 0, "Ptr", 0, "UPtr")  ; BGR Color.
        return ((Color & 0xFF0000) >> 16) + (Color & 0x00FF00) + ((Color & 0x0000FF) << 16)                        ; RGB Color.
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getinsertmarkcolor

    /*
        Sets the color used to draw the insertion mark for the toolbar.
        Parameters:
            Color:
                A RGB color value that contains the new insertion mark color.
        Return value:
            Returns a RGB color value that contains the previous insertion mark color.
    */
    SetInsertMarkColor(Color)
    {
        Color := SendMessage(0x458,, ((Color&0xFF0000)>>16)+(Color&0xFF00)+((Color&0xFF)<<16), this)
        DllCall("User32.dll\InvalidateRect", "Ptr", this, "Ptr", 0, "Int", TRUE, "Int")
        return ((Color & 0xFF0000) >> 16) + (Color & 0x00FF00) + ((Color & 0x0000FF) << 16)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setinsertmarkcolor

    /*
        Retrieves a pointer to the IDropTarget interface for the toolbar control.
        Return value:
            Returns a pointer to the interface. If an error occurs, the return value is zero.
        Remarks:
            The toolbar's IDropTarget is used by the toolbar when objects are dragged over or dropped onto it.
            You must call the ObjRelease function to free the memory used by this interface.
        IDropTarget interface:
            https://docs.microsoft.com/es-es/windows/desktop/api/oleidl/nn-oleidl-idroptarget.
    */
    GetObject()
    {
        local IDropTarget := 0, CLSID := BufferAlloc(16)
        DllCall("Ole32.dll\CLSIDFromString", "Str", "{00000122-0000-0000-C000-000000000046}", "Ptr", CLSID)
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43E, "Ptr", CLSID, "UPtrP", IDropTarget, "Ptr")
        return IDropTarget
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getobject

    /*
        Finds the zero-based index of the first item whose display text matches the specified string.
        Parameters:
            Text:
                A string containing the text that will be searched.
            Min / Max:
                The search range (inclusive).
            Mode:
                Determines the behavior of the search. You can specify one or more of the following flags.
                0 = Finds the item whose text exactly matches the specified string.
                1 = Finds the item whose text begins with the specified string.
                2 = Finds the item whose text coincides partially with the specified string.
                4 = Specifies a case-sensitive search.
        Return value:
            Returns the zero-based index of the matching item. -1 if the search has not been successful.
    */
    FindText(Text, Min := 0, Max := -1, Mode := 0)
    {
        local Str, Count := this.Count, Index := 0 * ( Max:=Max<0||Max>Count?Count:Max ) - 1
        while ( ( ++Index < Count ) && ( Index < Max ) )
            if ( Index >= Min ) {
                Str := Mode&1&&!(Mode&2)?SubStr(this.GetButtonText(Index),1,StrLen(Text)):this.GetButtonText(Index)
                if ( Mode&2?InStr(Str,Text,Mode&4):Mode&4?Str==Text:Str=Text )
                    return Index  ; OK.
        } return -1  ; ERROR.
    }

    /*
        Allow or prevent changes in the control to be redrawn.
        Parameters:
            Mode:
                The redraw state.
                0 (FALSE)       The content cannot be redrawn after a change.
                1 (TRUE)        The content can be redrawn after a change.
    */
    SetRedraw(Mode)
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0xB, "Ptr", !!Mode, "Ptr", 0, "Ptr")
        if (Mode)
            DllCall("User32.dll\InvalidateRect", "Ptr", this, "Ptr", 0, "Int", TRUE)
           ,DllCall("User32.dll\UpdateWindow", "Ptr", this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/gdi/wm-setredraw

    /*
        Retrieves the index of the hot item in the toolbar.
        Return value:
            Returns the index of the hot item, or -1 if no hot item is set.
        Remarks:
            Toolbar controls that do not have the TBSTYLE_FLAT style do not have hot items.
    */
    GetHotItem()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x447, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-gethotitem

    /*
        Sets the hot item in a toolbar.
        Parameters:
            Index:
                The zero-based index of the item that will be made hot. If this value is -1, none of the items will be hot.
            Flags:
                Flags that indicate why the hot item has changed. This can be one or more of the following values:
                0x000 HICF_OTHER                  The change in the hot item resulted from an event that could not be determined. This will most often be due to a change in focus or the TB_SETHOTITEM message.
                0x001 HICF_MOUSE                  The change in the hot item resulted from a mouse event.
                0x002 HICF_ARROWKEYS              The change in the hot item was caused by an arrow key.
                0x004 HICF_ACCELERATOR            The change in the hot item was caused by a shortcut key.
                0x008 HICF_DUPACCEL               Modifies HICF_ACCELERATOR. If this flag is set, more than one item has the same shortcut key character.
                0x010 HICF_ENTERING               Modifies the other reason flags. If this flag is set, there is no previous hot item and idOld does not contain valid information.
                0x020 HICF_LEAVING                Modifies the other reason flags. If this flag is set, there is no new hot item and idNew does not contain valid information.
                0x040 HICF_RESELECT               The change in the hot item resulted from the user entering the shortcut key for an item that was already hot.
                0x080 HICF_LMOUSE                 The change in the hot item resulted from a left-click mouse event.
                0x100 HICF_TOGGLEDROPDOWN         Causes the button to switch states.
                Read more: https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/ns-commctrl-tagnmtbhotitem.
        Return value:
            Returns the index of the previous hot item, or -1 if there was no hot item.
        Remarks:
            The behavior of this message is not defined for toolbars that do not have the TBSTYLE_FLAT style.
    */
    SetHotItem(Index, Flags := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x45E, "Ptr", Index, "Ptr", Flags, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-sethotitem2

    /*
        Registers a function or method to be called when the given event is raised by this control.
        Note:
            In order not to complicate things, I have decided not to handle any message automatically.
            This method just calls "this.Ctrl.OnNotify". See the reference link below.
        Toolbar Control Notifications:
            https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-toolbar-control-reference-notifications.
    */
    OnEvent(EventName, Callback, AddRemove := 1)
    {
        ; Most common messages:
        ;   NM_CLICK = -2. NM_DBLCLK = -3. NM_RCLICK = -5. NM_RDBLCLK = -6. NM_SETFOCUS = -7. NM_KILLFOCUS = -8.
        ;   NM_KEYDOWN = -15. TBN_BEGINADJUST = -703. TBN_ENDADJUST = -704. TBN_GETBUTTONINFO = -700.
        ;   TBN_QUERYINSERT = -706. TBN_QUERYDELETE = -707. TBN_TOOLBARCHANGE = -708.
        this.Ctrl.OnNotify(EventName, Callback, AddRemove)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-toolbar-control-reference-notifications


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Retrieves the number of buttons currently in the Toolbar control.
    */
    Count[]
    {
        get => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x418, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-buttoncount

    /*
        Retrieves the number of rows of buttons in the toolbar with the TBSTYLE_WRAPABLE style.
    */
    Rows[]
    {
        get => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x428, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getrows

    /*
        Retrieves the maximum number of text rows that can be displayed on a toolbar button.
        -----------------------------------------------------------------------
        Sets the maximum number of text rows displayed on a toolbar button.
        Parameters:
            Value:
                Maximum number of rows of text that can be displayed.
        Remarks:
            To cause text to wrap, you must set the maximum button width by sending a TB_SETBUTTONWIDTH message.
            The text wraps at a word break; line breaks ("\n") in the text are ignored. Text in TBSTYLE_LIST toolbars is always shown on a single line.
    */
    TextRows[]
    {
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-gettextrows
        get => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43D, "Ptr", 0, "Ptr", 0, "Ptr")
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setmaxtextrows
        set => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x43C, "Ptr", Value, "Ptr", 0, "Ptr")
    }


    ; ===================================================================================================================
    ; SPECIAL METHODS AND PROPERTIES
    ; ===================================================================================================================
    /*
        Enumerates items from the Toolbar control.
        Syntax:
            for ItemIndex, ItemText in IToolbar
            for ItemIndex in IToolbar
    */
    __Enum(NumberOfVars)
    {
        static Enumerator := Func("IToolbar_Enumerator")
        return Enumerator.Bind(this, NumberOfVars)
    }

    /*
        Retrieves or changes the text of the specified button.
    */
    __Item[Index]
    {
        get => this.GetButtonText(Index)
        set => this.SetButtonText(Index, Value)
    }
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
OnMessage(0x02, "IToolbar_OnMessage")  ; WM_DESTROY.

IToolbar_OnMessage(wParam, lParam, Message, hWnd)
{
    global IToolbar
    local

    switch Message
    {
    case 0x0002:  ; WM_DESTROY.
        for ctrl_hwnd, ctrl_obj in IToolbar.Instance.Clone()
        {
            if (ctrl_obj.Gui.Hwnd == hWnd)
            {
                ctrl_obj.Destroy()
            }
        }
    }
}

IToolbar_Enumerator(this, NumberOfVars, ByRef Key, ByRef Value := "")
{
    Key := A_Index - 1  ; Zero-based item index.
    if (NumberOfVars == 2)
        Value := this.GetButtonText(Key)  ; Item text.
    return A_Index <= this.Count
}

CreateToolbar(Gui, Options)
{
    return IToolbar.New(Gui, Options)
}

ToolbarFromHwnd(Hwnd)
{
    return IToolbar.Instance[IsObject(Hwnd)?Hwnd.hWnd:Hwnd]
}
