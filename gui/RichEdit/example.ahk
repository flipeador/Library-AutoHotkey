#Warn
#NoTrayIcon

#Include RichEdit.ahk


MenuBar := MenuBarCreate()
Menu_Open := MenuCreate()
Menu_Open.Add("Automatic detection", (*) => RE.Load2(FileSelect(3)))   ; Automatic detection (ANSI, UTF-8, UTF-16LE/BE).
Menu_Open.Add()
Menu_Open.Add("ANSI", (*) => RE.Load(FileSelect(3),1))                 ; ANSI (CP0).
Menu_Open.Add("UTF-16LE", (*) => RE.Load(FileSelect(3),0x11))          ; UTF-16LE.
Menu_Open.Add("RTF", (*) => RE.Load(FileSelect(3)))                    ; RTF.

Menu_Save := MenuCreate()
Menu_Save.Add("ANSI", (*) => RE.Save(FileSelect("S18"),1))          ; ANSI (CP0).
Menu_Save.Add("UTF-16LE", (*) => RE.Save(FileSelect("S18"),0x11))   ; UTF-16LE.
Menu_Save.Add("RTF", (*) => RE.Save(FileSelect("S18")))             ; RTF.

Menu_File := MenuCreate()
Menu_File.Add("Open..", Menu_Open)
Menu_File.Add("Save As..", Menu_Save)
Menu_File.Add()
Menu_File.Add("Reload", (*) => Reload())
Menu_File.Add("Exit", (*) => ExitApp())

Menu_Edit := MenuCreate()
Menu_Edit.Add("Find and replace text..", (*) => RE_FindText(RE))
Menu_Edit.Add()
Menu_Edit.Add("Read only", (t*) => RE.GetOptions() & 0x800 ? RE.SetOptions(0x800,4) . Menu_Edit.UnCheck(t[1]) : RE.SetOptions(0x800,2) . Menu_Edit.Check(t[1]))

Menu_Underline := MenuCreate()
Menu_Underline.Add("No underline", (*) => RE.SetFont("-Underline0",,1), "+Radio")
Menu_Underline.Add()
Menu_Underline.Add("Single solid line", (*) => RE.SetFont("Underline1",,1), "+Radio")
Menu_Underline.Add("Words only", (*) => RE.SetFont("Underline2",,1), "+Radio")
Menu_Underline.Add("Double line", (*) => RE.SetFont("Underline3",,1), "+Radio")
Menu_Underline.Add("Dotted line", (*) => RE.SetFont("Underline4",,1), "+Radio")
Menu_Underline.Add("Dashes", (*) => RE.SetFont("Underline5",,1), "+Radio")
Menu_Underline.Add("Dashed and dotted line", (*) => RE.SetFont("Underline6",,1), "+Radio")
Menu_Underline.Add("Dashed and doubled dotted line", (*) => RE.SetFont("Underline7",,1), "+Radio")
Menu_Underline.Add("Wavy line", (*) => RE.SetFont("Underline8",,1))

Menu_Effects := MenuCreate()
loop parse, "Bold.Italic.Strike..Shadow.Protected.", "."
    Menu_Effects.Add(A_LoopField, (n) => RE.SetFont((RE.GetFont(1)[n]?"-":"") . n,,1))
Menu_Effects.Add("Underline", Menu_Underline)

Menu_Insert := MenuCreate()
Menu_Insert.Add("Hyperlink (URL)", "InsertHyperlink_URL")
Menu_Insert.Add("Hyperlink (FILE)", "InsertHyperlink_File")
Menu_Insert.Add()
Menu_Insert.Add("Image file (WIN_8+)", (*) => RE.InsertImage2(FileSelect(3), PixelToHimetric(RE.Ctrl.Pos.W-50), PixelToHimetric(200)))
Menu_Insert.Add("Table", "InsertTable")

Menu_Alignment := MenuCreate()
Menu_Alignment.Add("Left", (*) => RE.SetAlignment(1) . Update_Menu_ParaFormat(), "+Radio")
Menu_Alignment.Add("Center", (*) => RE.SetAlignment(3) . Update_Menu_ParaFormat(), "+Radio")
Menu_Alignment.Add("Right", (*) => RE.SetAlignment(2) . Update_Menu_ParaFormat(), "+Radio")

