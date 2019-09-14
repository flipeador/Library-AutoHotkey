; AutoHotkey v2.0-a104-3e7a969d.

/*
    Encapsulates the creation and manipulation by means of messages of a standart ComboBoxEx control in a class.
    Remarks:
        Item indexes are zero based.
        DllCall is used instead of SendMessage to improve performance.
        Include this file in the Auto-execute Section of the script.
    ComboBoxEx Control Reference:
        https://docs.microsoft.com/en-us/windows/win32/controls/comboboxex-control-reference
*/
class IComboBoxEx  ; https://github.com/flipeador  |  https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=60315
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Type         := "ComboBoxEx"    ; A string with the control type name.
    static ClassName    := "ComboBoxEx32"  ; A string with the control class name.
    static Instance     := Map()           ; Instances of this control (ctrl_handle:this).


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Gui          := 0         ; The Gui object associated with this control.
    Ctrl         := 0         ; The Gui control class object.
    hWnd         := 0         ; The control Handle.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Adds a ComboBoxEx control to the specified GUI window. The CreateComboBox function can be used to create the control.
        Parameters:
            Gui:
                The GUI window object. This object must be previously created by a call to the GuiCreate function.
            Options:
                Some specific options for this control. You can specify one or more of the following words.
                Simple      (CBS_SIMPLE) Displays the list box at all times. The current selection in the list box is displayed in the edit control.
                            By default, the list box is not displayed unless the user selects an icon next to the edit control (CBS_DROPDOWN).
                DDL         (CBS_DROPDOWNLIST) Similar to CBS_DROPDOWN, except that the edit control is replaced by a static text item that displays the current selection in the list box.
                ChooseN     The item that will be selected by default. N is the zero-based index of the item to be selected.
                rN          Specifies the maximum number of visible rows in the list box. By default it is 5. AHK takes care of CBS_SIMPLE.
            Items:
                The items to be added once the control is created.
        Remarks:
            An existing ComboBoxEx control object can be retrieved by means of its handle using the ComboBoxFromHwnd function.
    */
    __New(Gui, Options, Items*)
    {
        global IComboBoxEx
        local

        if (Type(this.Gui:=Gui) !== "Gui")
            throw Exception("IComboBoxEx.New() - Invalid parameter #1.", -1)

        ; 0x40 = CBS_AUTOHSCROLL. 1 = CBS_SIMPLE. 2 = CBS_DROPDOWN. 3 = CBS_DROPDOWNLIST.
        style := 0x40 | (RegExMatch(Options,"i)\bsimple\b")?1:RegExMatch(Options,"i)\bddl\b")?3:2)

        if (style & 0x2)  ; CBS_DROPDOWN || CBS_DROPDOWNLIST.
        {
            rows    := RegExMatch(Options,"i)\br(\d+)\b",rows) ? rows[1] : 5  ; 5 = Default number of rows.
            Options := RegExReplace(Options, "i)\br\d+\b")
        }

        Options   := RegExReplace(Options, "i)\b(simple|ddl)\b")
        this.Ctrl := this.Gui.AddCustom("+" . style . " +0x210000 r1 " . Options . " Class" . IComboBoxEx.ClassName)
        IComboBoxEx.Instance[this.Ptr:=this.hWnd:=this.Ctrl.hWnd] := this

        ; CBEM_SETUNICODEFORMAT message.
        ; https://docs.microsoft.com/en-us/windows/win32/controls/cbem-setunicodeformat.
        SendMessage(0x2005, TRUE,, this)  ; Sets the Unicode character format flag for the control.

        if (style & 0x2)  ; CBS_DROPDOWN || CBS_DROPDOWNLIST.
            this.SetVisibleRows(rows)
        for Item in Items
            this.Add(, string(Item))
        if (RegExMatch(Options,"i)\bchoose(\d+)\b",match))
            this.SetCurSel(match[1])
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
        IComboBoxEx.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this)
    }

    /*
        Inserts a new item in this combo box.
        Parameters:
            Index:
                The zero-based index of a item.
                The method inserts the new item to the left of this item.
                To insert an item at the end of the list, set the Index parameter to -1.
            Text:
                A string with the text for the item.
            Image:
                The zero-based index of an image within the image list. The specified image will be displayed for the item when it is not selected.
                If this parameter is set to -1 (I_IMAGECALLBACK), the control will request the information by using CBEN_GETDISPINFO notification codes.
            SelImage:
                The zero-based index of an image within the image list. The specified image will be displayed for the item when it is selected.
                If this member is set to -1 (I_IMAGECALLBACK), the control will request the information by using CBEN_GETDISPINFO notification codes.
            Overlay:
                The one-based index of an overlay image within the image list.
                If this member is set to -1 (I_IMAGECALLBACK), the control will request the information by using CBEN_GETDISPINFO notification codes.
            Indent:
                The number of indent spaces to display for the item. Each indentation equals 10 pixels.
                If this member is set to -1 (I_INDENTCALLBACK), the control will request the information by using CBEN_GETDISPINFO notification codes.
            Data:
                Application-defined value associated with the ComboBox item.
                This value must be any integer number. By default it is zero.
        Return value:
            If the method succeeds, the return value is the index at which the new item was inserted.
            If the method fails, the return value is -1.
    */
    Add(Index := -1, Text := "", Image := 0, SelImage := 0, Overlay := 0, Indent := 0, Data := 0)
    {
        local COMBOBOXEXITEM := BufferAlloc(A_PtrSize==4?36:56)
        NumPut("UPtr",Data,NumPut("Int",Image,"Int",SelImage,"Int",Overlay,"Int",Indent,NumPut("UPtr",&Text,NumPut("Ptr",Index,NumPut("UInt",0x3F,COMBOBOXEXITEM)+A_PtrSize-4))+A_PtrSize-4))
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40B, "Ptr", 0, "Ptr", COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-insertitem

    /*
        Deletes the specified item from the combo box.
        Parameters:
            Index:
                The zero-based index of the item to delete.
        Return value:
            If the method succeeds, the return value is the number of items remaining in the control.
            If the method fails, the return value is -1.
    */
    Delete(Index)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x144, "Ptr", Index, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-deleteitem

    /*
        Removes all items from the list box and edit control of the combo box.
    */
    DeleteAll()
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x14B, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-resetcontent

    /*
        Retrieves the display text of the specified item in the list box of the combo box.
        Parameters:
            Index:
                The zero-based index of the item whose text is to be retrieved.
        Return value:
            Returns a string with the text that is currently displayed by the item.
            An empty string indicates one of the following cases:
                1) The display text of the item is an empty string.
                3) The index of the specified item is invalid.
    */
    GetItemText(Index)
    {
        local Length := DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x149, "Ptr", Index, "Ptr", 0, "Ptr")  ; CB_GETLBTEXTLEN message.
        if (Length <= 0)  ; Length: The length, in characters, of the string in the list of the combo box, not including zero.
            return ""     ; Error (?).
        local Buffer         := BufferAlloc(2*Length+2)          ; Character buffer (up to «Length+1» characters).
        local COMBOBOXEXITEM := BufferAlloc(A_PtrSize==4?36:56)  ; COMBOBOXEXITEMW structure.
        NumPut("Ptr", Index, "UPtr", NumPut("UShort",0,Buffer)-2, "Int", Length+1, NumPut("UInt",1,COMBOBOXEXITEM)+A_PtrSize-4)
        ; If the CBEIF_TEXT flag is set in the mask member of the COMBOBOXEXITEM structure, the control may change the-
        ; -pszText member of the structure to point to the new text instead of filling the buffer with the requested text.
        ; Applications should not assume that the text will always be placed in the requested buffer.  (*)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40D, "Ptr", 0, "Ptr", COMBOBOXEXITEM, "Ptr")
             ? StrGet(NumGet(COMBOBOXEXITEM,2*A_PtrSize), Length)  ; Ok.     (* -> NumGet)
             : ""                                                  ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-getitem

    /*
        Changes the display text of the specified item in the list box of the combo box.
        Parameters:
            Index:
                The zero-based index of the item whose text is to be changed.
            Text:
                A string that contains the new text for the item.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    SetItemText(Index, Text)
    {
        local COMBOBOXEXITEM := BufferAlloc(A_PtrSize==4?36:56)  ; COMBOBOXEXITEMW structure.
        NumPut("Ptr", Index, "UPtr", &Text, NumPut("UInt",1,COMBOBOXEXITEM)+A_PtrSize-4)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40C, "Ptr", 0, "Ptr", COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-setitem

    /*
        Retrieves the text of the edit control of the combo box.
    */
    GetEditText()
    {
        return ControlGetText("Edit1", "ahk_id" . this.hWnd)
    }

    /*
        Changes the text of the edit control of the combo box.
    */
    SetEditText(Text)
    {
        ControlSetText(Text, "Edit1", "ahk_id" . this.hWnd)
    }

    /*
        Determines whether the user has changed the text of a ComboBoxEx edit control.
        Return value:
            Returns TRUE if the text in the control's edit box has been changed, or FALSE otherwise.
        Remarks:
            When the user begins editing, you will receive a CBEN_BEGINEDIT notification.
            When editing is complete, or the focus changes, you will receive a CBEN_ENDEDIT notification.
            The CBEM_HASEDITCHANGED message is only useful for determining whether the text has been changed if it is sent before the CBEN_ENDEDIT notification.
            If the message is sent afterward, it will return FALSE. For example, suppose the user starts to edit the text in the edit box but changes focus, generating a CBEN_ENDEDIT notification. If you then send a CBEM_HASEDITCHANGED message, it will return FALSE, even though the text has been changed.
    */
    HasEditChanged()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40A, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-haseditchanged

    /*
        Retrieves the starting and ending character positions of the current selection in the edit control of a combo box.
        Return value:
            Returns an object with the following properties:
                Start    Receives the starting position of the selection.
                End      Receives the ending position of the selection.
    */
    GetEditSel()
    {
        local Sel := DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x140, "Ptr", 0, "Ptr", 0, "Ptr")
        return { Start:Sel&0xFFFF , End:(Sel>>16)&0xFFFF }
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-geteditsel

    /*
        Selects characters in the edit control of the combo box.
        Parameters:
            Start:
                Specifies the starting character position of the selection.
            End:
                Specifies the ending character position of the selection.
    */
    SetEditSel(Start, End := "")
    {
        DllCall("User32.dll\SendMessageW", "Ptr", this.EditControl, "UInt", 0xB1, "Ptr", Start, "Ptr", End==""?Start:End, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/em-setsel

    /*
        Retrieves the text that is displayed as the textual cue, or tip, in the edit control.
        Return value:
            If the method succeeds, the return value is a string with the text set as the textual cue.
            If the method fails, the return value an empty string.
    */
    GetCueBanner()
    {
        local Buffer := BufferAlloc(2048)  ; Character buffer (up to 1024 characters).
        return DllCall("User32.dll\SendMessageW", "Ptr", this.EditControl, "UInt", 0x1502, "Ptr", Buffer, "Ptr", Buffer.Size//2, "Ptr")
             ? StrGet(Buffer)  ; Ok.
             : ""              ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/em-getcuebanner

    /*
        Sets the textual cue, or tip, that is displayed by the edit control to prompt the user for information.
        Parameters:
            Text:
                A string with the text to display as the textual cue.
            Mode:
                FALSE    The cue banner disappears when the user clicks in the control.
                TRUE     The cue banner should show even when the edit control has focus.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    SetCueBanner(Text, Mode := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.EditControl, "UInt", 0x1501, "Ptr", Mode, "Str", String(Text), "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/em-setcuebanner

    /*
         Retrieves the index of the currently selected item, if any, in the list box of the combo box.
         Return value:
            The return value is the index of the currently selected item.
            If no item is selected, the return value is -1.
    */
    GetCurSel()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x147, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-getcursel

    /*
        Selects a string in the list of the combo box. If necessary, the list scrolls the string into view.
        The text in the edit control of the combo box changes to reflect the new selection, and any previous selection in the list is removed.
        Parameters:
            Index:
                The zero-based index of the string to select.
                If this parameter is -1, any current selection in the list is removed and the edit control is cleared.
        Return value:
            If the method succeeds, the return value is the index of the item selected.
            If 'Index' is greater than the number of items in the list or if 'Index' is -1, the return value is -1 and the selection is cleared.
    */
    SetCurSel(Index)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x14E, "Ptr", Index, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-setcursel

    /*
        Retrieves the number of indent spaces to display for the specified item.
        Return value:
            If the method succeeds, the return value is the item indent.
            If the method fails, the return value is -1.
    */
    GetItemIndent(Index)
    {
        local COMBOBOXEXITEM := BufferAlloc(A_PtrSize==4?36:56)  ; COMBOBOXEXITEMW structure.
        NumPut("Ptr", Index, NumPut("UInt",0x10,COMBOBOXEXITEM)+A_PtrSize-4)
       return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40D, "Ptr", 0, "Ptr", COMBOBOXEXITEM, "Ptr")
            ? NumGet(COMBOBOXEXITEM, 3*A_PtrSize+16, "Int")  ; Ok.
            : -1                                             ; Error.
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-getitem

    /*
        Sets the number of indent spaces to display for the specified item.
        Parameters:
            Index:
                The zero-based index of the item whose indent is to be changed.
            Indent:
                The number of indent spaces to display for the item. Each indentation equals 10 pixels.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    SetItemIndent(Index, Indent)
    {
        local COMBOBOXEXITEM := BufferAlloc(A_PtrSize==4?36:56)  ; COMBOBOXEXITEMW structure.
        NumPut("Int", Indent, NumPut("Ptr",Index,NumPut("UInt",0x10,COMBOBOXEXITEM)+A_PtrSize-4)+A_PtrSize+16)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40C, "Ptr", 0, "Ptr", COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-setitem

    /*
        Retrieves the handle to an image list assigned to a ComboBoxEx control.
        Return value:
            Returns the handle to the image list assigned to the control if successful, or zero otherwise.
    */
    GetItemImageList()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x403, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-getimagelist

    /*
        Sets an image within the image list to the specified item.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    SetItemImage(Index, Image := 0, SelImage := 0, Overlay := 0)
    {
        local COMBOBOXEXITEM := BufferAlloc(A_PtrSize==4?36:56)  ; COMBOBOXEXITEMW structure.
        NumPut("Int", Image, "Int", SelImage, "Int", Overlay, NumPut("Ptr",Index,NumPut("UInt",(Image==""?0:2)|(SelImage==""?0:4)|(Overlay==""?0:8),COMBOBOXEXITEM)+A_PtrSize-4)+A_PtrSize+4)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40C, "Ptr", 0, "Ptr", COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem

    /*
        Sets an image list for a ComboBoxEx control.
        Parameters:
            ImageList:
                A handle to the image list to be set for the control.
        Return value:
            Returns the handle to the image list previously associated with the control, or returns zero if no image list was previously set.
        Remarks:
            The height of images in your image list might change the size requirements of the ComboBoxEx control.
            It is recommended that you resize the control after sending this message to ensure that it is displayed properly.
    */
    SetImageList(ImageList)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x402, "Ptr", 0, "Ptr", ImageList, "UPtr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cbem-setimagelist

    /*
        Determines the height of list items or the selection field in a combo box.
        Parameters:
            Component:
                The combo box component whose height is to be retrieved.
                0     Retrieves the height of list items.
                1     Retrieves the height of the selection field.
        Return value:
            Returns the height, in pixels, of the list items in a combo box.
            If 'Component' is 1, the return value is the height of the edit control (or static-text) portion of the combo box. If an error occurs, the return value is -1 (CB_ERR).
    */
    GetItemHeight(Component := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x154, "Ptr", Component, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-getitemheight

    /*
        Set the height of list items or the selection field in a combo box.
        Parameters:
            Component:
                Specifies the component of the combo box for which to set the height.
                0     Sets the height of list items.
                1     Sets the height of the selection field.
            Height:
                Specifies the height, in pixels, of the combo box component identified by wParam.
        Return value:
            If the index or height is invalid, the return value is -1 (CB_ERR).
        Remarks:
            The selection field height in a combo box is set independently of the height of the list items.
            An application must ensure that the height of the selection field is not smaller than the height of a particular list item.
    */
    SetItemHeight(Height, Component := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x153, "Ptr", Component, "Ptr", Height, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-setitemheight

    /*
        Retrieves the zero-based index of the first visible item in the list box portion of this combo box.
        Initially, the item with index 0 is at the top of the list box, but if the list box contents have been scrolled, another item may be at the top.
        Return value:
            If the method succeeds, the return value is the index of the first visible item in the list box of this combo box.
            If the message fails, the return value is -1 (CB_ERR).
    */
    GetTopIndex()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x15B, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-gettopindex

    /*
        Ensures that a particular item is visible in the list box of a combo box.
        The system scrolls the list box contents so that either the specified item appears at the top of the list box or the maximum scroll range has been reached.
        Parameters:
            Index:
                Specifies the zero-based index of the list item.
        Return value:
            If the method succeeds, the return value is zero.
            If the method fails, the return value is -1 (CB_ERR).
    */
    SetTopIndex(Index)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x15C, "Ptr", Index, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-settopindex

    /*
        Retrieves the zero-based index of the item that matches the specified associated value.
        Parameters:
            Data:
                The application-defined value associated with the item (integer number).
            Start:
                Specifies the starting item index.
        Return value:
            Returns the zero-based index of the item, or -1 if the item cannot be found.
    */
    ItemFromData(Data, Start := 0)
    {
        loop (this.Count - Start)
            if (DllCall("User32.dll\SendMessageW","Ptr",this.hWnd,"UInt",0x150,"Ptr",Start+A_Index-1,"Ptr",0,"UPtr") == Data)
                return A_Index - 1
        return -1  ; CB_ERR.
    } ; GetCount + GetItemData

    /*
        Retrieves the application-defined value associated with the specified item from the combo box.
        Parameters:
            Index:
                The zero-based index of the item whose application-defined value is to be retrieved.
        Return value:
            Returns the application-defined value associated with the item (integer number).
            If the method fails, the return value is -1 (CB_ERR).
    */
    GetItemData(Index)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x150, "Ptr", Index, "Ptr",  0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-getitemdata

    /*
        Changes the application-defined value associated with the specified item from the combo box.
        Parameters:
            Index:
                The zero-based index of the item whose application-defined value is to be changed.
            Data:
                The new application-defined value associated with the item (integer number).
        Return value:
            If an error occurs, the return value is -1 (CB_ERR).
    */
    SetItemData(Index, Data)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x151, "Ptr", Index, "Ptr", Data, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-setitemdata

    /*
        Sets the maximum number of visible rows in the list box.
        Parameters:
            Rows:
                The desired number of rows.
        Return value:
            TRUE if successful, or FALSE otherwise.
    */
    SetVisibleRows(Rows)
    {
        return ControlMove(,,, this.ctrl.pos.h+Rows*this.GetItemHeight()+2, this.ComboControl)  ; CTRL_POS_HEIGHT+(ROWS*SINGLE_ITEM_HEIGHT)+BORDERS_PADDING_x1PX.
    }

    /*
        Retrieves the screen coordinates of this combo box in its dropped-down state.
        Return value:
            If the method succeeds, the return value is an object with the properties L(eft), T(op), R(ight) and B(ottom).
            If the method fails, the return value is zero.
    */
    GetDroppedCtrlRect()
    {
        local RECT := BufferAlloc(16)
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x152, "Ptr", 0, "Ptr", RECT, "Ptr")
             ? {L:NumGet(RECT,"Int") , T:NumGet(RECT,4,"Int") , R:NumGet(RECT,8,"Int") , B:NumGet(RECT,12,"Int")}  ; Ok.
             : 0                                                                                                   ; Error.
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-getdroppedcontrolrect

    /*
        Retrieves the client coordinates (relative to the parent window) of the combo box in its dropped-down state.
        Return value:
            If the method succeeds, the return value is an object with the properties X, Y, W and H.
            If the method fails, the return value is zero.
    */
    GetDroppedCtrlRect2()
    {
        local RECT := BufferAlloc(16)
        if (!DllCall("User32.dll\SendMessageW","Ptr",this,"UInt",0x152,"Ptr",0,"Ptr",RECT,"Ptr"))
            return 0
        local R := Array(NumGet(RECT,8,"Int")-NumGet(RECT,"Int"), NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int"))
        return DllCall("User32.dll\ScreenToClient", "Ptr", this.Gui.hWnd, "Ptr", RECT)
             ? {W:R[1] , H:R[2] , X:NumGet(RECT,"Int") , Y:NumGet(RECT,4,"Int")}  ; Ok.
             : 0                                                                  ; Error.
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-getdroppedcontrolrect

    /*
        Determines whether the list box of the combo box is dropped down.
        Return value:
            If the list box is visible, the return value is TRUE; otherwise, it is FALSE.
    */
    GetDroppedState()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x157, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-getdroppedstate

    /*
        Shows or hides the list box of the combo box that has the CBS_DROPDOWN or CBS_DROPDOWNLIST style.
        Parameters:
            State:
                A value that specifies whether the drop-down list box is to be shown or hidden.
                -1    Toggle the current list box state.
                 0    Hide the list box. It can be any value evaluated as FALSE.
                 1    Show the list box. It can be any value evaluated as TRUE (except -1).
        Return value:
            If the method succeeds, the return value is the previous state (TRUE/FALSE).
            If the method fails, the return value is -1 (CB_ERR).
        Remarks:
            This method has no effect on a combo box created with the CBS_SIMPLE style.
    */
    ShowDropDown(State := 1)
    {
        if (!(WinGetStyle("ahk_id" . this.hWnd) & 0x2))
            return -1 ; CB_ERR.
        local old_state := this.GetDroppedState()  ; Gets the current state.
        SendMessage(0x14F, State==-1 ? !old_state : !!State,, this)
        return old_state
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-showdropdown

    /*
        Gets the width, in pixels, that the list box can be scrolled horizontally (the scrollable width).
        This is applicable only if the list box has a horizontal scroll bar.
        Return value:
            The return value is the scrollable width, in pixels.
    */
    GetHorizontalExtent()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x15d, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cb-gethorizontalextent

    /*
        Finds the zero-based index of the first item whose text matches the specified string.
        Parameters:
            Text:
                A string containing the text that will be searched.
            Start / End:
                The search range (inclusive).
                If «End» is omitted, it searches from «Start» to the end (it does not start from the beginning up to Start-1).
                For example, to search the entire list starting with the item at index 5: (5,4).
            Mode:
                Determines the behavior of the search. Any combination of the following flags may be specified.
                0x0    Finds the item whose text exactly matches the specified string.
                0x1    Compares only the portion of text specified in parameters «StartingPos» and «Length» (SubStr).
                0x2    Finds the item whose text coincides partially with the specified string.
                0x4    Specifies a case-sensitive search.
                0x8    Use regular expression (RegExMath). Can only be combined with 0x1.
            StartingPos / Length:
                These parameters are passed to the built-in SubStr function when the 0x1 flag is used.
                It is applied to the item text, and then used in the comparison with «Text».
        Return value:
            Returns the zero-based index of the matching item. -1 if the search has not been successful.
    */
    FindText(Text, Start := 0, End := -1, Mode := 0, StartingPos := 0, Length := 0)
    {
        local l := this.count-1, r := Array(Start<0?0:Start>l?l:Start,End<0||End>l?l:End)
        , s, re := Mode&8, cs := Mode&4, ps := Mode&2, bs := Mode&1, i := 0
        loop (r[2]<r[1] ? l-r[1]+r[2]+2 : r[2]-r[1]+1) {
            if (re) {
                if (RegExMatch(bs?SubStr(this.GetItemText(r[1]),StartingPos,Length):this.GetItemText(r[1]),Text))
                    return r[1]  ; Ok.
            } else {
                s := bs ? SubStr(this.GetItemText(r[1]),StartingPos,Length) : this.GetItemText(r[1])
                if (ps ? InStr(s,Text,cs) : !StrCompare(s,Text,cs))
                    return r[1]  ; Ok.
            } r[1] := r[1] == l ? 0 : r[1] + 1
        } return -1  ; Error.
    }

    /*
        Registers a function or method to be called when the given event is raised by this control.
        Parameters:
            Events:
                SelChange:
                    Sent when the user changes the current selection in the list box of a combo box.
                    The user can change the selection by clicking in the list box or by using the arrow keys.
                    The CBN_SELCHANGE notification code is not sent when the current selection is set using the CB_SETCURSEL message.
                DoubleClick:
                    Sent when the user double-clicks a string in the list box of a combo box.
                Focus:
                    Sent when a combo box receives the keyboard focus.
                LoseFocus:
                    Sent when a combo box loses the keyboard focus.
                EditChange:
                    Sent after the user has taken an action that may have altered the text in the edit control portion of a combo box.
                    Unlike the CBN_EDITUPDATE notification code, this notification code is sent after the system updates the screen.
                EditUpdate:
                    Sent when the edit control portion of a combo box is about to display altered text.
                    This notification code is sent after the control has formatted the text, but before it displays the text.
                DropDown:
                    Sent when the list box of a combo box is about to be made visible.
                CloseUp:
                    Sent when the list box of a combo box has been closed.
                SelEndOk:
                    Sent when the user selects a list item, or selects an item and then closes the list. It indicates that the user's selection is to be processed.
                SelEndCancel:
                    Sent when the user selects an item, but then selects another control or closes the dialog box. It indicates the user's initial selection is to be ignored.
            Callback / AddRemove:
                See OnCommand (Gui) in the AutoHotkey documentation.
                Reference: https://lexikos.github.io/v2/docs/objects/GuiOnCommand.htm.
        Remarks:
            The callback function receives a single parameter: the control object.
    */
    OnEvent(EventName, Callback, AddRemove := 1)
    {
        loop parse, "SelChange|DoubleClick|Focus|LoseFocus|EditChange|EditUpdate|DropDown|CloseUp|SelEndOk|SelEndCancel", "|"
            if (A_LoopField = EventName)
                return this.Ctrl.OnCommand(A_Index, Callback, AddRemove)
        throw Exception("IComboBoxEx.OnEvent() - Invalid parameter #1.", -1)
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/bumper-combobox-control-reference-notifications

    /*
        Retrieves the extended styles currently in use for the combo box control.
        Return value:
            Returns a value that represents the extended styles currently in use for the combo box control.
    */
    GetExStyle()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x409, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/en-us/windows/win32/controls/cbem-getextendedstyle

    /*
        Sets the extended styles for the combo box control.
        Parameters:
            Value:
                A value that contains the ComboBoxEx control extended styles to set for the control.
                0x00000001  CBES_EX_NOEDITIMAGE          The edit box and the dropdown list will not display item images.
                0x00000002  CBES_EX_NOEDITIMAGEINDENT    The edit box and the dropdown list will not display item images.
                0x00000004  CBES_EX_PATHWORDBREAKPROC    The edit box will use the slash (/), backslash (\), and period (.) characters as word delimiters.
                                                         This makes keyboard shortcuts for word-by-word cursor movement effective in path names and URLs.
                0x00000008  CBES_EX_NOSIZELIMIT          Allows the ComboBoxEx control to be vertically sized smaller than its contained combo box control.
                                                         If the ComboBoxEx is sized smaller than the combo box, the combo box will be clipped.
                0x00000010  CBES_EX_CASESENSITIVE        BSTR searches in the list will be case sensitive. This includes searches as a result of text being
                                                         typed in the edit box and the CB_FINDSTRINGEXACT message.
                0x00000020  CBES_EX_TEXTENDELLIPSIS      Causes items in the drop-down list and the edit box (when the edit box is read only) to be truncated
                                                         with an ellipsis (...) rather than just clipped by the edge of the control. This is useful when the
                                                         control needs to be set to a fixed width, yet the entries in the list may be long.
            Mask:
                A value that indicates which extended styles in «Value» are to be affected. Only the extended styles in «Mask» will be changed.
                If this parameter is zero, then all of the extended styles in «Value» will be affected.
        Return value:
            Returns a value that contains the extended styles previously used for the control.
        Remarks:
            «Mask» enables you to modify one or more extended styles without having to retrieve the existing styles first.
            For example, if you pass CBES_EX_NOEDITIMAGE for «Mask» and 0 for «Value», the CBES_EX_NOEDITIMAGE style will be cleared, but all other styles will remain the same.
            If you try to set an extended style for a ComboBoxEx control created with the CBS_SIMPLE style, it may not repaint properly.
            The CBS_SIMPLE style also does not work properly with the CBES_EX_PATHWORDBREAKPROC extended style.
        ComboBoxEx Control Extended Styles:
            https://docs.microsoft.com/es-es/windows/win32/controls/comboboxex-control-extended-styles
    */
    SetExStyle(Value, Mask := 0)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x40E, "Ptr", Mask, "Ptr", Value, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-setextendedstyle

    /*
        Allow or prevent changes in the control to be redrawn.
        Parameters:
            Mode:
                FALSE    The content cannot be redrawn after a change.
                TRUE     The content can be redrawn after a change.
    */
    SetRedraw(Mode)
    {
        this.ShowDropDown(0)
        loop parse, this.hWnd . A_Tab . this.EditControl . A_Tab . this.ComboControl, A_Tab
            DllCall("User32.dll\SendMessageW", "Ptr", A_LoopField, "UInt", 0xB, "Ptr", !!Mode, "Ptr", 0, "Ptr")
        if (Mode)
            DllCall("User32.dll\InvalidateRect", "Ptr", this, "Ptr", 0, "Int", TRUE)
           ,DllCall("User32.dll\UpdateWindow", "Ptr", this)
    } ; https://docs.microsoft.com/en-us/windows/win32/gdi/wm-setredraw


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Retrieves the number of items in the list box of the combo box.
    */
    Count[] => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x146, "Ptr", 0, "Ptr", 0, "Ptr")
    ; https://docs.microsoft.com/es-es/windows/win32/controls/cb-getcount

    /*
        Retrieves or changes the the currently selected item.
    */
    Selection[]
    {
        get => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x147, "Ptr", 0x000, "Ptr", 0, "Ptr")
        set => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x14E, "Ptr", Value, "Ptr", 0, "Ptr")
    } ; GetCurSel + SetCurSel

    /*
        Retrieves the handle to the child combo box control within the ComboBoxEx control.
    */
    ComboControl[] => DllCall("User32.dll\SendMessageW", "Ptr", this, "UInt", 0x406, "Ptr", 0, "Ptr", 0, "UPtr")
    ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-getcombocontrol

    /*
        Retrieves the handle to the edit control portion of a ComboBoxEx control if it uses the CBS_DROPDOWN style..
        A ComboBoxEx control uses an edit box when it is set to the CBS_DROPDOWN (2) style.
    */
    EditControl[] => ControlGetHwnd("Edit1", "ahk_id" . this.hwnd) || 0
    ; https://docs.microsoft.com/es-es/windows/win32/controls/cbem-geteditcontrol

    /*
        Retrieves the current focus state of the control.
        0    The control doesn't has the focus.
        1    The list box control has the focus (drop-down list box is visible).
        2    The edit control has the focus (default).
        3    The combo box has the focus (rare).
    */
    Focused[]
    {
        get {
            local hWnd := ControlGetFocus("ahk_id" . this.Gui.hWnd)
            return hWnd == this.ComboControl ? 1 : hWnd == this.EditControl ? 2 : hWnd == this.hWnd ? 3 : 0
        }
    }


    ; ===================================================================================================================
    ; SPECIAL METHODS AND PROPERTIES
    ; ===================================================================================================================
    /*
        Enumerates items from the combo box control.
        Syntax:
            for ItemIndex, ItemText in IComboBoxEx
            for ItemIndex in IComboBoxEx
    */
    __Enum(NumberOfVars)
    {
        static Enumerator := Func("IComboBoxEx_Enumerator")
        return Enumerator.Bind(this, NumberOfVars)
    }

    /*
        Retrieves or changes the text of the specified item.
    */
    __Item[Index]
    {
        get => Index==-1&&this.EditControl ? this.GetEditText()      : this.GetItemText(Index==-1 ? this.Selection : Index       )
        set => Index==-1&&this.EditControl ? this.SetEditText(Value) : this.SetItemText(Index==-1 ? this.Selection : Index, Value)
    }
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
OnMessage(0x02, "IComboBoxEx_OnMessage")  ; WM_DESTROY.

IComboBoxEx_OnMessage(wParam, lParam, Message, hWnd)
{
    global IComboBoxEx
    local

    switch Message
    {
    case 0x0002:  ; WM_DESTROY.
        for ctrl_hwnd, ctrl_obj in IComboBoxEx.Instance.Clone()
        {
            if (ctrl_obj.Gui.Hwnd == hWnd)
            {
                ctrl_obj.Destroy()
            }
        }
    }
}

IComboBoxEx_Enumerator(this, NumberOfVars, ByRef Key, ByRef Value := "")
{
    Key := A_Index - 1  ; Zero-based item index.
    if (NumberOfVars == 2)
        Value := this.GetItemText(Key)  ; Item text.
    return A_Index <= this.Count
}

CreateComboBox(Gui, Options, Items*)
{
    return IComboBoxEx.New(Gui, Options, Items*)
}

ComboBoxFromHwnd(Hwnd)
{
    return IComboBoxEx.Instance[IsObject(Hwnd)?Hwnd.hWnd:Hwnd]
}
