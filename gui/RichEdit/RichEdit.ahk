; Clipboard := Format("0x{:X}", 0x0400+204)
#Include FormatRTF.ahk
#Include FindReplace.ahk





/*
    Remarks:
        Line numbers and character indexes are zero based.
    Some math conversion functions:
        https://github.com/flipeador/Library-AutoHotkey/tree/master/math.
    Special thanks to:
        just me    https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=148
        https://www.autohotkey.com/boards/viewtopic.php?f=6&t=681
*/
class RichEdit  ; WIN_V+
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Type        := "RichEdit"         ; The type of the control.
    static ClassName   := "RICHEDIT50W"      ; RichEdit 4.1.
    static DLL         := "Msftedit.dll"     ; RichEdit control DLL file.
    static Instance    := { }                ; Instances of this control {hwnd:ctrl_obj}.
    static hModule     := 0                  ; DLL Handle.
    static SubclassCB  := 0                  ; Callback function handling RichEdit messages.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Gui            := 0                          ; Gui Object.
    Ctrl           := 0                          ; Gui Control Object.
    hWnd           := 0                          ; The HWND of the control.
    hGui           := 0                          ; The HWND of the GUI.
    Encoding       := "UTF-16"                   ; Character encoding.
    UndoLimit      := 100                        ; Default number of actions that can stored in the undo queue.
    DefTabStops    := 15                         ; Default tab stops, in dialog template units.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Gui, Options := "", Text := "")
    {
        if (  RichEdit.Instance.HasKey( this.hGui := IsObject(Gui) ? Gui.hWnd : Gui )  )
            return RichEdit.Instance[ this.hGui ]

        if ( Type(this.Gui:=GuiFromHwnd(this.hGui)) !== "Gui" )
            throw Exception("RichEdit class invalid parameter #1.", -1)
        if ( Type(Options) !== "String" )
            throw Exception("RichEdit class invalid parameter #2.", -1)
        if ( Type(Text) !== "String" )
            throw Exception("RichEdit class invalid parameter #3.", -1)

        if ( RichEdit.Instance.Count() == 0 )
        {
            if ! ( RichEdit.hModule := DllCall("Kernel32.dll\LoadLibrary","Str",RichEdit.DLL,"UPtr") )
                throw Exception("RichEdit class LoadLibrary Error " . A_LastError . ".", -1)

            ; SUBCLASSPROC function pointer.
            ; https://msdn.microsoft.com/es-es/44e4cbe0-8252-4bcc-885e-d8af856e8ad7.
            RichEdit.SubclassCB := CallbackCreate("RichEdit.SubclassProc")

            ; To detect when the owner gui is destroyed.
            OnMessage(0x02, "RichEdit_OnMessage")  ; WM_DESTROY.
        }

        ; Window Styles (https://docs.microsoft.com/en-us/windows/desktop/winmsg/window-styles)
        ; Rich Edit Control Styles (https://docs.microsoft.com/en-us/windows/desktop/controls/rich-edit-control-styles)
        ;                WS_TABSTOP | WS_VISIBLE | WS_CHILD   | ES_AUTOHSCROLL | ES_NOHIDESEL | ES_SAVESEL | ES_WANTRETURN
        local   Style := 0x10000    | 0x10000000 | 0x40000000 | 0x80           | 0x0100       | 0x8000     | 0x1000
        ; Extended Window Styles (https://docs.microsoft.com/en-us/windows/desktop/winmsg/extended-window-styles)
        local ExStyle := 0

        if ( InStr(Options,"+Multi") )
        {
            Options := StrReplace(Options, "+Multi")
            ;        WS_HSCROLL | WS_VSCROLL | ES_MULTILINE | ES_AUTOVSCROLL
            Style |= 0x100000   | 0x200000   | 0x0004       |  0x40
        }

        if ( InStr(Options,"+ReadOnly") )                       ; ES_READONLY
            Options := StrReplace(Options, "+ReadOnly"), Style |= 0x0800
        if ( InStr(Options,"+Password") )                       ; ES_PASSWORD
            Options := StrReplace(Options, "+Password"), Style |= 0x0020
        if ( InStr(Options,"+Number") )                         ; ES_NUMBER
            Options := StrReplace(Options, "+Number"), Style |= 0x2000

        this.Ctrl := this.Gui.AddCustom("+" . Style . " +E" . ExStyle . A_Space . Options . " Class" . RichEdit.ClassName)
        this.hWnd := this.Ctrl.hWnd
        RichEdit.Instance[this.hWnd] := this

        this.SetLangOptions(1|2)
        this.SetTypographyOptions(1|8)
        this.SetStyle(2, 2)
        this.LimitText(-1)
        this.SetUndoLimit(this.UndoLimit)
        this.SetDefaultTabStops(this.DefTabStops)
        
        if ( Type(Text) !== "String" )
            throw Exception("__New invalid parameter #3.", -1, "RichEdit Class.")
        if ( Text !== "" )
            this.SetText(Text)

        ; https://docs.microsoft.com/en-us/windows/desktop/api/commctrl/nf-commctrl-setwindowsubclass
        ; The third parameter is simply an identifier, which identifies this callback.
        if ! DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", this.hWnd, "Ptr", RichEdit.SubclassCB, "Ptr", this.hWnd, "Ptr", 0, "Int")
            MsgBox("RichEdit Class SetWindowSubclass Error."), ExitApp()  ; Very rare.
    }
    

    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    SubclassProc(uMsg, wParam, lParam, uIdSubclass, dwRefData)
    {
        ; 0x87 WM_GETDLGCODE message  |  4 DLGC_WANTALLKEYS (all keyboard input)
        ; https://docs.microsoft.com/en-us/windows/desktop/dlgbox/wm-getdlgcode
        ; We can process WM_XXX messages (uMsg) right here, but better avoid it to return quickly and avoid hanging.
        return uMsg == 0x87 ? 4
                            ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nf-commctrl-defsubclassproc
                            : DllCall("Comctl32.dll\DefSubclassProc", "Ptr", this, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    } ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nf-commctrl-defsubclassproc


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Destroy()
    {
        RichEdit.Instance.Delete(this.hWnd)
        try CallbackFree( this.GetAutoCorrectProc() )
        ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nf-commctrl-removewindowsubclass
        if ! DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", this.hWnd, "Ptr", RichEdit.SubclassCB, "Ptr", this.hWnd, "Int")
            MsgBox("RichEdit Class RemoveWindowSubclass Error."), ExitApp()  ; Very rare.
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd, "Int")

        if ( RichEdit.Instance.Count() == 0 )
        {
            OnMessage(0x02, "RichEdit_OnMessage", 0)  ; WM_DESTROY.

            CallbackFree(RichEdit.SubclassCB)
            RichEdit.SubclassCB := 0

            DllCall("Kernel32.dll\FreeLibrary", "Ptr", RichEdit.hModule, "Int")
            RichEdit.hModule := 0
        }
    }

    SetLangOptions(Options)
    {
        return SendMessage(0x478,, Options, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setlangoptions

    /*
        Sets the current state of the typography options of a rich edit control.
        Parameters:
            Values:
                Specifies one or both of the following values.
                TO_ADVANCEDTYPOGRAPHY       0x0001
                TO_SIMPLELINEBREAK          0x0002
                TO_DISABLECUSTOMTEXTOUT     0x0004
                TO_ADVANCEDLAYOUT           0x0008
    */
    SetTypographyOptions(Values, Mask := "")
    {
        return SendMessage(0x4CA, Values, Mask==""?Values:Mask, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-settypographyoptions

    GetRect()
    {
        local RECT
        VarSetCapacity(RECT, 16), SendMessage(0xB2,, &RECT, this)
        return { left  : NumGet(&RECT   , "Int")
               , top   : NumGet(&RECT+4 , "Int")
               , right : NumGet(&RECT+8 , "Int")
               , bottom: NumGet(&RECT+12, "Int") }
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getrect

    SetRect(Rect, Relative := 0)
    {
        local _RECT, _ := [VarSetCapacity(_RECT,16),this.GetRect()]
        NumPut(Rect.HasKey("left")  ?Rect.left  :_[2].left  , &_RECT   , "Int")
       ,NumPut(Rect.HasKey("top")   ?Rect.top   :_[2].top   , &_RECT+4 , "Int")
       ,NumPut(Rect.HasKey("right") ?Rect.right :_[2].right , &_RECT+8 , "Int")
       ,NumPut(Rect.HasKey("bottom")?Rect.bottom:_[2].bottom, &_RECT+12, "Int")
        return SendMessage(0xB3, Relative, &_RECT, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setrect
    
    /*
        Sets the options for this rich edit control.
        Parameters:
            Options:
                Specifies one or more of the following values.
                ECO_AUTOWORDSELECTION      0x00000001
                ECO_AUTOVSCROLL            0x00000040
                ECO_AUTOHSCROLL            0x00000080
                ECO_NOHIDESEL              0x00000100
                ECO_READONLY               0x00000800
                ECO_WANTRETURN             0x00001000
                ECO_SAVESEL                0x00008000
                ECO_SELECTIONBAR           0x01000000
                ECO_VERTICAL               0x00400000   (FE specific)
            Operation:
                Specifies the operation, which can be one of these values.
                ECOOP_SET = 1, ECOOP_OR, ECOOP_AND, ECOOP_XOR.
        Return value:
            Returns the current options of the edit control.
    */
    SetOptions(Options, Operation := 2)
    {
        return SendMessage(0x44D, Operation, Options, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setoptions

    /*
        Retrieves rich edit control options.
        Return value:
            Returns a combination of the current option flag values described in the SetOptions method.
        Example to determine if the control is read-only:
            is_readonly := GetOptions() & 0x00000800  ; ECO_READONLY
    */
    GetOptions()
    {
        return SendMessage(0x44E,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getoptions

    /*
        Sets an upper limit to the amount of text the user can type or paste into a rich edit control.
        Parameters:
            Value:
                Specifies the maximum amount of text that can be entered.
                If this parameter is zero, the default maximum is used, which is 64K characters.
                A COM object counts as a single character.
    */
    LimitText(Value)
    {
        SendMessage(0x435,, Value, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-exlimittext

    /*
        Select a range of text from the specified line.
        Parameters:
            LineNum:
                The zero-based line number. A value of –1 specifies the current line number (the line that contains the caret).
            Start / End:
                The text range.
        Return value:
            The selection that is actually set.
    */
    SelectLine(LineNum := -1, Start := 0, End := -1)
    {
        local LineIndex := SendMessage(0xBB, LineNum,, this)
        return this.SetSelection(LineIndex+Start, End==-1?LineIndex+this.LineLength(LineIndex):LineIndex+End)
    } ; LineIndex + (LineLength) + SetSelection

    /*
        Gets the number of lines.
    */
    GetLineCount()
    {
        return SendMessage(0xBA,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getlinecount

    /*
        Get a range of text from the specified line.
        Parameters:
            LineNum:
                The zero-based line number. A value of –1 specifies the current line number (the line that contains the caret).
            Start / End:
                The text range.
    */
    GetLineText(LineNum := -1, Start := 0, End := -1)
    {
        local lnindex := SendMessage(0xBB, LineNum,, this)
        return this.GetTextRange( lnindex+Start, End==-1?lnindex+this.LineLength(lnindex):lnindex+End )
    } ; LineIndex + (LineLength) + GetTextRange

    /*
        Retrieves the length, in characters, of a line.
        Parameters:
            CharIndex:
                The character index of a character in the line whose length is to be retrieved.
                If this parameter is greater than the number of characters in the control, the return value is zero.
        Return value:
            For multiline edit controls, the return value is the number of characters of the specified line. It does not include the carriage-return character at the end of the line.
            For single-line edit controls, the return value is the number of characters of the whole text in the edit control.
        Example to retrieve the number of characters in the current line:
            num_chars := LineLength( LineIndex(-1) )   ; -1 can be replaced by the desired line number.
    */
    LineLength(CharIndex)
    {
        return SendMessage(0xC1, CharIndex,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-linelength

    /*
        Gets the character index of the first character of a specified line.
        A character index is the zero-based index of the character from the beginning of the edit control.
        Parameters:
            LineNumber:
                The zero-based line number. A value of –1 specifies the current line number (the line that contains the caret).
        Return value:
            The character index of the specified line, or it is –1 if the specified line number is greater than the number of lines in the edit control.
    */
    LineIndex(LineNumber := -1)
    {
        return SendMessage(0xBB, LineNumber,, this)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761611(v=vs.85).aspx

    /*
        Gets the length and the character index of the first and last character of a specified line.
        Returns an object with the keys: length, first and last.
    */
    LineIndex2(LineNumber := -1)
    {
        local obj  := { first: SendMessage(0xBB,LineNumber,,this) }
        obj.length := SendMessage(0xC1, obj.first,, this)
       ,obj.last   := obj.first + obj.length
        return obj
    } ; LineIndex + LineLength

    /*
        Determines which line contains the specified character.
        Parameters:
            CharIndex:
                Zero-based index of the character.
        Return value:
            Returns the zero-based index of the line.
    */
    LineFromChar(CharIndex)
    {
        return SendMessage(0x436,, CharIndex, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-exlinefromchar

    /*
        Retrieves the client area coordinates of a specified character in an edit control.
        Parameters:
            CharIndex:
                Zero-based index of the character.
        Return value:
            Returns an object with the keys X and Y.
    */
    PosFromChar(CharIndex)
    {
        local POINTL := 0
        SendMessage(0x00D6, &POINTL, CharIndex, this.wt)
        return { x:POINTL&0xFFFFFFFF, y:(POINTL>>32)&0xFFFFFFFF }
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-posfromchar

    /*
        Gets information about the character closest to a specified point in the client area of the control.
        Return value:
            The return value specifies the zero-based character index of the character nearest the specified point.
            The return value indicates the last character in the edit control if the specified point is beyond the last character in the control.
    */
    CharFromPos(X, Y)
    {
        local POINTL := ( X & 0xFFFFFFFF ) | ( ( Y & 0xFFFFFFFF ) << 32 ) 
        return SendMessage(0xD7,, &POINTL, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-charfrompos

    /*
        Gets the whole text of the line under the current cursor position.
    */
    GetCurText()
    {
        local curpos := this.GetCursorPos()
        return this.GetLineText( this.LineFromChar( this.CharFromPos(curpos.x,curpos.y) ) )
    }

    /*
        Retrieves the current coordinates of the cursor relative to the client area of ​​the control.
        Return value:
            Returns an object with the keys X and Y.
    */
    GetCursorPos()
    {
        local POINT := 0
        DllCall("User32.dll\GetCursorPos", "Int64P", POINT, "Int")
       ,DllCall("User32.dll\ScreenToClient", "UPtr", this.hWnd, "Int64P", POINT, "Int")
        return { x:POINT&0xFFFFFFFF, y:(POINT>>32)&0xFFFFFFFF }
    }

    /*
        Scrolls the caret into view.
    */
    ScrollCaret()
    {
        SendMessage(0xB7,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-scrollcaret

    /*
        Get the line number that contains the caret.
        Return value:
            Returns the zero-based index of the line.
        Note:
            To retrieve the current caret position, use the GetSelection method.
    */
    GetCaretLine()
    {
        return SendMessage(0x436,, SendMessage(0xBB,-1,,this), this)
    } ; LineIndex + LineFromChar

    /*
        Determines the selection type for this rich edit control.
        Return value:
            If the selection is empty, the return value is 0 (SEL_EMPTY).
            If the selection is not empty, the return value is a set of flags containing one or more of the following values.
            SEL_TEXT          1    Text.
            SEL_OBJECT        2    At least one COM object.
            SEL_MULTICHAR     4    More than one character of text.
            SEL_MULTIOBJECT   8    More than one COM object.
    */
    SelectionType()
    {
        return SendMessage(0x442,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-selectiontype

    /*
        Selects all the text in the control.
    */
    SelectAll()
    {
        return this.SetSelection( 0, this.GetTextLength() )
    }

    /*
        Selects the specified portion of text.
        Parameters / Return value:
            See the FindText method.
    */
    Select(ByRef Text, Min := 0, Max := -1, Mode := 5)
    {
        local r := this.FindText(Text, Min, Max, Mode)
        if ( r )
            this.SetSelection(r.min, r.max)
        return r
    } ; FindText + SetSelection

    Deselect()
    {
        return this.SetSelection( this.GetSelection().start )
    } ; GetSelection + SetSelection

    /*
        Selects a range of characters or Component Object Model (COM) objects in a Microsoft Rich Edit control.
        Parameters:
            Pos1:
                Character position index immediately preceding the first character in the range.
            Pos2:
                Character position immediately following the last character in the range.
                If an empty string is specified, the caret is inserted at Pos1 without selecting anything.
        Return value:
            The selection that is actually set.
    */
    SetSelection(Pos1, Pos2 := "", Reverse := FALSE)
    {
        local CHARRANGE := ( ( Reverse ? ( Pos1 := this.GetTextLength() - Pos1 ) : Pos1 ) & 0xFFFFFFFF )
                         | ( ( ( Pos2 == "" ? Pos1 : Reverse ? this.GetTextLength() - Pos2 : Pos2 ) & 0xFFFFFFFF ) << 32 )
        return SendMessage(0x437,, &CHARRANGE, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-exsetsel

    /*
        Retrieves the starting and ending character positions of the selection in a rich edit control.
        Return value:
            Returns an object containing the keys Start (start of selection) and End (end of selection).
    */
    GetSelection()
    {
        local CHARRANGE := 0
        SendMessage(0x434,, &CHARRANGE, this)
        return { start:CHARRANGE&0xFFFFFFFF, end:(CHARRANGE>>32)&0xFFFFFFFF }
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-exgetsel

    /*
        Retrieves the currently selected text in a rich edit control.
    */
    GetSelText()
    {
        local CHARRANGE := 0, Buffer
        SendMessage(0x434,, &CHARRANGE, this)  ; GetSelection.
       ,VarSetCapacity(Buffer, 2*(((CHARRANGE>>32)&0xFFFFFFFF)-(CHARRANGE&0xFFFFFFFF))+2, 0)
       ,SendMessage(0x43E,, &Buffer, this)
       ,VarSetCapacity(Buffer, -1)
        return Buffer
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getseltext

    /*
        Calculates the selected text length, in characters.
    */
    GetSelTextLen()
    {
        local CHARRANGE := 0
        SendMessage(0x434,, &CHARRANGE, this)
        return ( ( CHARRANGE >> 32 ) & 0xFFFFFFFF ) - ( CHARRANGE & 0xFFFFFFFF )
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-exgetsel

    /*
        Gets the text from a rich edit control.
        Parameters:
            Length:
                The number of bytes to retrieve. If a value less than zero is specified, the whole text is retrieved.
                Note that you must include the null termination character (+2).
            Mode:
                Value specifying a text operation. This member can be one of the following values.
                GT_DEFAULT        0    (All text is retrieved according to the following criteria: Carriage returns are not translated into CRLF. Table and math-object structure characters are removed. Hidden text is included. List numbers are not included.)
                GT_USECRLF        1    (When copying text, translate each CR into a CR/LF.)
                GT_SELECTION      2    (Retrieve the text for the current selection.)
                GT_RAWTEXT        4    (Text is retrieved exactly as it appears in memory.)
                GT_NOHIDDENTEXT   8    (Hidden text is not included in the retrieved text.)
        Example to retrieve the first 3 characters of the selected text:
            GetText(3*2+2, 2)    ; Specify a negative number in the first parameter to retrieve the whole selected text.
        Remarks:
            If you need the whole selected text, use the GetSelText method instead.
    */
    GetText(Length := -1, Mode := 0)
    {
        if ( ( Length := Length < 0 ? 2 * ( Mode & 2 ? this.GetSelTextLen() : this.GetTextLength() ) + 2 : Length ) < 3 )  ; Is GetTextLength/GetSelTextLen valid for GT_RAWTEXT?.
            return ""
        local GETTEXTEX, Buffer
        VarSetCapacity(GETTEXTEX, 8+3*A_PtrSize, 0*VarSetCapacity(Buffer,Length,0))
       ,NumPut(1200, NumPut((Length&0xFFFFFFFF)|((Mode&0xFFFFFFFF)<<32),&GETTEXTEX,"Int64"), "UInt")
       ,VarSetCapacity(Buffer, 0*SendMessage(0x45E,&GETTEXTEX,&Buffer,this)-1)
        return Buffer
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-gettextex

    /*
        Retrieves a specified range of characters from a rich edit control.
        Parameters:
            Min:
                Character position index immediately preceding the first character in the range.
            Max:
                Character position immediately following the last character in the range.
        Remarks:
            If you use this method to retrieve text in the range of a friendly hyperlink, the recovered text may not be the desired one, in which case you can use StreamOut(0x8011).
    */
    GetTextRange(Min, Max)
    {
        local TEXTRANGE, Buffer
        VarSetCapacity(TEXTRANGE, 8+A_PtrSize, 0), VarSetCapacity(Buffer, 2*(Max-Min)+2, 0)
       ,SendMessage(0x44B, NumPut(&Buffer,NumPut((Min&0xFFFFFFFF)|((Max&0xFFFFFFFF)<<32),&TEXTRANGE,"Int64"),"UPtr"), &TEXTRANGE, this)
       ,VarSetCapacity(Buffer, -1)
        return Buffer
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-gettextrange

    /*
        Calculates text length in various ways.
        Parameters:
            Mode:
                Value specifying the method to be used in determining the text length. This member can be one or more of the following values (some values are mutually exclusive).
                GTL_USECRLF    1      (Computes the answer by using CR/LFs at the end of paragraphs.)
                GTL_PRECISE    2      (Computes a precise answer. This approach could necessitate a conversion and thereby take longer.)
                GTL_CLOSE      4      (Computes an approximate (close) answer. It is obtained quickly and can be used to set the buffer size.)
                GTL_NUMCHARS   8      (Returns the number of characters.)
                GTL_NUMBYTES   16     (Returns the number of bytes.)
    */
    GetTextLength(Mode := 0)
    {
        local GETTEXTLENGTHEX := ( Mode & 0xFFFFFFFF ) | ( ( 1200 & 0xFFFFFFFF ) << 32 )
        return SendMessage(0x45F, &GETTEXTLENGTHEX,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-gettextlengthex

    /*
        Replaces the selection or the whole content of the control.
        Parameters:
            Text:
                The text to insert.
                If the text starts with a valid RTF ASCII sequence ('{\rtf' or '{urtf') the text is read in using the RTF reader.
            Mode:
                Option flags. It can be any reasonable combination of the following flags.
                ST_DEFAULT     0    (Deletes the undo stack, discards rich-text formatting, replaces all text.)
                ST_KEEPUNDO    1    (Keeps the undo stack.)
                ST_SELECTION   2    (Replaces selection and keeps rich-text formatting.)
                ST_NEWCHARS    4    (Act as if new characters are being entered.)
        Return value:
            If the operation is setting all of the text and succeeds, the return value is 1.
            If the operation is setting the selection and succeeds, the return value is the number of bytes or characters copied.
            If the operation fails, the return value is zero.
    */
    SetText(ByRef Text, Mode := 0)
    {
        local IsRTF := Text ~= "^\{\\rtf" || Text ~= "^\{urtf", pBuffer := &Text
        local SETTEXTEX := ( Mode & 0xFFFFFFFF ) | ( ( ( IsRTF?0:1200 ) & 0xFFFFFFFF ) << 32 )
        if ( IsRTF )  ; RTF formatted text has to be passed as ANSI.
            local Buffer, _ := VarSetCapacity(Buffer,StrPut(Text,"CP0"),0) . StrPut(Text,pBuffer:=&Buffer,"CP0")
        return SendMessage(0x461, &SETTEXTEX, pBuffer, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-settextex

    /*
        Replaces the whole content of the control with the specified plain text (ignores RTF format). See the remarks of the SetText method.
        Parameters:
            Text:
                The plain texto to insert. The inserted text will not be formatted.
                This parameter can be a pointer to a null terminated string.
    */
    SetPlainText(ByRef Text)
    {
        if ( !( Type(Text) ~= "i)integer|string") )
            throw Exception("SetPlainText method invalid parameter #1.", -1, "RichEdit Class.")
        return SendMessage(0xC,, type(Text)="integer"?Text:&Text, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/winmsg/wm-settext

    /*
        Set text in a specific range of characters from a rich edit control.
        Parameters:
            Min:
                Character position index immediately preceding the first character in the range.
            Max:
                Character position immediately following the last character in the range.
            Mode:
                Option flags. It can be any combination of the following flags.
                ST_KEEPUNDO    1    (Keeps the undo stack.)
                ST_NEWCHARS    4    (Act as if new characters are being entered.)
    */
    SetTextRange(ByRef Text, Min, Max := "", Mode := 0)
    {
        local sel := this.GetSelection(), sbpos := this.GetScrollPos()
        this.SetSelection(Min, Max), this.SetText(Text, 2|Mode)
       ,this.SetSelection(sel.start, sel.end), this.SetScrollPos(sbpos.x, sbpos.y)
    }

    /*
        Replaces the selected text with the specified text.
        Parameters:
            Text:
                The replacement text.
            CanUndo:
                Specifies whether the replacement operation can be undone.
                If this is TRUE, the operation can be undone. If this is FALSE, the operation cannot be undone.
            Select:
                Specifies whether the replacement operation should select the inserted text.
        Note:
            This is equivalent to calling method SetText, mode 2 (ST_SELECTION).
        Return value:
            Returns the number un caracters that has been inserted.
    */
    ReplaceSel(ByRef Text, CanUndo := FALSE, Select := FALSE)
    {
        local len := SendMessage(0xC2, CanUndo, &Text, this)
        if ( Select )
            this.SetSelection(this.GetSelection().start-len, this.GetSelection().start)
        return len
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-replacesel

    /*
        Hides or shows the selection in a rich edit control.
        Parameters:
            Mode:
                Value specifying whether to hide or show the selection.
                If this parameter is zero, the selection is shown. Otherwise, the selection is hidden.
    */
    HideSelection(Mode)
    {
        SendMessage(0x043F, Mode,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-hideselection

    /*
        Turn wordwrapping on/off.
    */
    WordWrap(Mode)
    {
        return SendMessage(0x448,, Mode?0:-1, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-settargetdevice

    GetScrollPos()
    {
        local POINT := 0
        SendMessage(0x4DD,, &POINT, this)
        return { x:POINT&0xFFFFFFFF, y:(POINT>>32)&0xFFFFFFFF }
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getscrollpos

    SetScrollPos(X, Y)
    {
        local POINT := ( X & 0xFFFFFFFF ) | ( ( Y & 0xFFFFFFFF ) << 32 ) 
        SendMessage(0x4DE,, &POINT, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setscrollpos

    ShowScrollBar(SB, Show := TRUE)
    {
        ; 1 = SB_VERT  |  0 = SB_HORZ
        SendMessage(0x460, SB, Show, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-showscrollbar

    /*
        Sets the zoom ratio for a multiline rich edit control.
        Parameters:
            Ratio:
                A value between 1 and 6400. A value of 0 restores the zoom.
        Return value:
            Returns the current zoom if it succeeded, or zero otherwise.
    */
    SetZoom(Ratio)
    {
        return SendMessage(0x4E1, Ratio, 100, this) ? Ratio : 0
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setzoom
    
    /*
        Gets the current zoom ratio for a multiline rich edit control. The zoom ration is always between 1 and 6400.
        Return value:
            Returns the zoom ratio in percent. 100 is the normal zoom.
    */
    GetZoom()
    {
        local Numerator := 0, Denominator := 0
        local R := SendMessage(0x4E0, &Numerator, &Denominator, this)
        return !Numerator || !Denominator ? 100 : Round(Numerator / Denominator * 100)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getzoom

    /*
        Sets the background color for this rich edit control.
        Parameters:
            Color:
                The RGB Color value. A value of -1 restores the original color.
        Return value:
            Returns the previous background color (RGB).
    */
    SetBkgndColor(Color)
    {
        Color := SendMessage(0x443, Color==-1?1:0, ((Color&0xFF0000)>>16)+(Color&0xFF00)+((Color&0xFF)<<16), this)
        return ((Color & 0xFF0000) >> 16) + (Color & 0x00FF00) + ((Color & 0x0000FF) << 16)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setbkgndcolor

    /*
        Gets the background color for this rich edit control.
    */
    GetBkgndColor()
    {
        local Color := this.SetBkgndColor(0)
        return this.SetBkgndColor( Color ) * 0 + Color
    }

    /*
        Enables or disables automatic detection of hyperlinks by a rich edit control.
        Parameters:
            Mode:
                Specify 0 to disable automatic link detection, or one of the following values to enable various kinds of detection.
                AURL_ENABLEURL              1   (Windows 8: Recognize URLs that include the path.)
                AURL_ENABLEEMAILADDR        2   (Windows 8: Recognize email addresses.)
                AURL_ENABLETELNO            4   (Windows 8: Recognize telephone numbers.)
                AURL_ENABLEEAURLS           8   (Recognize URLs that contain East Asian characters.)
                AURL_ENABLEDRIVELETTERS    16   (Windows 8: Recognize file names that have a leading drive specification, such as c:\temp.)
                AURL_DISABLEMIXEDLGC       32   (Windows 8: Disable recognition of domain names that contain labels with characters belonging to more than one of the following scripts: Latin, Greek, and Cyrillic.)
        Remarks:
            When auto URL detection is on, Microsoft Rich Edit is constantly checking typed text for a valid URL.
            Rich Edit recognizes URLs that start with these prefixes: http, file, mailto, ftp, https, gopher, nntp, prospero, telnet, news, wais, outlook.
            Rich Edit also recognizes standard path names that start with \\. When Rich Edit locates a URL, it changes the URL text color, underlines the text, and notifies the client using EN_LINK.
    */
    AutoURL(Mode, lParam := 0)
    {
        return SendMessage(0x45B, Mode, lParam, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-autourldetect

    /*
        Indicates whether the auto URL detection is turned on in the rich edit control.
        Return value:
            If auto-URL detection is active, the return value is 1. If auto-URL detection is inactive, the return value is 0.
    */
    GetAutoURL()
    {
        return SendMessage(0x45C,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getautourldetect

    /*
        Undoes the last edit control operation in the control's undo queue.
    */
    Undo()
    {
        return SendMessage(0xC7,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-undo

    /*
        Redo the next action in the control's redo queue.
    */
    Redo()
    {
        return SendMessage(0x454,,, this)
    } ; https://msdn.microsoft.com/en-us/data/bb774218(v=vs.71)

    /*
        Copy the current content of the clipboard to the edit control at the current caret position.
        Data is inserted only if the clipboard contains data in CF_TEXT format.
    */
    Paste()
    {
        return SendMessage(0x302,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/dataxchg/wm-paste

    /*
        Delete (cut) the current selection, if any, in the edit control and copy the deleted text to the clipboard in CF_TEXT format.
    */
    Cut()
    {
        return SendMessage(0x300,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/dataxchg/wm-cut

    /*
        Copy the current selection to the clipboard in CF_TEXT format.
    */
    Copy()
    {
        return SendMessage(0x301,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/dataxchg/wm-copy

    /*
        Delete (clear) the current selection, if any, from the edit control.
    */
    Clear()
    {
        return SendMessage(0x303,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/dataxchg/wm-clear

    /*
        Determines whether there are any actions in the control redo queue.
    */
    CanRedo()
    {
        return SendMessage(0x455,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-canredo

    /*
        Determines whether there are any actions in an edit control's undo queue.
    */
    CanUndo()
    {
        return SendMessage(0xC6,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-canundo

    /*
        Clears the undo queue and returns the current number of actions that can stored.
    */
    ClearUndo()
    {
        return this.SetUndoLimit(SendMessage(0x452,,,this)+this.UndoLimit)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setundolimit

    /*
        Sets the maximum number of actions that can stored in the undo queue of a rich edit control.
        Parameters:
            Value:
                Specifies the maximum number of actions that can be stored in the undo queue. Setting the limit to zero disables the Undo feature.
        Return value:
            The return value is the new maximum number of undo actions for the rich edit control. This value may be less than 'Value' if memory is limited.
        Remarks:
            By default, the maximum number of actions in the undo queue is 100.
            If you increase this number, there must be enough available memory to accommodate the new number.
            For better performance, set the limit to the smallest possible value.
    */
    SetUndoLimit(Value)
    {
        return this.UndoLimit := SendMessage(0x452, Value,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setundolimit

    /*
        Retrieves the type of the next undo action, if any.
        Return value:
            If there is an undo action, the value returned is an UNDONAMEID enumeration value that indicates the type of the next action in the control's undo queue.
            If there are no actions that can be undone or the type of the next undo action is unknown, the return value is zero.
            UID_UNKNOWN = 0, UID_TYPING, UID_DELETE, UID_DRAGDROP, UID_CUT, UID_PASTE, UID_AUTOTABLE
    */
    GetUndoName()
    {
        return SendMessage(0x456,,, this)
    }

    /*
        Stops a rich edit control from collecting additional typing actions into the current undo action. The control stores the next typing action, if any, into a new action in the undo queue.
        Remarks:
            A rich edit control groups consecutive typing actions, including characters deleted by using the BackSpace key, into a single undo action until one of the following events occurs:
            - The control receives an EM_STOPGROUPTYPING message.
            - The control loses focus.
            - The user moves the current selection, either by using the arrow keys or by clicking the mouse.
            - The user presses the Delete key.
            - The user performs any other action, such as a paste operation that does not involve typing.
            You can send the EM_STOPGROUPTYPING message to break consecutive typing actions into smaller undo groups. For example, you could send EM_STOPGROUPTYPING after each character or at each word break.
    */
    StopGroupTyping()
    {
        SendMessage(0x458,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-stopgrouptyping

    /*
        Sets the current edit style flags for this rich edit control.
        Return value:
            The return value is the state of the edit style flags after the rich edit control has attempted to implement your edit style changes.
            The edit style flags are a set of flags that indicate the current edit style.
    */
    SetStyle(Flags, Mask)
    {
        return SendMessage(0x4CC, Flags, Mask, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-seteditstyle

    /*
        Retrieves the current edit style flags.
    */
    GetStyle()
    {
        return SendMessage(0x4CD,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-geteditstyle

    Send(Keys)
    {
        ControlSend(Keys, this)
    }

    /*
        Finds Unicode text within a rich edit control.
        Parameters:
            Text:
                The null terminated string to find.
            Mode:
                Specifies the parameters of the search operation. This parameter can be one or more of the following values.
                FR_DOWN            0x00000001 (The operation searches from the end of the current selection to the end of the document. If not set, the operation searches from the end of the current selection to the beginning of the document.)
                FR_WHOLEWORD       0x00000002 (The operation searches only for whole words that match the search string. If not set, the operation also searches for word fragments that match the search string.)
                FR_MATCHCASE       0x00000004 (the search operation is case-sensitive. If not set, the search operation is case-insensitive.)
                FR_MATCHDIAC       0x20000000 (By default, Arabic and Hebrew diacritical marks are ignored. Set this flag if you want the search operation to consider diacritical marks.)
                FR_MATCHKASHIDA    0x40000000 (By default, Arabic and Hebrew kashidas are ignored. Set this flag if you want the search operation to consider kashidas.)
                FR_MATCHALEFHAMZA  0x80000000 (By default, Arabic and Hebrew alefs with different accents are all matched by the alef character. Set this flag if you want the search to differentiate between alefs with different accents.)
            Min / Max:
                The range of characters to search. To search forward (FR_DOWN) in the entire control, set Min to 0 and Max to -1.
                The Min parameter always specifies the starting-point of the search, and Max specifies the end point.
                When searching backward (default), Min must be equal to or greater than Max.
                When searching forward, a value of -1 in Max extends the search range to the end of the text.
        Return value:
            If the target string is found, the return value is an object with the keys Min and Max.
            If the target is not found, the return value is zero.
        Example to search and select all 'Hello' words one by one:
            match := { min: -1 }    ; Starting point (match.min+1).
            while ( match := FindText("Hello", match.min+1, -1, 1|4) )  ; -1 means to the end. 1 means FR_DOWN. 4 means FR_MATCHCASE.
                SetSelection( match.min, match.max ), ScrollCaret()
                ,ToolTip("Match found at (" . match.min . ";" . match.max . ")")
                ,SetTimer("ToolTip", -1500), Sleep(1000)
    */
    FindText(ByRef Text, Min, Max, Mode := 0)
    {
        local FINDTEXTEX, _ := VarSetCapacity(FINDTEXTEX, 16 + A_PtrSize)
        NumPut((Min&0xFFFFFFFF)|((Max&0xFFFFFFFF)<<32), &FINDTEXTEX, "Int64")
       ,SendMessage(0*NumPut(&Text,&FINDTEXTEX+8,"UPtr")+0x47C, Mode, &FINDTEXTEX, this)
       ,_ := { min:NumGet(&FINDTEXTEX+8+A_PtrSize,"Int"), max:NumGet(&FINDTEXTEX+12+A_PtrSize,"Int") }
        return _.min == -1 && _.max == -1 ? 0 : _
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-findtextex

    /*
        Finds the next word break before or after the specified character position or retrieves information about the character at that position.
        Parameters:
            CharIndex:
                Zero-based character starting position.
            Mode:
                Specifies the find operation. This parameter can be one of the following values.
                WB_LEFT            0  (Finds the nearest character before the specified position that begins a word.)
                WB_RIGHT           1  (Finds the next character that begins a word after the specified position.)
                WB_ISDELIMITER     2  (Returns TRUE if the character at the specified position is a delimiter, or FALSE otherwise.)
                WB_CLASSIFY        3  (Returns the character class and word-break flags of the character at the specified position.)
                WB_MOVEWORDLEFT    4  (Finds the next character that begins a word before the specified position. This value is used during CTRL+LEFT ARROW key processing. This value is the similar to WB_MOVEWORDPREV)
                WB_MOVEWORDRIGHT   5  (Finds the next character that begins a word after the specified position. This value is used during CTRL+right key processing. This value is similar to WB_MOVEWORDNEXT)
                WB_LEFTBREAK       6  (Finds the next word end before the specified position. This value is the same as WB_PREVBREAK.)
                WB_RIGHTBREAK      7  (Finds the next end-of-word delimiter after the specified position. This value is the same as WB_NEXTBREAK.)
        Return value:
            The message returns a value based on the Mode parameter.
            WB_CLASSIFY       Returns the character class and word-break flags of the character at the specified position.
            WB_ISDELIMITER    Returns TRUE if the character at the specified position is a delimiter; otherwise it returns FALSE.
            Others            Returns the character index of the word break.
    */
    FindWordBreak(CharIndex, Mode := 0)
    {
        return SendMessage(0x44C, Mode, CharIndex, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-findwordbreak

    /*
        Sets character formatting in a rich edit control.
        Parameters:
            Options:
                Specify a string with the character format options. Specify the '-' prefix to disable the effect.
                You can specify the object returned by the SetFont method instead.
                Normal     = Restore the format effects (bold,protected,italic,strike,underline,subscript,superscript).
                sN         = The font size, in points.
                oN         = Character offset, in twips, from the baseline. If positive, the character is a superscript; if it is negative, the character is a subscript.
                cN         = The text color. Hexadecimal value without prefix. If it is Auto, the text color is the return value of GetSysColor(COLOR_WINDOWTEXT).
                csN        = Character set value. 1 = DEFAULT_CHARSET, 2 = SYMBOL_CHARSET.
                wN         = The weight of the font in the range 0 through 1000. For example, 400 is normal and 700 is bold. If this value is zero, a default weight is used.
                bcN        = Background color. Hexadecimal value without prefix. If it is Auto, the text color is the return value of GetSysColor(COLOR_WINDOW).
                UnderlineN = Specifies the underline type. The value is optional. You must specify a underline type to activate the underline color. This can be one of the following values.
                    CFU_UNDERLINENONE        0  (No underline. This is the default.)
                    CFU_UNDERLINE            1  (Text underlined with a single solid line.)
                    CFU_UNDERLINEWORD        2  (Underline words only. The rich edit control displays the text with a solid underline.)
                    CFU_UNDERLINEDOUBLE      3  (Text underlined with a double line. The rich edit control displays the text with a solid underline.)
                    CFU_UNDERLINEDOTTED      4  (Text underlined with a dotted line.)
                    CFU_UNDERLINEDASH        5  (Text underlined with dashes.)
                    CFU_UNDERLINEDASHDOT     6  (Text underlined with a dashed and dotted line.)
                    CFU_UNDERLINEDASHDOTDOT  7  (Text underlined with a dashed and doubled dotted line.)
                    CFU_UNDERLINEWAVE        8  (Text underlined with a wavy line.)
                ucN                   = The underline color. Hexadecimal value without prefix. This should be an 8-bit color value.
                Bold/Italic/Strike    = Characters are bold/italic/struck.
                Protected             = Characters are protected; an attempt to modify them will cause an EN_PROTECTED (0x704) notification code.
                SubScript/SuperScript = Character are subscript/superscript.
                Disabled              = Characters are displayed with a shadow that is offset by 3/4 point or one pixel, whichever is larger.
                Shadow                = Characters are displayed with shading.
                Hidden                = Characters are marked as hidden.
                Revised/Smallcaps/Allcaps/Outline/Emboss/Imprint/raN/pnfN = Others.
            FontFace:
                The font name. It must be a string of no more than 32 characters.
                If you leave this parameter empty, the font face is not modified.
                If 'Options' is an object, this parameter overwrites the font in the object.
            Mode:
                Character formatting that applies to the control. If this parameter is zero, the default character format is set. Otherwise, it can be one of the following values.
                SCF_DEFAULT           0x0000  (Sets the default font for the control.)
                SCF_SELECTION         0x0001  (Applies the formatting to the current selection. If the selection is empty, the character formatting is applied to the insertion point, and the new character format is in effect only until the insertion point changes.)
                SCF_WORD              0x0002  (Applies the formatting to the selected word or words. If the selection is empty but the insertion point is inside a word, the formatting is applied to the word. The SCF_WORD value must be used in conjunction with the SCF_SELECTION value.)
                SPF_DONTSETDEFAULT    0x0002  (Prevents setting the default paragraph format when the rich edit control is empty.)
                SCF_ALL               0x0004  (Applies the formatting to all text in the control. Not valid with SCF_SELECTION or SCF_WORD.)
                SPF_SETDEFAULT        0x0004  (Sets the default paragraph formatting attributes.)
                SCF_USEUIRULES        0x0008  (Used with SCF_SELECTION. Indicates that format came from a toolbar or other UI tool, so UI formatting rules should be used instead of literal formatting.)
                SCF_ASSOCIATEFONT     0x0010  (Associates a font to a given script, thus changing the default font for that script.)
                SCF_NOKBUPDATE        0x0020  (Prevents keyboard switching to match the font. For example, if an Arabic font is set, normally the automatic keyboard feature for Bidi languages changes the keyboard to an Arabic keyboard.)
                SCF_ASSOCIATEFONT2    0x0040  (Associates a surrogate (plane-2) font to a given script, thus changing the default font for that script.)
                SCF_SMARTFONT         0x0080  (Apply the font only if it can handle script.)
                SCF_CHARREPFROMLCID   0x0100  (Gets the character repertoire from the LCID.)
        Return value:
            If the operation succeeds, the return value is a nonzero value. If the operation fails, the return value is zero.
        Remarks:
            The FontFace and CharSet options may be overruled when invalid for characters, for example: Arial on kanji characters.
            Use SetFont("-Underline0") to remove the underline effect.
        Example to underline the whole text with red color:
            SetFont("Underline1 uc06")   ; 06 = 0x06 (8-bit color value). 1 = CFU_UNDERLINE. uc = Underline color.
    */
    SetFont(Options := "", FontFace := "", Mode := 0)
    {
        if ( IsObject(Options) )  ; Formats the object to a string.
        {
            local opt := "", p := ""
            Loop Parse, "s.size|o.offset|c.color|cs.charset|pnf.pichnfamily|w.weight|bc.bcolor|underline.utype|ra.revauthor|uc.ucolor", "|"
                opt .= (p:=StrSplit(A_LoopField,"."))[1] . ( p[1]="c"||p[1]="bc"||p[1]="uc"?(Options[p[2]]="auto"?"auto":Format("{:X}",Options[p[2]])):Options[p[2]] ) . A_Space
            Loop Parse, "bold|italic|underline|strike|protected|smallcaps|allcaps|hidden|outline|shadow|emboss|imprint|disabled|revised|subcript|superscript", "|"
                opt .= ( Options[A_LoopField] ? "" : "-" ) . A_LoopField . A_Space
            FontFace := FontFace == "" ? Options.name : FontFace, Options := opt
        }

        local CHARFORMAT2, _ := VarSetCapacity(CHARFORMAT2, 116, 0)
        local effects := (RegExMatch(Options,"i)\bcAuto\b")?0x40000000:0) | (InStr(Options,"bcAuto")?0x04000000:0)
        local mask := effects | (InStr(Options,"Normal")?0x3001F:0)

        if ( Type(FontFace) !== "String" || StrLen(FontFace) > 32 )
            throw Exception("SetFont method invalid parameter #2.", -1, "RichEdit Class.")

        if ( RegExMatch(Options, "i)\bs([\d]+)(p*)",_) )  ; CFM_SIZE
            mask |= 0x80000000, NumPut(_[1]*20, &CHARFORMAT2+12, "Int")  ; CHARFORMAT.yHeight
        if ( RegExMatch(Options, "i)\bo([\-\d]+)(p*)",_) )  ; CFM_OFFSET
            mask |= 0x10000000, NumPut(_[1], &CHARFORMAT2+16, "Int")  ; CHARFORMAT.yOffset
        if ( RegExMatch(Options, "i)\bc(&\d+|[\da-f]+)\b",_) && ( _ := ["0x" . _[1]] ) )  ; CFM_COLOR
            mask |= 0x40000000, NumPut(((_[1]&0xFF0000)>>16)+(_[1]&0xFF00)+((_[1]&0xFF)<<16), &CHARFORMAT2+20, "UInt")  ; CHARFORMAT.crTextColor
        if ( RegExMatch(Options, "i)\bcs([\d]+)(p*)",_) )  ; CFM_CHARSET
            mask |= 0x08000000, NumPut(_[1], &CHARFORMAT2+24, "UChar")  ; CHARFORMAT.bCharSet
        if ( RegExMatch(Options, "i)\bpnf([\d]+)(p*)",_) )
            mask |= 0x00000000, NumPut(_[1], &CHARFORMAT2+25, "UChar")  ; CHARFORMAT.bPitchAndFamily
        if ( FontFace !== "" )  ; CFM_FACE
            mask |= 0x20000000, StrPut(FontFace, &CHARFORMAT2+26, "UTF-16")  ; CHARFORMAT.szFaceName[LF_FACESIZE(32)]
        if ( RegExMatch(Options, "i)\bw([\d]+)(p*)",_) )  ; CFM_WEIGHT
            mask |= 0x00400000, NumPut(_[1], &CHARFORMAT2+90, "UShort")  ; CHARFORMAT2.wWeight
        if ( RegExMatch(Options, "i)\bbc(&\d+|[\da-f]+)\b",_) && ( _ := ["0x" . _[1]] ) )  ; CFM_BACKCOLOR
            mask |= 0x04000000, NumPut(((_[1]&0xFF0000)>>16)+(_[1]&0xFF00)+((_[1]&0xFF)<<16), &CHARFORMAT2+96, "UInt")  ; CHARFORMAT2.crBackColor
        if ( RegExMatch(Options, "i)\bUnderline([\-\d]+)(p*)",_) )  ; CFM_UNDERLINETYPE
            mask |= 0x00800000, NumPut(_[1], &CHARFORMAT2+112, "UChar")  ; CHARFORMAT2.bUnderlineType
        if ( RegExMatch(Options, "i)\bra([\d]+)(p*)",_) )  ; CFM_REVAUTHOR
            mask |= 0x00008000, NumPut(_[1], &CHARFORMAT2+114, "UChar")  ; CHARFORMAT2.bRevAuthor
        if ( RegExMatch(Options, "i)\buc(&\d+|[\da-f]+)\b",_) && ( _ := ["0x" . _[1]] ) )
            NumPut(_[1], &CHARFORMAT2+115, "UChar")  ; CHARFORMAT2.bUnderlineColor

        Loop Parse, "bold.1|ital.2|under.4|stri.8|prot.16|smallc.64|allc.128|hid.256|outl.512|sha.1024|emb.2048|imp.4096|dis.8192|rev.16384|sub.65536|sup.131072", "|"
            if ( InStr(Options,(_:=StrSplit(A_LoopField,"."))[1]) )
                mask |= _[2], effects |= InStr(Options,"-" . _[1]) ? 0 : _[2]

        NumPut(effects, NumPut((116&0xFFFFFFFF)|((mask&0xFFFFFFFF)<<32), &CHARFORMAT2, "Int64"), "UInt")
        return SendMessage(0x444, Mode, &CHARFORMAT2, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setcharformat

    /*
        Formats the text in the specified range.
        Parameters:
            Mode:
                Specifies the mode of saving and restoring the cursor and the scroll bars. It can be one or more of the following values.
                0   = It does not perform any saving and restoration operations.
                1   = Save the current positions in a static variable.
                2   = Restore the positions saved last time.
                This helps improve performance if you are going to format multiple pieces of text.
                In the first iteration, specify mode=1 to save the current position.
                In the following iterations, specify mode=0.
                In the last iteration, specify mode=2.
        Return value:
            The return value is always TRUE.
        Note:
            If 'Min' or 'Max' are an empty string, nothing is formatted.
            .. You can use this to restore the last saved position without performing any further formatting operations.
    */
    SetFontRange(Min := "", Max := "", Options := "", FontFace := "", Mode := 3)
    {
        static POINT := 0, CHARRANGE1 := 0
        if ( Mode & 1 )
            SendMessage(0*SendMessage(0x434,,&CHARRANGE1,this)+0x4DD,, &POINT, this)
        if ( Min !== "" && Max !="" ) {
            local CHARRANGE2 := (Min&0xFFFFFFFF)|((Max&0xFFFFFFFF)<<32)
            this.SetFont( Options, FontFace, 0*SendMessage(0x437,,&CHARRANGE2,this)+1 )
        } if ( Mode & 2 )
            SendMessage(0*SendMessage(0x437,,&CHARRANGE1,this)+0x4DE,, &POINT, this)
        return TRUE
    } ; GetScrollPos + GetSelection + SetFont + SetSelection + SetScrollPos

    /*
        Sets the font size for the selected text in a rich edit control.
        Parameters:
            Value:
                Change in point size of the selected text. Rich Edit adds 'Value' the current font size.
        Return value:
            If no error occurred, the return value is TRUE. If an error occurred, the return value is FALSE.
    */
    SetFontSize(Value)
    {
        return SendMessage(0x4DF, Value,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setfontsize

    /*
        Set the paragraph alignment for the current selection.
        Parameters:
            Alignment:
                Value specifying the paragraph alignment. This member can be one of the following values.
                PFA_LEFT = 1, PFA_RIGHT, PFA_CENTER, PFA_JUSTIFY/PFA_FULL_INTERWORD, PFA_FULL_INTERLETTER, PFA_FULL_SCALED, PFA_FULL_GLYPHS, PFA_SNAP_GRID.
        Return value:
            If the operation succeeds, the return value is a nonzero value. If the operation fails, the return value is zero.
    */
    SetAlignment(Alignment)
    {
        local PARAFORMAT2  ; https://docs.microsoft.com/en-us/windows/desktop/api/Richedit/ns-richedit-paraformat2
        NumPut(0*VarSetCapacity(PARAFORMAT2,188)+0x8000000BC, &PARAFORMAT2, "Int64")
        return SendMessage(0x447, NumPut(Alignment,&PARAFORMAT2+24,"UShort"), &PARAFORMAT2, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setparaformat

    /*
        Set the paragraph line spacing.
        Parameters:
            LineSpacing:
                Spacing between lines. For a description of how this value is interpreted, see the 'Rule' parameter.
            Rule:
                Type of line spacing. This member can be one of the following values.
                0     Single spacing. The 'LineSpacing' parameter is ignored.
                1     One-and-a-half spacing. The 'LineSpacing' parameter is ignored.
                2     Double spacing. The 'LineSpacing' parameter is ignored.
                3     The 'LineSpacing' parameter specifies the spacing from one line to the next, in twips. If 'LineSpacing' specifies a value that is less than single spacing, the control displays single-spaced text.
                4     The 'LineSpacing' parameter specifies the spacing from one line to the next, in twips. The control uses the exact spacing specified, even if 'LineSpacing' specifies a value that is less than single spacing.
                5     The value of 'LineSpacing/20' is the spacing, in lines, from one line to the next. Thus, setting 'LineSpacing' to 20 produces single-spaced text, 40 is double spaced, 60 is triple spaced, and so on.
        Return value:
            If the operation succeeds, the return value is a nonzero value. If the operation fails, the return value is zero.
    */
    SetLineSpacing(LineSpacing, Rule := 5)
    {
        local PARAFORMAT2  ; https://docs.microsoft.com/en-us/windows/desktop/api/Richedit/ns-richedit-paraformat2
        NumPut(0*VarSetCapacity(PARAFORMAT2,188)+0x100000000BC, &PARAFORMAT2, "Int64")
        return SendMessage(0x447, NumPut(Rule,NumPut(LineSpacing,&PARAFORMAT2+164,"Int")+2,"UChar"), &PARAFORMAT2, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setparaformat

    /*
        Set the paragraph indentation.
        Parameters:
            Start:
                Indentation of the first line in the paragraph, in twips.
                This value is treated as a relative value that is added to the starting indentation of each affected paragraph.
            Right:
                Size, of the right indentation relative to the right margin, in twips.
            Offset:
                Indentation of the second and subsequent lines of a paragraph relative to the starting indentation, in twips.
                The first line is indented if this member is negative or outdented if this member is positive.
        Return value:
            If the operation succeeds, the return value is a nonzero value. If the operation fails, the return value is zero.
        Remarks:
            An empty string indicates that the current value is not modified.
    */
    SetIndentation(Start := "", Right := "", Offset := "")
    {
        local PARAFORMAT2
        NumPut(0*VarSetCapacity(PARAFORMAT2,188)+188, &PARAFORMAT2, "UInt")
        ,NumPut((Start!=="")|(Right==""?0:2)|(Offset==""?0:4), &PARAFORMAT2+4, "UInt")
        ,NumPut(Offset==""?0:Offset, NumPut(Right==""?0:Right,NumPut(Start==""?0:Start,&PARAFORMAT2+12,"Int"),"Int"), "Int")
        return SendMessage(0x447,, &PARAFORMAT2, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setparaformat

    /*
        Set the paragraph numbering.
        Parameters:
            Numbering:
                Value specifying numbering options. This parameter can be zero or one of the following values.
                PFN_BULLET       1       tomListBullet
                PFN_ARABIC       2       tomListNumberAsArabic:     0,  1,   2, ...
                PFN_LCLETTER     3       tomListNumberAsLCLetter:   a,  b,   c, ...
                PFN_UCLETTER     4       tomListNumberAsUCLetter:   A,  B,   C, ...
                PFN_LCROMAN      5       tomListNumberAsLCRoman:    i, ii, iii, ...
                PFN_UCROMAN      6       tomListNumberAsUCRoman:    I, II, III, ...
            Start:
                Starting number or Unicode value used for numbered paragraphs.
            Style:
                Numbering style used with numbered paragraphs.
                PFNS_PAREN       0x000      Follows the number with a right parenthesis.  
                PFNS_PARENS      0x100      Encloses the number in parentheses.   
                PFNS_PERIOD      0x200      Follows the number with a period. 
                PFNS_PLAIN       0x300      Displays only the number. 
                PFNS_NONUMBER    0x400      Continues a numbered list without applying the next number or bullet.
                PFNS_NEWNUMBER   0x8000     Starts a new number with 'Start'.
            Tab:
                Minimum space between a paragraph number and the paragraph text, in twips.
        Return value:
            If the operation succeeds, the return value is a nonzero value. If the operation fails, the return value is zero.
        Remarks:
            An empty string indicates that the current value is not modified.
    */
    SetNumbering(Numbering := "", Start := "", Style := "", Tab := "")
    {
        local PARAFORMAT2
        NumPut(0*VarSetCapacity(PARAFORMAT2,188)+188, &PARAFORMAT2, "UInt")
        ,NumPut((Numbering==""?0:0x20)|(Start==""?0:0x8000)|(Style==""?0:0x2000)|(Tab==""?0:0x4000), &PARAFORMAT2+4, "UInt")
        ,NumPut(Tab, NumPut(Style,NumPut(Start,NumPut(Numbering,&PARAFORMAT2+8,"UShort")+166,"UShort"),"UShort"), "UShort")
        return SendMessage(0x447,, &PARAFORMAT2, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setparaformat

    /*
        Set the paragraph spacing.
        Parameters:
            Before:
                Size of the spacing above the paragraph, in twips. The value must be greater than or equal to zero.
            After:
                Specifies the size of the spacing below the paragraph, in twips. The value must be greater than or equal to zero.
        Return value:
            If the operation succeeds, the return value is a nonzero value. If the operation fails, the return value is zero.
        Remarks:
            An empty string indicates that the current value is not modified.
    */
    SetSpacing(Before := "", After := "")
    {
        local PARAFORMAT2
        NumPut((Before==""?0:0x40)|(After==""?0:0x80), NumPut(0*VarSetCapacity(PARAFORMAT2,188)+188,&PARAFORMAT2,"UInt"), "UInt")
        return SendMessage(0x447, NumPut(After,NumPut(Before,&PARAFORMAT2+156,"Int"),"Int"), &PARAFORMAT2, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setparaformat

    /*
        Retrieves the paragraph formatting of the current selection.
        Return value:
            Returns an object with the following keys.
            Alignment. LineSpacing, LineSpacingRule. StartIndent, RightIndent, Offset. Numbering, NumStart, NumStyle, NumTab. SpacingBefore, SpacingAfter.
    */
    GetParaFormat()
    {
        local PARAFORMAT2, _, obj := { size: 0*VarSetCapacity(PARAFORMAT2,188)+188 }
        obj.mask := SendMessage(0x43D, NumPut(obj.size,&PARAFORMAT2,"UInt"), &PARAFORMAT2, this)
        loop parse, "alignment.24.ushort|lineSpacingrule.170.uchar|startindent.12.int|rightindent.16.int|offset.20.int|numbering.8.ushort|numstart.176.ushort|numstyle.178.ushort|numtab.180.ushort|spacingbefore.156.int|spacingafter.160.int", "|"
            obj[(_:=StrSplit(A_LoopField,"."))[1]] := NumGet(&PARAFORMAT2+_[2], _[3])
        obj.linespacing := obj.linespacingrule > 2 ? NumGet(&PARAFORMAT2+164,"Int") : {0:20,1:29,2:40}[obj.linespacingrule]
        return obj
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getparaformat

    /*
        Determines the character formatting in a rich edit control.
        Parámeters:
            Mode:
                Specifies the range of text from which to retrieve formatting. It can be one of the following values.
                SCF_DEFAULT           0x0000  (The default character formatting.)
                SCF_SELECTION         0x0001  (The current selection's character formatting.)
        Return value:
            Returns an object with information about the character formatting. The keys are listed below.
                - mask, effects, size, offset, charset, weight, utype, ucolor, pichnfamily, revauthor, color, bcolor, name.
                - bold, italic, underline, strike, protected, smallcaps, allcaps, hidden, outline, shadow, emboss, imprint, disabled, revised, subcript, superscript, link.
        Note:
            The color of the text or background can be the string 'Auto'. See the method SetFont.
            To get the BGR color you can use:
                DllCall("User32.dll\GetSysColor", "Int", 8, "UInt")  ; For the text color.
                DllCall("User32.dll\GetSysColor", "Int", 5, "UInt")  ; For the background color.
            ... and to convert the color from BGR to RGB you can use:
                rgb_color := ((bgr_color & 0xFF0000) >> 16) + (bgr_color & 0xFF00) + ((bgr_color & 0xFF) << 16)
    */
    GetFont(Mode := 0)
    {
        local CHARFORMAT2, _ := NumPut(0*VarSetCapacity(CHARFORMAT2,116,0)+116, &CHARFORMAT2, "UInt")
        local font := { mask: SendMessage(0x43A, Mode, &CHARFORMAT2, this), effects: NumGet(&CHARFORMAT2+8,"UInt") }
        Loop Parse, "offset.16.int|charset.24.uchar|weight.90.ushort|utype.112.uchar|ucolor.115.uchar|pichnfamily.25.uchar|revauthor.114.uchar", "|"
            font[(_:=StrSplit(A_LoopField,"."))[1]] := NumGet(&CHARFORMAT2+_[2], _[3])
        font.color  := font.effects&0x40000000 ? "Auto" : (((_:=NumGet(&CHARFORMAT2+20,"UInt"))&0xFF0000)>>16)+(_&0xFF00)+((_&0xFF)<<16)
       ,font.bcolor := font.effects&0x04000000 ? "Auto" : (((_:=NumGet(&CHARFORMAT2+96,"UInt"))&0xFF0000)>>16) + (_&0xFF00) + ((_&0xFF)<<16)
       ,font.name   := StrGet(&CHARFORMAT2+26, 32, "UTF-16"), font.size := NumGet(&CHARFORMAT2+12,"Int") // 20
        Loop Parse, "bold.1|italic.2|underline.4|strike.8|protected.16|link.32|smallcaps.64|allcaps.128|hidden.256|outline.512|shadow.1024|emboss.2048|imprint.4096|disabled.8192|revised.16384|subscript.65536|superscript.131072", "|"
            font[(_:=StrSplit(A_LoopField,"."))[1]] := font.effects & _[2] ? (A_Index==3?font.utype||1:TRUE) : FALSE
        return font
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getcharformat

    /*
        Sets the tab stops. When text is copied to the control, any tab character in the text causes space to be generated up to the next tab stop.
        Parameters:
            TabStops:
                An array of unsigned integers specifying the tab stops, in dialog template units.
                It can be also a string with unsigned integers delimited by '|'.
            Count:
                The number of tab stops contained in the array. A value of -1 takes all the values in te array.
                If this parameter is zero, the 'TabStops' parameter is ignored and default tab stops are set at every 32 dialog template units.
                If this parameter is 1, tab stops are set at every n dialog template units, where n is the distance pointed to by the 'TabStops' parameter.
                If this parameter is greater than 1, 'TabStops' is an array of tab stops.
        Return value:
            If all the tabs are set, the return value is TRUE. If all the tabs are not set, the return value is FALSE.
        Remarks:
            The values specified in the array are in dialog template units, which are the device-independent units used in dialog box templates.
            A rich edit control can have the maximum number of tab stops specified by MAX_TAB_STOPS (32).
    */
    SetDefaultTabStops(TabStops, Count := -1)
    {
        local arr, _ := ""
        TabStops := IsObject( TabStops ) ? TabStops : StrSplit(RegExReplace(TabStops,"[^\|\d+]"),"|")
        Count    := Count == -1 ? TabStops.Length() : Min(Count,TabStops.Length())
        loop ( 0*VarSetCapacity(arr,Count) + Count )
            NumPut(TabStops[A_Index], &arr + 4 * ( A_Index - 1 ), "UInt"), _ .= integer(TabStops[A_Index]) . "|"
        this.DefTabStops := (arr:=SendMessage(0xCB,Count,&arr,this)) ? SubStr(_,1,-1) : this.DefTabStops
       ,this.SetRedraw(TRUE)
        return arr
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-settabstops
    
    /*
        Allow or prevent changes in that control to be redrawn.
        Parameters:
            Mode:
                The redraw state. If this parameter is TRUE, the content can be redrawn after a change.
                If this parameter is FALSE, the content cannot be redrawn after a change.
    */
    SetRedraw(Mode)
    {
        SendMessage(0xB, !!Mode,, this)
        if ( Mode )
            DllCall("User32.dll\InvalidateRect", "Ptr", this.hWnd, "Ptr", 0, "Int", TRUE, "Int")
           ,DllCall("User32.dll\UpdateWindow", "Ptr", this.hWnd, "Int")
    } ; https://docs.microsoft.com/en-us/windows/desktop/gdi/wm-setredraw

    /*
        Sets the event mask for this rich edit control. The event mask specifies which notification codes the control sends to its parent window.
        The default event mask (before any is set) is ENM_NONE.
        Parameters:
            Mask:
                New event mask for the rich edit control. For a list of event masks, see Rich Edit Control Event Mask Flags.
                https://docs.microsoft.com/en-us/windows/desktop/controls/rich-edit-control-event-mask-flags
            Mode:
                -1 = TOGGLE. 0 = REPLACE (default). 1 = ADD. 2 = REMOVE.
        Return value:
            This message returns the previous event mask.
    */
    SetEventMask(Mask, Mode := 0)
    {
        Mask := Mode == -1 ? this.GetEventMask() & Mask ? this.GetEventMask() & ~Mask : this.GetEventMask() | Mask  ; TOGGLE
              : Mode ==  1 ? this.GetEventMask() | Mask   ; ADD
              : Mode ==  2 ? this.GetEventMask() & ~Mask  ; REMOVE
              : Mode ==  0 ? Mask : 0                     ; REPLACE
        return SendMessage(0x445,, Mask, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-seteventmask

    /*
        Gets the event mask for this rich edit control. The event mask specifies which notification codes the control sends to its parent window.
    */ 
    GetEventMask()
    {
        local EventMask := SendMessage(0x445,,, this)
        return 0*SendMessage(0x445,,EventMask, this) + EventMask
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-seteventmask

    /*
        Causes a rich edit control to pass its contents to an application defined EditStreamCallback callback function.
        The callback function can then write the stream of data to a file or any other location that it chooses.
        Parameters:
            Mode:
                Specifies the data format and replacement options. This value must be one or more of the following values.
                SF_TEXT           0x0001    (Text with spaces in place of COM objects.)
                SF_RTF            0x0002    (RTF.)
                SF_RTFNOOBJS      0x0003    (RTF with spaces in place of COM objects.)
                SF_TEXTIZED       0x0004    (Text with a text representation of COM objects.)
                ------------------------------------------------------------------------------------------------------------------
                SF_UNICODE        0x0010    (Indicates Unicode text. You can combine this flag with the SF_TEXT flag.)
                FF_SELECTION      0x8000    (The control streams out only the contents of the current selection.)
                SFF_PLAINRTF      0x4000    (The control streams out only the keywords common to all languages, ignoring language-specific keywords.)
            Callback:
                Pointer to an EditStreamCallback function, which is an application-defined function that the control calls to transfer data.
                The control calls the callback function repeatedly, transferring a portion of the data with each call.
                Link: https://docs.microsoft.com/es-es/windows/desktop/api/richedit/nc-richedit-editstreamcallback.
                The method does not call CallbackFree with the passed callback.
            Cookie:
                Specifies an application-defined value that the rich edit control passes to the EditStreamCallback callback function specified by the Callback parameter.
            CallbackFree:
                Specifies to free the passed callback.
            CodePage:
                Generates UTF-8 RTF as well as text using other code pages (UTF-8 = 65001, UTF-16 = 1200).
        Return value:
            If a callback was specified, this method returns the number of characters written to the data stream.
            If a callback has not been specified, it returns all the recovered text.
        ErrorLevel:
            Indicates the results of the stream-out (write) operation. A value of zero indicates no error.
            A nonzero value can be the return value of the EditStreamCallback function or a code indicating that the control encountered an error.
        Examples:
            ansi_text    := StreamOut(1)      ; Get the whole control text as ansi text (0x8001 = Selected).
            unicode_text := StreamOut(0x11)   ; Get the whole control text as unicode text (0x8011 = Selected).
            RTF          := StreamOut(2)      ; Get the whole control text as RTF (0x8002 = Selected).
    */
    StreamOut(Mode, Callback := 0, Cookie := 0, CallbackFree := FALSE, CodePage := 1200)
    {
        local EDITSTREAM := "", r := VarSetCapacity(EDITSTREAM, 2*A_PtrSize+4), rtf := ""
        NumPut(Callback?Callback:CallbackCreate("EditStreamCallback"), NumPut(Cookie,&EDITSTREAM,"UPtr")+4, "UPtr")
        r := SendMessage(0x044A, CodePage==""?Mode:(CodePage<<16)|0x20|Mode, &EDITSTREAM, this), ErrorLevel := NumGet(&EDITSTREAM+A_PtrSize, "UInt")
        try CallbackFree( Callback && !CallbackFree ? 0 : NumGet(&EDITSTREAM+A_PtrSize+4,"UPtr") )
        return Callback ? r : rtf

        EditStreamCallback(dwCookie, pBuffer, BytesToRead, pBytesRead)
        {
            local CharsToRead := Mode & 0x10 ? BytesToRead // 2 : BytesToRead
            local Encoding := Mode & 0x10 ? "UTF-16" : "CP0"
            rtf .= StrGet(pBuffer, CharsToRead, Encoding)
        }
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-streamout
    
    /*
        Replaces the contents of a rich edit control with a stream of data provided by an application defined EditStreamCallback callback function.
        Parameters:
            Mode:
                Specifies the data format and replacement options. This value must be one or more of the following values.
                SF_TEXT           0x0001    (Text.)
                SF_RTF            0x0002    (RTF.)
                ------------------------------------------------------------------------------------------------------------------
                SF_UNICODE        0x0010    (Indicates Unicode text. You can combine this flag with the SF_TEXT flag.)
                FF_SELECTION      0x8000    (the data stream replaces the contents of the current selection. If not specified, the data stream replaces the entire contents of the control.)
                SFF_PLAINRTF      0x4000    (Only keywords common to all languages are streamed in. Language-specific RTF keywords in the stream are ignored.)
            Callback / Cookie / CallbackFree:
                See the StreamOut method.
                If you do not specify a callback, the Cookie parameter must be a string with the text to be set.
        Return value:
            This method returns the number of characters read.
        ErrorLevel:
            Indicates the results of the stream-in (read) operation. A value of zero indicates no error.
            A nonzero value can be the return value of the EditStreamCallback function or a code indicating that the control encountered an error.
        Examples:
            StreamIn(1,, "Plain text")  ; Replace the whole control text with the specified ansi plain text.
            StreamIn(0x8002,, TextRTF)  ; Replace the selected text with the specified RTF (Rich Text Format).
    */
    StreamIn(Mode, Callback := 0, Cookie := 0, CallbackFree := FALSE)
    {
        local EDITSTREAM := "", r := VarSetCapacity(EDITSTREAM, 2*A_PtrSize+4) * 0 + 1
        NumPut(Callback?Callback:CallbackCreate("EditStreamCallback"), NumPut(Cookie,&EDITSTREAM,"UPtr")+4, "UPtr")
        r := SendMessage(0x0449, Mode, &EDITSTREAM, this)
        try CallbackFree( Callback && !CallbackFree ? 0 : NumGet(&EDITSTREAM+A_PtrSize+4,"UPtr") )
        return 0 * ( ErrorLevel := NumGet(&EDITSTREAM+A_PtrSize,"UInt") ) + r

        EditStreamCallback(dwCookie, pBuffer, BytesToRead, pBytesRead)
        {
            local CharsRead := ( StrPut(SubStr(Cookie,r,BytesToRead//2), pBuffer, Mode&0x10?"UTF-16":"CP0") - 1 )
            local BytesRead := CharsRead * ( Mode&0x10 ? 2 : 1 )
            NumPut(BytesRead, pBytesRead, "Int"), r += CharsRead
        }
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-streamin

    /*
        Save the content to a file.
        Parameters:
            FileName:
                The name of the file where the content will be saved. This parameter can be a File Object with write access.
            Mode:
                Specifies the data format and replacement options. This value must be one or more of the following values. By default it writes RTF.
                StreamOut Method: SF_TEXT, SF_RTF, FF_SELECTION, SF_UNICODE.
        Return value:
            Returns -1 if there was an error opening the file. Otherwise, it returns what the StreamOut method.
        Remarks:
            This method is more effective than doing it in another way, since the file is written in parts directly from the control's buffer.
            If you specify the SF_TEXT and SF_UNICODE flags, the file is written as UTF-16LE with BOM (instead of ANSI).
    */
    Save(FileName, Mode := 2, CodePage := 1200)
    {
        local f := IsObject( FileName ) ? FileName : FileOpen(FileName, "w-wrd", Mode&0x10?"UTF-16":"CP0")
        return f ? f.Write("")+this.StreamOut(Mode,CallbackCreate((x,p,y,z)=>!NumPut(f.RawWrite(p,y),z,"Int")),,TRUE,CodePage) : -1
    } ; StreamOut
    
    /*
        Load content from a file into the control.
        Parameters:
            FileName:
                The name of the file from which to read. This parameter can be a File Object with read access.
            Mode:
                Specifies the data format and replacement options. This value must be one or more of the following values. By default it reads RTF.
                StreamIn Method: SF_TEXT, SF_RTF, FF_SELECTION, SF_UNICODE.
        Return value:
            Returns -1 if there was an error opening the file. Otherwise, it returns what the StreamIn method.
        Remarks:
            This method is more effective than doing it in another way, since the file content are written in parts directly into the control's buffer.
            This method only supports ANSI and UTF-16LE files. Loading a file in another encoding will show erroneous data. Use the Load2 method instead.
    */
    Load(FileName, Mode := 2)
    {
        local f := IsObject( FileName ) ? FileName : FileOpen(FileName, "r-wd", Mode&0x10?"UTF-16":"CP0")
        return f ? this.StreamIn(Mode,CallbackCreate((x,p,y,z)=>!NumPut(f.RawRead(p,y),z,"Int")),,TRUE) : -1
    } ; StreamIn

    /*
        Same as the Load method. Supports ANSI, UTF-8, UTF-16LE and UTF-16BE files.
        Mode can be: SF_TEXT, SF_RTF, FF_SELECTION. SF_UNICODE is detected automatically.
        This method can have a worse performance for UTF-8 and UTF-16BE large files.
    */
    Load2(FileName, Mode := 1)
    {
        local f := IsObject( FileName ) ? FileName : FileOpen(FileName, "r-wd")
        if ( f && f.Encoding == "UTF-16")  ; UTF-16LE (use Load method)
            return this.Load(f, Mode&2?Mode:Mode|0x10)
        else if ( f && f.Encoding == "UTF-8" )  ; UTF-8
            local txt := f.Read()
        else if ( f ) {
            local char := [f.ReadUchar(), f.ReadUChar()]
            if ( char[1] !== 0xFE || char[2] !== 0xFF )  ; ANSI (use Load method. else UTF-16BE)
                return 0*f.Seek(0) + this.Load(f, Mode)
            local LE := "", BE := "", _ := VarSetCapacity(LE,f.length-2) . VarSetCapacity(BE,f.length-2)
            f.RawRead(&BE, f.length-2)  ; Read binary data (UTF-16BE) without BOM (FEFF).
            DllCall("Kernel32.dll\LCMapStringW", "UInt", 0, "UInt", 0x800, "UPtr", &BE, "UInt", f.length-2, "UPtr", &LE, "UInt", f.length-2, "Int")
            local txt := StrGet(&LE, (f.length-2)//2, "UTF-16")
        } f := f ? f.Close() . "1" : 0
        return f ? this.StreamIn(Mode&2?Mode:Mode|0x10,,txt) : -1
    }

    /*
        Defines the current autocorrect callback procedure. The current callback is released automatically when the control is removed.
        Parameters:
            AutoCorrectProc:
                The AutoCorrectProc callback function, or specify zero to remove the current callback.
                Link: https://docs.microsoft.com/en-us/windows/desktop/api/Richedit/nc-richedit-autocorrectproc.
        Return value:
            If the operation succeeds, the return value is zero. If the operation fails, the return value is a nonzero value.
    */
    SetAutoCorrectProc(AutoCorrectProc)
    {
        if ( Type(AutoCorrectProc) !== "Integer" || AutoCorrectProc <= 0x10000 )
            throw Exception("SetAutoCorrectProc method invalid parameter #1.", -1, "RichEdit Class.")
        return SendMessage(0x4EA, AutoCorrectProc,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-setautocorrectproc

    /*
        Gets a pointer to the application-defined AutoCorrectProc function.
    */
    GetAutoCorrectProc()
    {
        return SendMessage(0x4E9,,, this)
    } ; https://docs.microsoft.com/es-es/windows/desktop/Controls/em-getautocorrectproc

    /*
        Calls the autocorrect callback function that is stored by the EM_SETAUTOCORRECTPROC message, provided that the text preceding the insertion point is a candidate for autocorrection.
        Parameters:
            WChar:
                A character of type WCHAR.
                If this character is a tab (U+0009), and the character preceding the insertion point isn't a tab,
                - then the character preceding the insertion point is treated as part of the autocorrect candidate string instead of as a string delimiter;
                - otherwise, wParam has no effect.
        Return value:
            The return value is zero if the message succeeds, or nonzero if an error occurs.
    */
    CallAutoCorrectProc(WChar := 0)
    {
        return SendMessage(0x4FF, WChar,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-callautocorrectproc

    /*
        Replaces the selection with a blob that displays an image. If the selection is an insertion point, the image blob is inserted at the insertion point.
        Parameters:
            pIStream:
                The stream that contains the image data.
            xWidth / yHeight:
                The width and height, in HIMETRIC units (0.01 mm), of the image.
            Ascent:
                If Type is TA_BASELINE, this parameter is the distance, in HIMETRIC units, that the top of the image extends above the text baseline.
                If Type is TA_BASELINE and ascent is zero, the bottom of the image is placed at the text baseline.
            Type:
                The vertical alignment of the image. It can be one of the following values.
                TA_TOP         0    Align the top of the image at the top of the text line.
                TA_BOTTOM      8    Align the bottom of the image at the bottom of the text line.
                TA_BASELINE   24    Align the image relative to the text baseline.
            AlternateText:
                The alternate text for the image.
        Return value:
            Returns 0 (S_OK) if successful, or one of the following error codes.
            E_FAIL           0x80004005     Cannot insert the image.
            E_INVALIDARG     0x80070057     The pIStream parameter points to an invalid image.
            E_OUTOFMEMORY    0x8007000E     Insufficient memory is available.
    */
    InsertImage(pIStream, xWidth, yHeight, Ascent := 0, Type := 0, AlternateText := "")  ; WIN_8+
    {
        local RICHEDIT_IMAGE_PARAMETERS := "", _ := VarSetCapacity(RICHEDIT_IMAGE_PARAMETERS, 16+2*A_PtrSize, 0)
        NumPut((floor(xWidth)&0xFFFFFFFF)|((floor(yHeight)&0xFFFFFFFF)<<32), &RICHEDIT_IMAGE_PARAMETERS, "Int64")
       ,NumPut((Ascent&0xFFFFFFFF)|((Type&0xFFFFFFFF)<<32), &RICHEDIT_IMAGE_PARAMETERS+8, "Int64")
       ,NumPut(&AlternateText, &RICHEDIT_IMAGE_PARAMETERS+16, "UPtr")
       ,NumPut(pIStream, &RICHEDIT_IMAGE_PARAMETERS+16+A_PtrSize, "UPtr")
        return SendMessage(0x53A,, &RICHEDIT_IMAGE_PARAMETERS, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-insertimage

    InsertImage2(FileName, xWidth, yHeight, Ascent := 0, Type := 0, AlternateText := "")  ; WIN_8+
    {
        local pIStream := 0
        local r := DllCall("Shlwapi.dll\SHCreateStreamOnFileEx", "UPtr", &FileName, "UInt", 0, "UInt", 0, "Int", FALSE, "UPtr", 0, "UPtrP", pIStream, "UInt")
        return r ? r : this.InsertImage(pIStream, xWidth, yHeight, Ascent, Type, AlternateText)  ; HRESULT error code.
    } ; https://docs.microsoft.com/es-es/windows/desktop/api/shlwapi/nf-shlwapi-shcreatestreamonfileex

    /*
        Replaces the selection or the whole text with a friendly hyperlink.
        Parameters:
            Link:
                The hyperlink. It can be a URL or the path to a file.
            Label:
                The link label. If an empty string is specified, the string specified in 'Link' will be used.
            Mode:
                See the SetText method. By default is ST_SELECTION.
    */
    InsertHyperlink(Link, Label := "", Mode := 2)
    {
        Link := Trim(Link), Label := Label == "" ? Link : Label
        return StrLen(Link) ? this.SetText("{\rtf1{\field{\*\fldinst{HYPERLINK `"" . RE_FormatRTF(Link) . "`"}}{\fldrslt{" . RE_FormatRTF(Label) . "}}}}", Mode) : 0
    } ; https://www.autohotkey.com/boards/viewtopic.php?t=43427#p198934

    /*
        Inserts one or more identical table rows with empty cells.
        Parameters:
            Cell:
                The count of cells in a row, up to the maximum specified by MAX_TABLE_CELLS (63).
            Row:
                The count of rows.
            CellWidth:
                The width of each cell, in twips. You can specify an array with the desired width for each cell.
            CellMargin:
                Left margin width of each row, in twips. It can be an array.
            BorderWidth:
                Cells border width, in twips. Defaults to 10. Zero is the thinnest border.
                You can specify an array [left,top,right,bottom]. Unspecified parts inherits the last one.
            BorderType:
                The border type. Defaults to 'brdrs'. It can be an array as the 'BorderWidth' parameter.
                brdrs            Single border. Other borders may not be displayed on this control.
                brdrdot          Dotted border.
                brdrdb           Double thickness border.
                brdrdash         Dashed border.
                brdrdashsm       Small dashed border.
                brdrdashd        Dot dash border.
                brdrdashdd       Dot dot dash border.
                brdrtriple       Triple border.
                brdrtnthlg       Thick thin border (large).
                brdrtnthlg       Thin thick border (large).
                brdrtnthtnlg     Thin thick thin border (large).
                brdrwavy         Wavy border.
                brdrdashdotstr   Striped border.
                brdremboss       Emboss border.
                brdrengrave      Engrave border.
            Data:
                The initial data to fill in the table. An array of strings can be specified.
                The table is filled from top to bottom and from left to right.
                If a string is specified, all cells will be initialized with it.
                Data beyond the array will be initialized with Data[0].
            Mode:
                See the SetText method. By default is ST_SELECTION.
    */
    InsertTable(Cell := 1, Row := 1, CellWidth := 375, CellMargin := 144, BorderWidth := 10, BorderType := "brdrs", Data := "", Mode := 2)
    {
        static fnc := (n,v,f:=0) => IsObject(v) ? v[ n > v.length() ? ( f ? 0 : v.length() ) : n ] : v
        local RTF := "", arr := [0,0,0]
        loop ( Row )
        {
            RTF .= "\trowd\trgaph" . fnc.call(A_Index,CellMargin)
            loop ( Cell )
                RTF .= "\clbrdrl\" . fnc.call(1,BorderType) . "\brdrw" . fnc.call(1,BorderWidth) . "\clbrdrt\" . fnc.call(2,BorderType) . "\brdrw" . fnc.call(2,BorderWidth) . "\clbrdrr\" . fnc.call(2,BorderType) . "\brdrw" . fnc.call(3,BorderWidth) . "\clbrdrb\" . fnc.call(4,BorderType) . "\brdrw" . fnc.call(4,BorderWidth)
                     . "\cellx" . ( arr[1] := fnc.call(A_Index,CellWidth) ) + arr[2], arr[2] += arr[1]
            arr[2] := 0, RTF .= "\pard\intbl"
            loop ( Cell )
                RTF .= "\f1 " . RE_FormatRTF( fnc.call(++arr[3],Data,1) ) . "\f0\cell"
            RTF .= "\row"
        }
        return Row > 0 ? this.SetText("{\rtf1\par" . RTF . "\par}", Mode) : 0
    } ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=681&sid=ad4b5299166c4d91aff249adb3402f44&start=160#p200226 | http://www.pindari.com/rtf3.html

    /*
        Gets the state of the modification flag.
        The flag indicates whether the contents of the rich edit control have been modified.
        Return value:
            If the contents of rich edit control have been modified, the return value is nonzero; otherwise, it is zero.
    */
    GetModify()
    {
        return SendMessage(0xB8,,, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-getmodify

    /*
        Sets or clears the modification flag for this rich edit control.
        The modification flag indicates whether the text within the rich edit control has been modified.
        Remarks:
            The system automatically clears the modification flag to zero when the control is created.
            If the user changes the control's text, the system sets the flag to nonzero.
    */
    SetModify(Value)
    {
        SendMessage(0xB9,, !!Value, this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/controls/em-setmodify

    
    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Get or set the caret line.
        When set, by default the current column is maintained.
        If the current column is greater than the number of characters in the specified line, the caret is positioned at the end.
    */
    Line[Column := -1]
    {
        Get {
            return this.LineFromChar( this.GetSelection().start )
        }
        Set {
            if ( Column == -1 )
            {
                local len := this.LineLength( this.LineIndex(value) )
                Column := this.Column > len ? len : this.Column
            }
            this.SetSelection( this.LineIndex(value) + Column )
            return value
        }
    }

    /*
        Get or set the caret position.
    */
    Caret[]
    {
        get {
            return this.GetSelection().start
        }
        set {
            return this.SetSelection( value )
        }
    }

    /*
        Get or set the caret column.
    */
    Column[]
    {
        get {
            return this.GetSelection().start - this.LineIndex()
        }
        set {
            return this.SetSelection( this.LineIndex() + value )
        }
    }
}





RichEdit_OnMessage(wParam, lParam, Msg, hWnd)
{
    global RichEdit  ; Class.
    local

    if ( Msg == 0x02 )  ; WM_DESTROY.
    {
        for ctrl_hwnd, ctrl_obj in RichEdit.Instance.Clone()
            if ( ctrl_obj.hGui == hWnd )
                ctrl_obj.Destroy()
    }
}