Menu_LNSpacing := MenuCreate()
Menu_LNSpacing.Add("Single spacing", (*) => RE.SetLineSpacing(0,0) . Update_Menu_ParaFormat(), "+Radio")
Menu_LNSpacing.Add("One-and-a-half spacing", (*) => RE.SetLineSpacing(0,1) . Update_Menu_ParaFormat(), "+Radio")
Menu_LNSpacing.Add("Double spacing", (*) => RE.SetLineSpacing(0,2) . Update_Menu_ParaFormat(), "+Radio")
Menu_LNSpacing.Add()
Menu_LNSpacing.Add("From one line to the next (twips)", "LineSpacing", "+Radio")
Menu_LNSpacing.Add("From one line to the next (twips. exact)", "LineSpacing", "+Radio")
Menu_LNSpacing.Add("From one line to the next (lines. spacing/20)", "LineSpacing", "+Radio")

Menu_Indent := MenuCreate()
Menu_Indent.Add("Left", (*) => RE.SetIndentation(InputBox("Indentation of the first line in the paragraph, in twips.`n`nThis value is treated as a relative value that is added to the starting indentation of each affected paragraph.","Paragraph indentation",,RE.GetParaFormat().StartIndent)))
Menu_Indent.Add("Right", (*) => RE.SetIndentation(,InputBox("Size, of the right indentation relative to the right margin, in twips.","Paragraph indentation",,RE.GetParaFormat().RightIndent)))
Menu_Indent.Add("Offset", (*) => RE.SetIndentation(,,InputBox("Indentation of the second and subsequent lines of a paragraph relative to the starting indentation, in twips.`n`nThe first line is indented if this member is negative or outdented if this member is positive.","Paragraph indentation",,RE.GetParaFormat().Offset)))

Menu_Numbering := MenuCreate()
Menu_Numbering.Add("Bullet", (*) => RE.SetNumbering(1) . Update_Menu_ParaFormat(), "+Radio")
Menu_Numbering.Add("0, 1, 2 ...", (*) => RE.SetNumbering(2) . Update_Menu_ParaFormat(), "+Radio")
Menu_Numbering.Add("a, b, c ...", (*) => RE.SetNumbering(3) . Update_Menu_ParaFormat(), "+Radio")
Menu_Numbering.Add("A, B, C ...`s", (*) => RE.SetNumbering(4) . Update_Menu_ParaFormat(), "+Radio")
Menu_Numbering.Add("i, ii, iii ...", (*) => RE.SetNumbering(5) . Update_Menu_ParaFormat(), "+Radio")
Menu_Numbering.Add("I, II, III ...`s", (*) => RE.SetNumbering(6) . Update_Menu_ParaFormat(), "+Radio")
Menu_Numbering.Add()
Menu_Numbering.Add("Numbering start", (n) => RE.SetNumbering(,InputBox("Starting number used for numbered paragraphs.",n,,RE.GetParaFormat().NumStart)))
Menu_Numbering.Add("Numbering tab", (n) => RE.SetNumbering(,,,InputBox("Minimum space between a paragraph number and the paragraph text, in twips.",n,,RE.GetParaFormat().NumTab)))

Menu_Spacing := MenuCreate()
Menu_Spacing.Add("Before", (*) => RE.SetSpacing(InputBox("Size of the spacing above the paragraph, in twips.`n`nThe value must be greater than or equal to zero.","Spacing before",,RE.GetParaFormat().SpacingBefore)))
Menu_Spacing.Add("After", (*) => RE.SetSpacing(,InputBox("Specifies the size of the spacing below the paragraph, in twips.`n`nThe value must be greater than or equal to zero.","Spacing after",,RE.GetParaFormat().SpacingAfter)))

Menu_ParaFormat := MenuCreate()
Menu_ParaFormat.Add("Alignment", Menu_Alignment)
Menu_ParaFormat.Add("Line spacing", Menu_LNSpacing)
Menu_ParaFormat.Add("Indentation", Menu_Indent)
Menu_ParaFormat.Add("Numbering", Menu_Numbering)
Menu_ParaFormat.Add("Spacing", Menu_Spacing)
Menu_ParaFormat.Add()
Menu_ParaFormat.Add("Default tab stops", (n*) => RE.SetDefaultTabStops(InputBox("Unsigned integers specifying the tab stops, in dialog template units.`n`nString with unsigned integers delimited by '|'.",n[1],,RE.DefTabStops)))

