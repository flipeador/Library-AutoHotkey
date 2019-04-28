/*
    Remarks:
        Item indexes are zero based.
    Tab Control Reference:
        https://docs.microsoft.com/en-us/windows/desktop/controls/tab-control-reference.
*/
class Tab
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Type         := "Tab"              ; The control type.
    static Instance     := { }                ; Instances of this control {ctrl_hwnd:ctrl_obj}.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Gui          := 0         ; Gui Object.
    Ctrl         := 0         ; Gui Control Object.
    hWnd         := 0         ; The HWND of the control.
    hGui         := 0         ; The HWND of the GUI.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Adds a Tab control to the specified GUI window.
        Parameters:
            Gui:
                The GUI window object.
                You can specify an existing Tab control HWND to retrieve the Tab control object.
    */
    __New(Gui, Options := "", Tabs*)
    {
        if (  Tab.Instance.HasKey( this.hGui := IsObject(Gui) ? Gui.hWnd : Gui )  )
            return Tab.Instance[ this.hGui ]

        if ( Type(this.Gui:=GuiFromHwnd(this.hGui)) !== "Gui" )
            throw Exception("Tab class invalid parameter #1.", -1, "Invalid GUI.")
        if ( Type(Options) !== "String" )
            throw Exception("Tab class invalid parameter #2.", -1, "Invalid data type.")

        if ( Tab.Instance.Count() == 0 )
            OnMessage(0x02, "Tab_OnMessage")  ; WM_DESTROY.

        this.Ctrl := this.Gui.AddTab3("-0x200 " . Options, Chr(21891))
        this.hWnd := this.Ctrl.hWnd
        Tab.Instance[this.hWnd] := this

        this.DeleteAll()
        loop Tabs.Length()
            this.Add(, String(Tabs[A_Index]))
        
        local Match
        if RegExMatch(Options, "i)\bchoose(\d+)\b", Match)
        {
            if Match[1] < 0 || Match[1] >= Tabs.Length()
                throw Exception("Tab class invalid parameter #2.", -1, "Invalid option value: ChooseN")
            this.Select( Match[1] )
        }
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Destroy()
    {
        Tab.Instance.Delete(this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd, "Int")

        if ( Tab.Instance.Count() == 0 )
            OnMessage(0x02, "Tab_OnMessage", 0)  ; WM_DESTROY.
    }

    /*
        Inserts a new tab in the tab control.
        Parameters:
            Item:
                Zero-based index of the new tab.
            Text:
                String that contains the tab text.
            Image:
                Index in the tab control's image list, or -1 if there is no image for the tab.
            State:
                The state value to be set for the new item.
            Data:
                Application-defined data associated with the tab control item.
        Return value:
            Returns the index of the new tab if successful, or -1 otherwise.
    */
    Add(Item := -1, Text := "", Image := -1, State := 0, Data := 0)
    {
        local TCITEM
        VarSetCapacity(TCITEM, A_PtrSize==4?28:40, 0)
        NumPut(Data,NumPut(Image,NumPut(&Text,NumPut(State,NumPut(0x1B,&TCITEM,"UInt"),"UInt")+A_PtrSize,"Ptr")+4+A_PtrSize,"Int"),"Ptr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133E
                                                , "Ptr", Item < 0 ? this.GetCount() : Item
                                                , "Ptr", &TCITEM, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-insertitem

    /*
        Removes an item from the tab control.
        Parameters:
            Item:
                Zero-based index of the item to delete.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    Delete(Item)
    {
        return SendMessage(0x1308, Item,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-deleteitem

    /*
        Removes all items from the tab control.
        Return value:
            Returns TRUE if successful, or FALSE otherwise.
    */
    DeleteAll()
    {
        return SendMessage(0x1309,,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-deleteallitems

    /*
        Retrieves the number of tabs in the tab control.
        Return value:
            Returns the number of items if successful, or zero otherwise.
    */
    GetCount()
    {
        return SendMessage(0x1304,,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitemcount

    /*
        Selects and sets the focus to a specified tab in the tab control.
        Parameters:
            Item:
                Zero-based index of the tab.
    */
    Select(Item)
    {
        this.DeselectAll()
        this.SetCurSel(Item)
        this.SetCurFocus(Item)
    }

    /*
        Resets items in the tab control, clearing any that were set to the TCIS_BUTTONPRESSED state.
        Parameters:
            Flag:
                Flag that specifies the scope of the item deselection.
                0  (FALSE)          All tab items will be reset.
                1  (TRUE)           All tab items except for the one currently selected will be reset.
    */
    DeselectAll(Flag := FALSE)
    {
        SendMessage(0x1332, !!Flag,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-deselectall

    /*
        Selects a tab in the tab control.
        Parameters:
            Item:
                Zero-based index of the tab to select.
        Return value:
            Returns the index of the previously selected tab if successful, or -1 otherwise.
    */
    SetCurSel(Item)
    {
        return SendMessage(0x130C, Item,, this) << 32 >> 32
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setcursel

    /*
        Sets the focus to a specified tab in the tab control.
        Parameters:
            Item:
                Zero-based index of the tab that gets the focus.
    */
    SetCurFocus(Item)
    {
        SendMessage(0x1330, Item,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setcurfocus
}





Tab_OnMessage(wParam, lParam, Msg, hWnd)
{
    global Tab
    local

    if ( Msg == 0x02 )  ; WM_DESTROY.
    {
        for ctrl_hwnd, ctrl_obj in Tab.Instance.Clone()
            if ( ctrl_obj.hGui == hWnd )
                ctrl_obj.Destroy()
    }
}
