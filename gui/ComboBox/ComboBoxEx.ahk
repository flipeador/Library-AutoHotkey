; Clipboard := Format("0x{:X}", 0x0400+60)
; iItem A_PtrSize, pszText 2*A_PtrSize, cchTextMax 3*A_PtrSize, iImage 3*A_PtrSize+4, iSelectedImage 3*A_PtrSize+8, iOverlay 3*A_PtrSize+12, iIndent 3*A_PtrSize+16, lParam 4*A_PtrSize+16





/*
    Remarks:
        Item indexes are zero based.
        Sometimes DllCall is used instead of SendMessage for better performance.
    ComboBoxEx Control Reference:
        https://docs.microsoft.com/en-us/windows/desktop/controls/comboboxex-control-reference
    ComboBox Control Styles:
        https://docs.microsoft.com/es-es/windows/desktop/Controls/combo-box-styles
    ComboBoxEx Control Extended Styles:
        https://docs.microsoft.com/es-es/windows/desktop/Controls/comboboxex-control-extended-styles
*/
class ComboBoxEx
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Type         := "ComboBoxEx"    ; The type of the control.
    static ClassName    := "ComboBoxEx32"  ; Control class.
    static Instance     := { }             ; Instances of this control {hwnd:ctrl_obj}.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Gui            := 0                          ; Gui Object.
    Ctrl           := 0                          ; Gui Control Object.
    hWnd           := 0                          ; The HWND of the control.
    hGui           := 0                          ; The HWND of the GUI.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Adds a ComboBoxEx control to the specified GUI window.
        Parameters:
            Gui:
                The GUI window object.
                You can specify an existing control to retrieve the control object.
            Options:
                Some special options for this control. By default, the list box is not displayed unless the user selects an icon next to the edit control (CBS_DROPDOWN).
                Simple      (CBS_SIMPLE) Displays the list box at all times. The current selection in the list box is displayed in the edit control.
                DDL         (CBS_DROPDOWNLIST) Similar to CBS_DROPDOWN, except that the edit control is replaced by a static text item that displays the current selection in the list box.
                ChooseN     The item that will be selected by default. N is the zero-based index of the item to be selected.
                rN          Specifies the maximum number of visible rows in the list box. By default it is 5. AHK takes care of CBS_SIMPLE.
            Items:
                The initial list of items that are to be added in the control.
    */
    __New(Gui, Options := "", Items*)
    {
        if (  ComboBoxEx.Instance.HasKey( this.hGui := IsObject(Gui) ? Gui.hWnd : Gui )  )
            return ComboBoxEx.Instance[ this.hGui ]

        if ( Type(this.Gui:=GuiFromHwnd(this.hGui)) !== "Gui" )
            throw Exception("ComboBoxEx class invalid parameter #1.", -1)
        if ( Type(Options) !== "String" )
            throw Exception("ComboBoxEx class invalid parameter #2.", -1)

        if ( ComboBoxEx.Instance.Count() == 0 )
            OnMessage(0x02, "ComboBoxEx_OnMessage")  ; WM_DESTROY.

        ; 0x40 = CBS_AUTOHSCROLL. 1 = CBS_SIMPLE. 2 = CBS_DROPDOWN. 3 = CBS_DROPDOWNLIST.
        local style := 0x40 | (RegExMatch(Options,"i)\bsimple\b")?1:RegExMatch(Options,"i)\bddl\b")?3:2)

        if ( style & 0x2 )  ; CBS_DROPDOWN || CBS_DROPDOWNLIST.
        {
            local rows
            rows    := RegExMatch(Options,"i)\br(\d+)\b",rows) ? rows[1] : 5  ; 5 = Default number of rows.
            Options := RegExReplace(Options, "i)\br\d+\b")
        }

        ; ComboBoxEx Control Reference.
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775740.aspx.
        Options   := RegExReplace(Options, "i)\b(simple|ddl)\b")
        this.ctrl := this.Gui.AddCustom("+" . style . " +0x210000 r1 " . Options . " Class" . ComboBoxEx.ClassName)
        this.hWnd := this.Ctrl.hWnd
        ComboBoxEx.Instance[this.hWnd] := this

        SendMessage(0x2005, TRUE,, this)  ; CBEM_SETUNICODEFORMAT.
        if ( style & 0x2 )  ; CBS_DROPDOWN || CBS_DROPDOWNLIST.
            this.SetVisibleRows(rows)

        loop ( Items.Length() )
            this.add(, string(Items[A_Index]) )

        local match
        if ( RegExMatch(Options,"i)\bchoose(\d+)\b",match) )
            this.SetCurSel( match[1] )
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Destroy()
    {
        ComboBoxEx.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd, "Int")

        if ( ComboBoxEx.Instance.Count() == 0 )
            OnMessage(0x02, "ComboBoxEx_OnMessage", 0)  ; WM_DESTROY.
    }

    /*
        Inserts a new item.
        Parameters:
            Item:
                The zero-based index of the item.
            Text:
                A string that contains the item's text.
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
            lParam:
                A value specific to the item.
        Return value:
            Returns the index at which the new item was inserted if successful, or -1 otherwise.
    */
    Add(Item := -1, ByRef Text := "", Image := 0, SelImage := 0, Overlay := 0, Indent := 0, lParam := 0)
    {
        local COMBOBOXEXITEM
        VarSetCapacity(COMBOBOXEXITEM, A_PtrSize == 4 ? 36 : 56)
       ,NumPut(lParam,NumPut(Indent,NumPut(Overlay,NumPut(SelImage,NumPut(Image,NumPut(&Text,NumPut(Item,NumPut(0x3F,&COMBOBOXEXITEM,"UInt")+A_PtrSize-4,"Ptr"),"UPtr")+4,"Int"),"Int"),"Int"),"Int")+A_PtrSize-4,"UPtr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40B, "Ptr", 0, "Ptr", &COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-insertitem
    
    /*
        Removes an item.
        Parameters:
            Item:
                The zero-based index of the item to be removed.
        Return value:
            Returns the number of items remaining in the control. If 'Item' is invalid, the message returns -1 (CB_ERR).
    */
    Delete(Item)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x144, "Ptr", Item, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-deleteitem

    /*
        Removes all items from the list box and edit control of a combo box.
        Return value:
            This message always returns 0 (CB_OKAY).
    */
    DeleteAll()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x14B, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-resetcontent

    /*
         Retrieves the index of the currently selected item, if any, in the list box of a combo box.
         Return value:
            The return value is the zero-based index of the currently selected item. If no item is selected, it is -1 (CB_ERR).
    */
    GetCurSel()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x147, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getcursel

    /*
        Selects a string in the list of a combo box. If necessary, the list scrolls the string into view.
        The text in the edit control of the combo box changes to reflect the new selection, and any previous selection in the list is removed.
        Parameters:
            Item:
                Specifies the zero-based index of the string to select. If this parameter is -1, any current selection in the list is removed and the edit control is cleared.
        Return value:
            If the message is successful, the return value is the index of the item selected.
            If 'Item' is greater than the number of items in the list or if 'Item' is -1, the return value is -1 (CB_ERR) and the selection is cleared.
    */
    SetCurSel(Item)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x14E, "Ptr", Item, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-setcursel

    /*
        Gets the length, in characters, of a string in the list of a combo box.
        Parameters:
            Item:
                The zero-based index of the string.
        Return value:
            Returns the length of the string, in characters, excluding the terminating null character.
            If the 'Item' parameter does not specify a valid index, the return value is -1 (CB_ERR).
    */
    GetTextLength(Item)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x149, "Ptr", Item, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getlbtextlen

    /*
        Gets the text of the specified item, in the list box of a combo box.
        Parameters:
            Item:
                The zero-based index of the item from which the text will be retrieved.
            Length:
                The maximum number of characters to be retrieved. If zero, the whole text is recovered.
        Return value:
            Returns the item text.
        ErrorLevel:
            It is set to zero if successful, or nonzero otherwise.
    */
    GetText(Item := -1, Length := -1)
    {
        if ( ( Length := Length == -1 ? this.GetTextLength(Item) : Length ) < 1 )
            return SubStr(ErrorLevel := Length !== 0, 0)
        
        local COMBOBOXEXITEM, Buffer
        VarSetCapacity(COMBOBOXEXITEM,A_PtrSize==4?36:56), VarSetCapacity(Buffer, 2*Length+2)
       ,NumPut(Length+1, NumPut(&Buffer,NumPut(Item,NumPut(1,&COMBOBOXEXITEM,"UInt")+A_PtrSize-4,"Ptr"),"UPtr"), "Int")
        return ( ErrorLevel := !SendMessage(0x40D,,&COMBOBOXEXITEM,this) ) ? "" : StrGet(&Buffer,Length,"UTF-16")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getitem

    /*
        Sets the text of the specified item, in the list box of a combo box.
            Item:
               The zero-based index of the item.
            Text:
                The text to be set.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetText(Item, ByRef Text)
    {
        local COMBOBOXEXITEM
        VarSetCapacity(COMBOBOXEXITEM, A_PtrSize == 4 ? 36 : 56)
       ,NumPut(&Text, NumPut(Item,NumPut(1,&COMBOBOXEXITEM,"UInt")+A_PtrSize-4,"Ptr"), "UPtr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", 0, "Ptr", &COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem

    /*
        Gets the number of items in the list box of a combo box.
        Return value:
            The return value is the number of items in the list box. If an error occurs, it is -1 (CB_ERR).
    */
    GetCount()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x146, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getcount

    /*
        Gets the handle to the child combo box control.
        Return value:
            Returns the handle to the combo box control within the ComboBoxEx control.
    */
    GetComboControl()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x406, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getcombocontrol

    /*
        Gets the handle to the edit control portion of a ComboBoxEx control. A ComboBoxEx control uses an edit box when it is set to the CBS_DROPDOWN (2) style.
        Return value:
            Returns the handle to the edit control within the ComboBoxEx control if it uses the CBS_DROPDOWN (2) style. Otherwise, the message returns NULL.
    */
    GetEditControl()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x407, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-geteditcontrol

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
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40A, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-haseditchanged

    /*
        Gets the starting and ending character positions of the current selection in the edit control of a combo box.
        Return value:
            Returns an object with the following keys:
                v          Value with the starting position of the selection in the LOWORD and with the ending position of the first character after the last selected character in the HIWORD.
                Start      Receives the starting position of the selection.
                End        Receives the ending position of the selection.
    */
    GetEditSel()
    { 
        local start := 0, end := 0
        return { v:SendMessage(0x140,&start,&end,this) , start:start , end:end }
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-geteditsel

    /*
        Selects characters in the edit control of a combo box.
        Parameters:
            Start:
                Specifies the starting character position of the selection.
            End:
                Specifies the ending character position of the selection.
    */
    SetEditSel(Start, End := "")
    {
        SendMessage(0xB1, Start, End==""?Start:End, this.GetEditControl())
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-setsel
    
    /*
        Gets the text that is displayed as the textual cue, or tip, in the edit control.
        Return value:
            Returns the text set as the textual cue.
        ErrorLevel:
            It is set to zero if successful, or nonzero otherwise.
    */
    GetCueBanner()
    {
        local Buffer
        VarSetCapacity(Buffer, 2*1024+2)
        ErrorLevel := !SendMessage(0x1502, &Buffer, 1024+1, this.GetEditControl())
        return ErrorLevel ? "" : StrGet(&Buffer,1024,"UTF-16")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-getcuebanner

    /*
        Sets the textual cue, or tip, that is displayed by the edit control to prompt the user for information.
        Parameters:
            Text:
                The text to display as the textual cue.
            Mode:
                TRUE if the cue banner should show even when the edit control has focus.
                FALSE is the default behavior, the cue banner disappears when the user clicks in the control.
        Return value:
            If the message succeeds, it returns TRUE. Otherwise it returns FALSE.
    */
    SetCueBanner(Text, Mode := 0)
    {
        return SendMessage(0x1501, !!Mode, &Text, this.GetEditControl())
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-setcuebanner

    /*
        Gets the number of indent spaces to display for the specified item.
        Return value:
            The return value is the item indent. If an error occurs, it is -1 (CB_ERR).
    */
    GetIndent(Item)
    {
        local COMBOBOXEXITEM
        VarSetCapacity(COMBOBOXEXITEM, A_PtrSize == 4 ? 36 : 56)
       ,NumPut(Item, NumPut(0x10,&COMBOBOXEXITEM,"UInt")+A_PtrSize-4, "Ptr")
       return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40D, "Ptr", 0, "Ptr", &COMBOBOXEXITEM, "Ptr")
            ? NumGet(&COMBOBOXEXITEM+3*A_PtrSize+16, "Int")
            : -1  ; CB_ERR.
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getitem

    /*
        Sets the number of indent spaces to display for the specified item.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetIndent(Item, Indent)
    {
        local COMBOBOXEXITEM
        VarSetCapacity(COMBOBOXEXITEM, A_PtrSize == 4 ? 36 : 56)
       ,NumPut(Indent, NumPut(Item,NumPut(0x10,&COMBOBOXEXITEM,"UInt")+A_PtrSize-4,"Ptr")+A_PtrSize+16, "Int")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", 0, "Ptr", &COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem

    /*
        Sets an image within the image list to the specified item.
        Return value:
            Returns nonzero if successful, or zero otherwise.
    */
    SetImage(Item, Image := "", SelImage := "", Overlay := "")
    {
        local COMBOBOXEXITEM
        VarSetCapacity(COMBOBOXEXITEM, A_PtrSize == 4 ? 36 : 56)
       ,NumPut(Overlay,NumPut(SelImage,NumPut(Image,NumPut(Item,NumPut((Image==""?0:2)|(SelImage==""?0:4)|(Overlay==""?0:8),&COMBOBOXEXITEM,"UInt")+A_PtrSize-4,"Ptr")+A_PtrSize+4,"Int"),"Int"),"Int")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", 0, "Ptr", &COMBOBOXEXITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem
    
    /*
        Gets the handle to an image list assigned to a ComboBoxEx control.
        Return value:
            Returns the handle to the image list assigned to the control if successful, or NULL otherwise.
    */
    GetImageList()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x403, "Ptr", 0, "Ptr", 0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getimagelist

    /*
        Sets an image list for a ComboBoxEx control.
        Parameters:
            ImageList:
                A handle to the image list to be set for the control.
        Return value:
            Returns the handle to the image list previously associated with the control, or returns NULL if no image list was previously set.
        Remarks:
            The height of images in your image list might change the size requirements of the ComboBoxEx control.
            It is recommended that you resize the control after sending this message to ensure that it is displayed properly.
    */
    SetImageList(ImageList)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x402, "Ptr", 0, "Ptr", ImageList, "UPtr")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775787.aspx

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
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x154, "Ptr", Component, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getitemheight

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
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x153, "Ptr", Component, "Ptr", Height, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-setitemheight

    /*
        Retrieves the zero-based index of the first visible item in the list box portion of this combo box.
        Initially, the item with index 0 is at the top of the list box, but if the list box contents have been scrolled, another item may be at the top.
        Return value:
            If the message is successful, the return value is the index of the first visible item in the list box of this combo box.
            If the message fails, the return value is -1 (CB_ERR).
    */
    GetTopIndex()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x15B, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-gettopindex

    /*
        Ensures that a particular item is visible in the list box of a combo box.
        The system scrolls the list box contents so that either the specified item appears at the top of the list box or the maximum scroll range has been reached.
        Parameters:
            Index:
                Specifies the zero-based index of the list item.
        Return value:
            If the message is successful, the return value is zero.
            If the message fails, the return value is -1 (CB_ERR).
    */
    SetTopIndex(Index)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x15C, "Ptr", Index, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-settopindex

    /*
        Retrieves the zero-based index of the item that matches the specified associated value.
        Parameters:
            Data:
                Specifies the value of type UPTR associated with the item.
            Start:
                Specifies the starting item index.
        Return value:
            Returns the zero-based index of the item, or -1 if the item cannot be found.
    */
    ItemFromData(Data, Start := 0)
    {
        loop ( this.GetCount() - Start )
            if ( DllCall("User32.dll\SendMessageW","Ptr",this.hWnd,"UInt",0x150,"Ptr",Start+A_Index-1,"Ptr",0,"UPtr") == Data )  ; GetItemData.
                return A_Index - 1
        return -1  ; CB_ERR.
    } ; GetCount + GetItemData

    /*
        Retrieves the application-supplied value associated with the specified item in the combo box.
        Parameters:
            Item:
                The zero-based index of the item.
        Return value:
            Returns the UPTR value associated with the item. If an error occurs, it is -1 (CB_ERR).
    */
    GetItemData(Item)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x150, "Ptr", 0, "Ptr",  0, "UPtr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getitemdata

    /*
        Sets the value associated with the specified item in a combo box.
        Parameters:
            Item:
                Specifies the item's zero-based index.
            Data:
                Specifies the new value of type UPTR to be associated with the item.
        Return value:
            If an error occurs, the return value is -1 (CB_ERR).
    */
    SetItemData(Item, Data)
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x151, "Ptr", Item, "Ptr", Data, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-setitemdata

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
        return ControlMove(,,, this.ctrl.pos.h+Rows*this.GetItemHeight()+2, this.GetComboControl())  ; CTRL_POS_HEIGHT+(ROWS*SINGLE_ITEM_HEIGHT)+BORDERS_PADDING_x1PX.
    }

    /*
        Retrieves the screen coordinates of this combo box in its dropped-down state.
        Return value:
            If the message succeeds, the return value is an object with the following keys: left, top, right and bottom.
            If the message fails, the return value is zero.
    */
    GetDroppedCtrlRect()
    {
        local RECT  ; https://msdn.microsoft.com/library/windows/desktop/dd162897.
        VarSetCapacity(RECT, 16)
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x152, "Ptr", 0, "Ptr", &RECT, "Ptr")
             ? { left:NumGet(&RECT,"Int"), top:NumGet(&RECT+4,"Int"), right:NumGet(&RECT+8,"Int"), bottom:NumGet(&RECT+12,"Int") }
             : 0
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-getdroppedcontrolrect

    /*
        Retrieves the client coordinates (relative to the GUI) of this combo box in its dropped-down state.
        Return value:
            If the message succeeds, the return value is an object with the following keys: X, Y, W and H.
            If the message fails, the return value is zero.
    */
    GetDroppedCtrlRect2()
    {
        local RECT  ; https://msdn.microsoft.com/library/windows/desktop/dd162897.
        VarSetCapacity(RECT, 16)
        local r := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x152, "Ptr", 0, "Ptr", &RECT, "Ptr")
            , o := { W:NumGet(&RECT+8,"Int")-NumGet(&RECT,"Int") , H:NumGet(&RECT+12,"Int")-NumGet(&RECT+4,"Int") }
        if ( r := r ? DllCall("User32.dll\ScreenToClient","Ptr",this.hGui,"Ptr",&RECT,"Int") : FALSE )
            o.X := NumGet(&RECT,"Int"), o.Y := NumGet(&RECT+4,"Int")
        return r ? o : 0
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-getdroppedcontrolrect | https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-screentoclient
    
    /*
        Determines whether the list box of a combo box is dropped down.
        Return value:
            If the list box is visible, the return value is TRUE; otherwise, it is FALSE.
    */
    GetDroppedState()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x157, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-getdroppedstate

    /*
        Shows or hides the list box of a combo box that has the CBS_DROPDOWN or CBS_DROPDOWNLIST style.
        Parameters:
            State:
                A value that specifies whether the drop-down list box is to be shown or hidden.
                -1    Toggle the current list box state.
                 0    Hide the list box. It can be any value evaluated as FALSE.
                 1    Show the list box. It can be any value evaluated as TRUE (except -1).
        Return value:
            If the message succeeds, the return value is the previous state (TRUE/FALSE).
            If the message fails, the return value is -1 (CB_ERR).
    */
    ShowDropDown(State := 1)
    {
        if ( !( WinGetStyle("ahk_id" . this.hWnd) & 0x2 ) )
            return -1 ; CB_ERR.
        local old_state := this.GetDroppedState()  ; Gets the current state.
        SendMessage(0x14F, State == -1 ? !old_state : !!State,, this)
        return old_state
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-showdropdown

    /*
        Gets the width, in pixels, that the list box can be scrolled horizontally (the scrollable width). This is applicable only if the list box has a horizontal scroll bar.
        Return value:
            The return value is the scrollable width, in pixels.
    */
    GetHorizontalExtent()
    {
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x15d, "Ptr", 0, "Ptr", 0, "Ptr")
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-gethorizontalextent

    /*
        Finds the zero-based item of the first element whose text matches the specified string.
        Parameters: 
            Text:
                The string that will be searched.
            Item:
                The zero-based item from which to start searching (inclusive).
                When the search reaches the end, it continues from the top to 'Item-1' (inclusive).
                This parameter can be an object with the keys Start and End, that specify the exact range in which to perform the search.
            Mode:
                Determines the behavior of the search. You can specify one or more of the following values.
                0 = Finds the item whose text exactly matches the specified string.
                1 = Finds the item whose text begins with the specified string.
                2 = Finds the item whose text coincides partially with the specified string.
                4 = Specifies a case-sensitive search.
        Return value:
            Returns the zero-based index of the matching item. -1 if the search has not been successful.
    */
    FindText(ByRef Text, Item := 0, Mode := 0)
    {
        local o := [isobject(Item)?Item:{start:Item,end:-1},strlen(Text)]
        loop ( this.GetCount() ) {
            if ( ( o[3] := A_Index - 1 ) < o[1].start )
                continue
            if ( o[3] == o[1].end )
                break
            if ( Mode & 2 ) {
                if ( InStr(this.GetText(o[3]),Text,Mode&4) )
                    return o[3]
            } else {
                if (  (Mode&4) && Text == this.GetText(o[3],Mode&1?o[2]:-1) )
                || ( !(Mode&4) && Text  = this.GetText(o[3],Mode&1?o[2]:-1) )
                    return o[3]
        }   } return isobject(Item) ? -1 : this.FindText(Text,{start:0,end:o[1].start},Mode)
    } ; GetText

    /*
        Finds the first list box string in a combo box that matches the string specified in the 'String' parameter.
        Parameters:
            String:
                The string that contains the characters for which to search.
                The search is not case sensitive, so this string can contain any combination of uppercase and lowercase letters.
            Item:
                The zero-based index of the item preceding the first item to be searched.
                When the search reaches the bottom of the list box, it continues from the top of the list box back to the item specified by the 'Item' parameter.
                If 'Item' is -1, the entire list box is searched from the beginning.
            Exact:
                By default, the search looks for an item beginning with the characters in the specified string.
                If set to TRUE, the search looks for an item that exactly matches the specified string.
        Return value:
            The return value is the zero-based index of the matching item. If the search is unsuccessful, it is -1 (CB_ERR).
    */
    ;FindString(ByRef String, Item := -1, Exact := FALSE)  ; It seems not to work.
    ;{
    ;    return Exact ? DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x158, "Ptr", Item, "Ptr", &String, "Ptr")
    ;                 : DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x14C, "Ptr", Item, "Ptr", &String, "Ptr")
    ;} ; https://docs.microsoft.com/en-us/windows/desktop/controls/cb-findstringexact | https://docs.microsoft.com/en-us/windows/desktop/controls/cb-findstring

    /*
        Gets the extended styles that are in use for this ComboBoxEx control.
        Return value:
            Returns a value that contains the ComboBoxEx control extended styles in use for the control.
    */
    GetExStyle()
    {
        return SendMessage(0x409,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/cbem-getextendedstyle

    /*
        Sets extended styles within this ComboBoxEx control.
        Parameters:
            Value:
                A value that contains the ComboBoxEx Control Extended Styles to set for the control.
            Mask:
                A value that indicates which styles in 'Value' are to be affected.
                Only the extended styles in 'Mask' will be changed.
                If this parameter is zero, then all of the styles in 'Value' will be affected.
        Return value:
            Returns a value that contains the extended styles previously used for the control.
        Remarks:
            'Mask' enables you to modify one or more extended styles without having to retrieve the existing styles first.
            For example, if you pass CBES_EX_NOEDITIMAGE for 'Mask' and 0 for lParam, the CBES_EX_NOEDITIMAGE style will be cleared, but all other styles will remain the same.
            If you try to set an extended style for a ComboBoxEx control created with the CBS_SIMPLE style, it may not repaint properly.
    */
    SetExStyle(Value, Mask := 0)
    {
        return SendMessage(0x40E, Mask, Value, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setextendedstyle

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
                Link: https://lexikos.github.io/v2/docs/objects/GuiOnCommand.htm.
        Remarks:
            The callback function receives a single parameter: the control object. To retrieve this ComboBoxEx object, use: 'CBEX := new ComboBoxEx(GuiCtrlObj)'.
    */
    OnEvent(EventName, Callback, AddRemove := 1)
    {
        loop parse, "SelChange|DoubleClick|Focus|LoseFocus|EditChange|EditUpdate|DropDown|CloseUp|SelEndOk|SelEndCancel", "|"
            if ( A_LoopField = EventName )
                return this.Ctrl.OnCommand(A_Index, Callback, AddRemove)
        throw Exception("ComboBoxEx class OnEvent method invalid parameter #1.", -1, "Invalid event name.")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-combobox-control-reference-notifications

    /*
        Allow or prevent changes in that control to be redrawn.
        Parameters:
            Mode:
                The redraw state.
                0 (FALSE)       The content cannot be redrawn after a change.
                1 (TRUE)        The content can be redrawn after a change.
    */
    SetRedraw(Mode)
    {
        this.ShowDropDown(0)
        SendMessage(0xB, !!Mode,, this)
        SendMessage(0xB, !!Mode,, this.GetEditControl())
        SendMessage(0xB, !!Mode,, this.GetComboControl())
        if ( Mode )
            DllCall("User32.dll\InvalidateRect", "Ptr", this.hWnd, "Ptr", 0, "Int", TRUE, "Int")
           ,DllCall("User32.dll\UpdateWindow", "Ptr", this.hWnd, "Int")
    } ; https://docs.microsoft.com/en-us/windows/desktop/gdi/wm-setredraw


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================    
    Text[Item := -1]
    {
        get {
            return this.GetText(Item == -1 ? this.GetEditControl() ? -1 : this.GetCurSel() : Item)
        }
        set {
            this.SetText(Item == -1 ? this.GetEditControl() ? -1 : this.GetCurSel() : Item, string(value))
            return value
        }
    }

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
            return hWnd == this.GetComboControl() ? 1 : hWnd == this.GetEditControl() ? 2 : hWnd == this.hWnd ? 3 : 0
        }
    }
}





ComboBoxEx_OnMessage(wParam, lParam, Msg, hWnd)
{
    global ComboBoxEx  ; Class.
    local

    if ( Msg == 0x02 )  ; WM_DESTROY.
    {
        for ctrl_hwnd, ctrl_obj in ComboBoxEx.Instance.Clone()
            if ( ctrl_obj.hGui == hWnd )
                ctrl_obj.Destroy()
    }
}