MenuBar.Add("File", Menu_File)
MenuBar.Add("Edit", Menu_Edit)
MenuBar.Add("Effects", Menu_Effects)
MenuBar.Add("Insert", Menu_Insert)
MenuBar.Add("Paragraph formatting", Menu_ParaFormat)



Gui := GuiCreate("+Resize", "MS Rich Edit Control | Basic example - AutoHotkey v2")
Gui.MarginX := Gui.MarginY := 0
Gui.SetFont("s9", "Segoe UI")
Gui.MenuBar := MenuBar
RE := new RichEdit(Gui, "x0 y0 w550 h300 vRE2 +Multi", "Click on the middle button to select the whole line under the cursor."
                      . "`nCTRL-D to duplicate the current line or selection."
                      . "`n`nSome characters such as '" . Chr(21891) . "' can change the height of that line."
                      . "`nThe control uses UTF-16 encoding (two bytes per code poin), so characters such as '" . Chr(132878) . "' will count as two characters."
                      . "`n`nLink: https://www.autohotkey.com/boards/index.php."
                      . "`nYou can open the URL when it is clicked while the CTRL key is held down."
                      . "`n`nYou can use the SetFont method to set the character formatting."
                      . "`nYou can also protect a range of characters. An attempt to modify them will cause an EN_PROTECTED notification code.`n"
                      . "`nWrite 'btw' and see how it will be transformed into 'by the way'."
                      . "`nThis is done by setting an autocorrect callback function (EM_SETAUTOCORRECTPROC).`n"
                      . "`nYou can use friendly hyperlinks. Some examples are Google and Calculator.`n`n")
RE.SetRect( { left:4, top:4 } )
RE.AutoURL( 1|8 )
RE.SetFontRange(429, 492, "cFF0000 Underline4 uc3 Bold bc0", "Segoe UI")
RE.SetFontRange(493, 608, "Protected")
RE.Select("Google"), RE.InsertHyperlink("www.google.com", "Google")
RE.Select("Calculator"), RE.InsertHyperlink("calc.exe", "Calculator")
RE.SetSelection(879), RE.InsertTable(4, 7, 1750,,,, ["*","A","B","C",1,,,,2,,,,3,,,,4,,,,5,,,,6,,,,7])
loop parse, "882|884|886|888|894|904|912|921|930|939", "|"
    RE.SetSelection(A_LoopField), RE.SetAlignment(3)

SB := Gui.AddStatusBar("vSB")
SB.OnEvent("DoubleClick", "Gui_Statusbar_DoubleClick")

; (ENM_KEYEVENTS | ENM_MOUSEEVENTS | ENM_SCROLLEVENTS) | ENM_SELCHANGE | ENM_LINK | ENM_PROTECTED
; https://docs.microsoft.com/en-us/windows/desktop/controls/rich-edit-control-event-mask-flags
RE.SetEventMask( (0x10000 | 0x80000 | 0x20000) | 0x8 | 0x4000000 | 0x200000)
RE.SetAutoCorrectProc( CallbackCreate("AutoCorrectProc") )
RE.ClearUndo()      ; Clears the undo queue.

RE.Ctrl.OnNotify(0x0700, Func("EN_MSGFILTER"))  ; ENM_KEYEVENTS | ENM_MOUSEEVENTS | ENM_SCROLLEVENTS
RE.Ctrl.OnNotify(0x0702, Func("EN_SELCHANGE"))  ; ENM_SELCHANGE
RE.Ctrl.OnNotify(0x070B, Func("EN_LINK"))       ; ENM_LINK
RE.Ctrl.OnNotify(0x0704, Func("EN_PROTECTED"))  ; ENM_PROTECTED

Gui.OnEvent("Size", "Gui_Size")
Gui.OnEvent("Close", "ExitApp")

OnMessage(0x100, "WM_KEYDOWN")

Gui.Show()

RE.Ctrl.Focus()
RE.SetSelection(0)  ; Reset the selection.
return





/*
    MENUBAR FUNCTIONS.
*/
InsertHyperlink_URL(*)
{
    global RE
    local r := InputBox("Format:`n`tHyperlink Label`n`nExample:`n`twww.example.com An example.", "Insert friendly hyperlink")
    local Link := Trim( SubStr(r, 1, InStr(r,A_Space)) )
    local Label := Trim( SubStr(r, InStr(r,A_Space)+1) )
    RE.InsertHyperlink( Link, Label )
}

LineSpacing(ItemName, ItemPos, Menu)
{
    global RE
    local input := InputBox(ItemName . ".", "Paragraph formatting",, RE.GetParaFormat().LineSpacing)
    if ( !ErrorLevel )
        RE.SetLineSpacing(input, ItemPos-2)
    Update_Menu_ParaFormat()
}

InsertHyperlink_FILE(*)
{
    global RE
    local Path := FileSelect(), FNNE, _ := SplitPath(Path,,,, FNNE)
    local Label := ErrorLevel ? "" : InputBox("Specify the link label.", "Insert friendly hyperlink",, FNNE)
    RE.InsertHyperlink( Path, Label )
}


InsertTable(*)
{
    global RE
    local tbl := StrSplit(InputBox("The measurements are in Twips.`n`nTwip = Pixel / DPI * 1440.","Insert table.", "w500","Cells: 1, Rows: 1, CellWidth: 500, LeftMargin: 144, BorderWidth: 10."), ",")
    if ( !ErrorLevel )
        RE.InsertTable(RegExReplace(tbl[1],"[^0-9]"), RegExReplace(tbl[2],"[^0-9]"), RegExReplace(tbl[3],"[^0-9]"), RegExReplace(tbl[4],"[^0-9]"), RegExReplace(tbl[5],"[^0-9]"))
}


/*
    The AutoCorrectProc function is an application-defined callback function that is used with the EM_SETAUTOCORRECTPROC message.
    AutoCorrectProc is a placeholder for the application-defined function name. It provides application-defined automatic error correction for text entered into a rich edit control.
    Parámetros:
        LangID:
            Language ID that identifies the autocorrect file to use for automatic correcting.
        pBefore:
            Autocorrect candidate string.
        pAfter:
            Resulting autocorrect string, if the return value is not ATP_NOCHANGE.
        iAfter:
            Count of characters in pAfter.
        pReplaced:
            Count of trailing characters in pBefore to replace with iAfter.
    Return Value:
        Returns one or more of the following values.
        ATP_NOCHANGE        0  (No change.)
        ATP_CHANGE          1  (Change but don’t replace most delimiters, and don’t replace a span of unchanged trailing characters (preserves their formatting).)
        ATP_NODELIMITER     2  (Change but don’t replace a span of unchanged trailing characters.)
        ATP_REPLACEALLTEXT  4  (Replace trailing characters even if they are not changed (uses the same formatting for the entire replacement string).)
*/
AutoCorrectProc(LangID, pBefore, pAfter, iAfter, pReplaced)
{
    local Before   := StrGet(pBefore, "UTF-16")
    local FoundPos := Last := 0, Match
    
    while ( FoundPos := RegExMatch(Before, "(*UCP)\b(\w+)\b", Match, FoundPos+1) )
        Last := { str:Match[1], pos:FoundPos }
    
    if ( Last )
    {
        if ( Last.str = "btw" )  ; btw -> by the way.
        {
            Last.str := SubStr(last.str,1,1) . "y the way" . SubStr(Before,-1)
            StrPut(last.str, pAfter, "UTF-16")
            NumPut(3+1, pReplaced, "Int")  ; 3 = strlen("btw").
            return 2  ; ATP_NODELIMITER.
        }
    }
} ; https://docs.microsoft.com/en-us/windows/desktop/api/Richedit/nc-richedit-autocorrectproc


Gui_Size(_Gui, MinMax, W, H)
{
    static Update := 0

    if ( Update )
        SetTimer(Update, "Delete"), Update := 0
    if ( MinMax == -1 )  ; -1 = minimized.
        return
    SetTimer(Update:=Func("Update"), -50)

    Update()
    {   Update:=0
        local sbposh := _Gui.Control["SB"].Pos.H
        _Gui.Control["RE2"].Move("w" . W . " h" . (H-sbposh))
        _Gui.Control["SB"].SetParts(15*W//100,15*W//100,20*W//100,10*W//100,20*W//100)
    }
}


Gui_Statusbar_DoubleClick(SB, Index)
{
    static txt := ["Caret line. (modifiable)`nTotal number of lines.","Caret column start.`nCaret column end.","Selected text length.`nSelection start (character index).`nSelection end (character index).","Number of selected lines.","Total number of characters.`nTotal number of bytes.","Encoding.`nCursor Position (relative)."]
    local Opt := "h175 w350 x" . SB.Gui.Pos.X . " y" . (SB.Gui.Pos.Y+SB.Gui.Pos.H-175)
    
    if ( Index > 0 )
    {
        global RE
        SB.Gui.Opt("+OwnDialogs")
        local r := InputBox(txt[Index],, Opt, SB_GetText(SB,Index))
        if ( !ErrorLevel && Index == 1 )
        {
            RE.Line := StrSplit(r,A_Space)[2] - 1
            RE.ScrollCaret()
        }
    }
}


/*
    Notifies a rich edit control's parent window of a keyboard or mouse event in the control.
    A rich edit control sends this notification code in the form of a WM_NOTIFY message.
*/
EN_MSGFILTER(Ctrl, lParam)
{
    global RE
    local msg := NumGet(lParam+3*A_PtrSize, "UInt")
    
    if ( msg == 0x200 )  ; WM_MOUSEMOVE
        SetTimer("WM_MOUSEMOVE", -15)
    else if ( msg == 0x205 )  ; WM_RBUTTONUP
        SetTimer("WM_RBUTTONUP", -15)
    else if ( msg == 0x207 )  ; WM_MBUTTONDOWN
    {
        local curpos := RE.GetCursorPos()
        RE.SelectLine( RE.LineFromChar( RE.CharFromPos(curpos.x,curpos.y) ) )
        return 1  ; Blocks current behavior.
    } ; https://docs.microsoft.com/en-us/windows/desktop/inputdev/wm-mbuttondown

    WM_MOUSEMOVE()
    {
        local mpos := RE.GetCursorPos()
        RE.Gui.Control["SB"].SetText(RE.Encoding . " (" . mpos.x . ";" . mpos.y . ")", 6)
    } ; https://docs.microsoft.com/en-us/windows/desktop/inputdev/wm-mousemove

    WM_RBUTTONUP()  ; context menu
    {
        local menu := MenuCreate(), _ := 0
        local curtxt := RE.GetCurText()
        menu.add("Undo", (*) => RE.Undo()), _ := RE.CanUndo() ? 0 : menu.disable("Undo")
        menu.add("Redo", (*) => RE.Redo()), _ := RE.CanRedo() ? 0 : menu.disable("Redo")
        menu.add()
        menu.add("Cut", (*) => RE.Cut()), _ := RE.SelectionType() ? 0 : menu.disable("Cut")
        menu.add("Copy", (*) => RE.Copy()), _ := RE.SelectionType() ? 0 : menu.disable("Copy")
        menu.add("Paste", (*) => RE.Paste()), _ := Clipboard == "" ? menu.disable("Paste") : 0
        menu.add("Delete", (*) => RE.Clear()), _ := RE.SelectionType() ? 0 : menu.disable("Delete")
        menu.add()
        menu.add("Select All", (*) => RE.SelectAll()), _ := RE.GetTextLength() ? 0 : menu.disable("Select All")
        menu.add()
        menu.add("Open Hyperlink", (*) => Run(GetUrlCaret(curtxt,RE.column+1))), _ := GetUrlCaret(curtxt,RE.column+1) == "" ? menu.disable("Open Hyperlink") : 0
        menu.add("Google search", (*) => GoogleSearch(RE.GetSelText())), _ := RegExReplace(RE.GetSelText(),"\s") == "" ? menu.disable("Google search") : 0
        menu.show()
    } ; https://docs.microsoft.com/en-us/windows/desktop/inputdev/wm-rbuttonup
} ; https://docs.microsoft.com/en-us/windows/desktop/controls/en-msgfilter


/*
    Notifies a rich edit control's parent window that the current selection has changed.
    A rich edit control sends this notification code in the form of a WM_NOTIFY message.
*/
EN_SELCHANGE(Ctrl := 0, lParam := 0)
{
    global RE
    static Update := 0

    if ( Update )
        SetTimer(Update, "Delete"), Update := 0
    SetTimer(Update:=Func("Update"), -75)

    Update()
    {   Update := 0
        local sel := RE.GetSelection()
        sel.ln_start := RE.LineFromChar(sel.start)
        sel.ln_end := RE.LineFromChar(sel.end)
        local ln_index := RE.LineIndex(-1)

        ; caret line / total number of lines
        RE.Gui.Control["SB"].SetText("Ln " . (sel.ln_start+1) . " / " . RE.GetLineCount())
        ; caret column start / caret column end 
        RE.Gui.Control["SB"].SetText("Col " . (sel.start-ln_index+1) . " / " . (sel.end-ln_index+1), 2)
        ; selected text length / selection start / selection end
        RE.Gui.Control["SB"].SetText("Sel " . (sel.end-sel.start) . " / " . (sel.start+1) . " / " . (sel.end+1), 3)
        ; selected number of lines
        RE.Gui.Control["SB"].SetText("SLn " . (sel.ln_end-sel.ln_start+1), 4)
        ; total number of characters / total number of bytes
        RE.Gui.Control["SB"].SetText("Len " . RE.GetTextLength(8) . " / " . RE.GetTextLength(16), 5)

        Update_Menu_Effects()
        Update_Menu_ParaFormat()
    }
} ; https://docs.microsoft.com/en-us/windows/desktop/controls/en-selchange


Update_Menu_ParaFormat(*)
{
    global RE, Menu_Alignment, Menu_LNSpacing, Menu_Numbering
    local fmt := RE.GetParaFormat()

    loop parse, "left.right.center", "."
        Menu_Alignment[A_Index==fmt.alignment?"Check":"UnCheck"](A_LoopField)

    loop 7
        Menu_LNSpacing.UnCheck(A_Index . "&")
    Menu_LNSpacing.Check( (fmt.LineSpacingRule>2?fmt.LineSpacingRule+2:fmt.LineSpacingRule+1) . "&")

    loop 6
        Menu_Numbering.UnCheck(A_Index . "&")
    if ( fmt.Numbering )
        Menu_Numbering.Check(fmt.Numbering . "&")
}

Update_Menu_Effects(*)
{
    global RE, Menu_Effects, Menu_Underline
    local fnt := RE.GetFont(1)
    loop parse, "Bold.Italic.Strike.Shadow.Protected", "."
        Menu_Effects[fnt[A_LoopField]?"Check":"UnCheck"](A_LoopField)

    loop 10
        Menu_Underline.UnCheck(A_Index . "&")
    Menu_Underline.Check((fnt.underline?fnt.underline+2:fnt.underline+1) . "&")
}


/*
    Sends EN_LINK notifications when the mouse pointer is over text that has the CFE_LINK and one of several mouse actions is performed.
*/
EN_LINK(Ctrl, lParam)
{
    global RE
    local msg := NumGet(lParam+3*A_PtrSize, "UInt")  ; ENLINK.msg (https://docs.microsoft.com/en-us/windows/desktop/api/Richedit/ns-richedit-_enlink)
    local rng := { x:NumGet(lParam+5*A_PtrSize+4, "Int"), y:NumGet(lParam+5*A_PtrSize+8, "Int") }  ; ENLINK.CHARRANGE (x;y)

    if ( msg == 0x0202 )  ; WM_LBUTTONUP
        if ( GetKeyState("CTRL") )
            Run( RE.GetTextRange(rng.x,rng.y) )  ; Open the hyperlink when it is clicked while the CTRL key is held down.
} ; https://docs.microsoft.com/en-us/windows/desktop/controls/en-link


/*
    Notifies a rich edit control's parent window that the user is taking an action that would change a protected range of text.
    A rich edit control sends this notification code in the form of a WM_NOTIFY message.
    Return value:
        Return zero to allow the operation. Return a nonzero value to prevent the operation.
*/
EN_PROTECTED(RE, lParam)
{
    local msg := NumGet(lParam+3*A_PtrSize, "UInt")
    local wParam := NumGet(lParam+3*A_PtrSize+4, "UInt")  ; vk code.

    SetTimer("ShowToolTip", -50)
    SetTimer("ToolTip", -1000)

    return ( msg >= 0x100 && msg <= 0x108 )  ; 0x100 = WM_KEYFIRST. 0x108 = WM_KEYLAST.
        || ( msg >= 0x300 && msg <= 0x304 )  ; 0x300 = WM_CUT. 0x304 = WM_UNDO.

    ShowToolTip()
    {
        ToolTip("EN_PROTECTED`nMessage:`s#" . Format("{:04X}",msg) . "`nwParam:`s`s#" . Format("{:04X}",wParam))
    }
} ; https://docs.microsoft.com/en-us/windows/desktop/controls/en-protected


/*
    Posted to the window with the keyboard focus when a nonsystem key is pressed.
    A nonsystem key is a key that is pressed when the ALT key is not pressed.
    wParam:
        The virtual-key code of the nonsystem key (https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes).
    lParam:
        The repeat count, scan code, extended-key flag, context code, previous key-state flag, and transition-state flag.
*/
WM_KEYDOWN(wParam, lParam, msg, hWnd)
{ ; Clipboard := Format("0x{:02X}", Ord( "X" ))
    global RE, findtxtdlg, reptxtdlg

    if ( hWnd == RE.hWnd )
    {
        if ( wParam == 0x41 || wParam == 0x45 )  ; A key. E key.
        {
            ; Implements CTRL-A/E to select all the text.
            if ( GetKeyState("CTRL") )
            {
                local scrollpos := RE.GetScrollPos()
                RE.SelectAll()
                RE.SetScrollPos(scrollpos.x, scrollpos.y)
                return 1  ; Overrides the default behavior.
            }
        }

        else if ( wParam == 0x44 )  ; D key.
        {
            ; Implements CTRL-D to duplicate the current line.
            if ( GetKeyState("CTRL") )
            {
                if ( RE.SelectionType() )
                    RE.SetTextRange(RE.GetSelText(), RE.GetSelection().end,, 1)
                else
                    RE.SetTextRange("`n" . RE.GetLineText(), RE.LineIndex2().last,, 1)
                return 1
            }
        }

        else if ( wParam == 0x46 )  ; F key.
        {
            ; Implements CTRL-F to open the text search and replacement dialog box.
            if ( GetKeyState("CTRL") )
            {
                RE_FindText(RE)
                return 1
            }
        }
    }
} ; https://docs.microsoft.com/en-us/windows/desktop/inputdev/wm-keydown


/*
    Retrieves the text from the specified part of a status window.
*/
SB_GetText(SB, Index)
{
    local len := SendMessage(1036, Index-1,,, "ahk_id" . SB.hWnd) & 0xFFFF
    local buf := "", _ := VarSetCapacity(buf, len*2+2, 0)
    SendMessage(1037, Index-1, &buf,, "ahk_id" . SB.hWnd)
    VarSetCapacity(buf, -1)
    return buf
} ; https://docs.microsoft.com/en-us/windows/desktop/controls/sb-gettext


GoogleSearch(Text)
{
    Run("https://www.google.com/search?q=" . URLEncode(RegExReplace(RegExReplace(trim(Text),"[\r\n]",A_Space),"\s+",A_Space)))
}


URLEncode(Url)
{
    static Unreserved := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
    local Buffer := "", Code := VarSetCapacity(Buffer,StrPut(Url,"UTF-8")) . StrPut(Url,&B uffer,"UTF-8")
    while ( Code := NumGet(&Buffer+A_Index-1,"UChar") )
        Encoded .= InStr(Unreserved,Chr(Code)) ? Chr(Code) : Format("%{:02X}",Code)
    return Encoded
} ; https://github.com/flipeador/Library-AutoHotkey/blob/master/crt/Url.ahk


GetUrlCaret(ByRef Text, Caret := 1)
{
    local arr := [ 0, "", Text . A_Space ]

    while ( arr[1] := RegExMatch(arr[3],"i)((ftp|http(s|))\://|www\.)[\w]+",,arr[1]+1) )
    {
        arr[2] := RTrim(SubStr(arr[3],arr[1], RegExMatch(arr[3],"[^\w\./:\?&=\-_~\+\=\$@]",,arr[1])-arr[1]), "./:;?@&=+$,{|^[``")
        if ( caret >= arr[1] && caret <= arr[1] + StrLen(arr[2]) )
            return arr[2]
    }

    return ""
} ; https://github.com/flipeador/Library-AutoHotkey/blob/master/str/url.ahk


PixelToHimetric(Pixel, DPI := 0)
{
    return ( Pixel * 2.54 / ( DPI ? DPI : A_ScreenDPI ) ) * 1000
} ; https://github.com/flipeador/Library-AutoHotkey/blob/master/math/himetric_pixel.ahk
