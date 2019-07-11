/*
    Creates dialog box that lets the user specify a string to search for and a replacement string, as well as options to control the find and replace operations.
    Parameters:
        RE:
            The RichEdit control object.
        FindText:
            The initial string that is displayed in the search edit control.
        ReplaceText:
            The initial string that is displayed in the Replace With edit control.
    Return value:
        If the function succeeds, the return value is the dialog box gui object.
        If the function fails, the return value is NULL.
    Remarks:
        The input strings are limited to 1024 characters. The funcion only takes in account the first line of text.
        Set the control to read only to disable te replacement options.
        You cannot open more than one dialog per control.
*/
RE_FindText(RE, FindText := 0, ReplaceText := 0)
{
    static list := { }
    static fnc  := { WM_ACTIVATE:0 } ; , WM_MOUSEMOVE:0 }
    local

    if ( RE.Type !== "RichEdit" )
        throw Exception("Function RE_FindText invalid parameter 1.", -1)
    else if ( list.HasKey(RE.hWnd) )
    {
        list[RE.hWnd].Gui.Show()
        return list[RE.hWnd].Gui
    }
    else if ( !RE.GetTextLength() )
        return 0
     
    if ( fnc.WM_ACTIVATE )
        OnMessage(0x06, fnc.WM_ACTIVATE, 0)
    OnMessage(0x06, fnc.WM_ACTIVATE?fnc.WM_ACTIVATE:(fnc.WM_ACTIVATE:=Func("WM_ACTIVATE")), -1)

    ;if ( fnc.WM_MOUSEMOVE )
    ;    OnMessage(0x200, fnc.WM_MOUSEMOVE, 0)
    ;OnMessage(0x200, fnc.WM_MOUSEMOVE?fnc.WM_MOUSEMOVE:fnc.WM_MOUSEMOVE:=Func("WM_MOUSEMOVE"), -1)

    if ( Type(FindText) !== "String" )
        FindText := RE.StreamOut(0x8011)
    if ( Type(ReplaceText) !== "String" )
        ReplaceText := ""

    Gui := GuiCreate("+Owner" . RE.Gui.hWnd, "Find and replace text")
    list[RE.hWnd] := { Gui:Gui, RE:RE }

    Gui.SetFont("s9", "Segoe UI")
    Gui.MarginX := 12
    Gui.MarginY := 14

    Gui.AddText(, "Search string:")
    Gui.AddEdit("y+6 w335 veft r1 limit1024 +0x100", SubStr(StrSplit(FindText,"`n","`r")[1],1,1024))
    Gui.AddText("y+12", "Replace with:")
    Gui.AddEdit("y+6 w335 vert r1 limit1024 +0x100", SubStr(StrSplit(ReplaceText,"`n","`r")[1],1,1024))

    Gui.AddButton("vbws", "Swamp strings")
    Gui.Control["bws"].Move(  "x" . ( 335-Gui.Control["bws"].Pos.W + Gui.MarginX + 1 )
                           . " y" . ( Gui.Control["eft"].Pos.Y + Gui.Control["eft"].Pos.H + 6 )
                           . " h" . ( Gui.Control["ert"].Pos.Y - Gui.Control["eft"].Pos.Y - Gui.Control["eft"].Pos.H - 2*6 )
                           )

    Gui.AddButton("ys w100 vbfn default", "Find next").SetFont("bold")
    Gui.AddButton("y+6 wp vbfp", "Find previous")
    Gui.AddButton("y+12 wp vbrp", "Replace")
    Gui.AddButton("y+6 wp vbra", "Replace all")
    Gui.AddButton("y+12 wp vbcn", "Count")
    Gui.AddButton("y+12 wp vbcl", "Close")

    Gui.AddCheckbox("xm y" . (Gui.Control["ert"].Pos.Y+Gui.Control["ert"].Pos.H+12) . " vcmc section", "Match case")
    Gui.AddCheckbox("y+6 vcmw", "Match whole word only")
    Gui.AddCheckbox("y+6 vcmb", "Match beginning of word only")
    Gui.AddCheckbox("y+6 vcrx", "Regular expression search")

    Gui.AddCheckbox("ys vcsl", "Selection")
    Gui.AddCheckbox("y+6 vcdw checked disabled", "Don't wrap around")
    Gui.AddCheckbox("y+6 vcar", "Close after replace")
    Gui.AddButton("y+6 vcgs h" . (Gui.Control["bws"].Pos.H) . " w" . (Gui.Control["car"].Pos.W), "Goto start")

    Gui.AddStatusBar("vsb", RE.GetTextLength(8) . " characters, " . RE.GetTextLength(16) . " bytes.")

    list[RE.hWnd].sel := { start:0, end:0 }  ; Selection.

    Gui.Control["bws"].OnEvent("Click", "Swamp_Strings")
    Gui.Control["bfn"].OnEvent("Click", "Find_Next")
    Gui.Control["bfp"].OnEvent("Click", "Find_Prev")
    Gui.Control["brp"].OnEvent("Click", "Replace")
    Gui.Control["bra"].OnEvent("Click", "Replace_All")
    Gui.Control["bcn"].OnEvent("Click", (*) => Gui.Control["crx"].Value ? CountRegEx() : Count())
    Gui.Control["bcl"].OnEvent("Click", "Close")
    Gui.Control["csl"].OnEvent("Click", (*) => !Gui.Control["csl"].Value ? 0 : (list[RE.hWnd].sel := RE.GetSelection())
                                            . Gui.Control["sb"].SetText("Selection: Saved at (" . (list[RE.hWnd].sel.start+1) . ";" . (list[RE.hWnd].sel.end+1) . ")."))
    Gui.Control["cmw"].OnEvent("Click", (*) => Gui.Control["cmb"].Enabled := !Gui.Control["cmw"].Value)
    Gui.Control["cmb"].OnEvent("Click", (*) => Gui.Control["cmw"].Enabled := !Gui.Control["cmb"].Value)
    Gui.Control["crx"].OnEvent("Click", "Check_RexEx")
    Gui.Control["cgs"].OnEvent("Click", (*) => RE.SetSelection(0) . Gui.Control["sb"].SetText("Goto: (1;1).") . (Gui.Control["csl"].Enabled:=FALSE) . RE.ScrollCaret())

    Gui.OnEvent("Size", "Size")
    Gui.OnEvent("Escape", (*) => Gui.Show("Minimize"))
    Gui.OnEvent("Close", "Close")

    WinGetPos(X, Y, W, H, "ahk_id" . RE.hWnd)
    Gui.Show("Hide")
    Gui.Show(  "x" . ( X + W - Gui.Pos.W - 5 )
            . " y" . ( Y + H - Gui.Pos.H - 5 )
            )

    return Gui

    ; ----------------------------------------------

    Swamp_Strings(*)
    {
        local find_str := Gui.Control["eft"].Text
        Gui.Control["eft"].Text := Gui.Control["ert"].Text
        Gui.Control["ert"].Text := find_str
    }

    Find_Next(*)
    {
        return Find_PrevNext(TRUE)
    }

    Find_Prev(*)
    {
        return Find_PrevNext(FALSE)
    }

    Find_PrevNext(Down)
    {
        local csel := RE.GetSelection()
        local rng  := { min:csel[Down?"end":"start"], max:-1 }

        if ( Gui.Control["csl"].Value && Gui.Control["csl"].Enabled )
        {
            if ( !list[RE.hWnd].sel.HasKey("started") )
            {
                rng.min := list[RE.hWnd].sel[Down?"start":"end"]
                rng.max := list[RE.hWnd].sel[Down?"end":"start"]
                list[RE.hWnd].sel.started := true
            }
            else
                rng.max := list[RE.hWnd].sel[Down?"end":"start"]
        }
        
        return Gui.Control["crx"].Value ? FindRegEx(rng.min,rng.max) : Find(rng.min,rng.max,Down)
    }

    Find(Min, Max, Flags)
    {
        local find_str := Gui.Control["eft"].Text
        Flags |= (Gui.Control["cmc"].Value?4:0) | (Gui.Control["cmw"].Value?2:0)
        local r := RE.FindText(find_str, Min, Max, Flags)

        if ( !r )
            return NotFound(A_ThisFunc, find_str)

        if ( Gui.Control["cmb"].Value && RE.FindWordBreak(r.min+1,4) !== r.min )
            return Flags & 1 ? Find(r.max,Max,Flags) : Find(r.min,Min,Flags)
        RE.SetSelection(r.min, r.max)
        RE.ScrollCaret()
        Gui.Control["sb"].SetText("Find: Occurrence founded at (" . (r.min+1) . ";" . (r.max+1) . ").")

        return r
    }

    FindRegEx(Min, Max)
    {
        local find_str := Gui.Control["eft"].Text, output
        local r        := RegExMatch(RE.GetTextRange(Min,Max==-1?RE.GetTextLength():Max), find_str, output)

        if ( !r || !output.count() )
            return NotFound(A_ThisFunc, find_str)

        RE.SetSelection(r-1+Min, r-1+Min+StrLen(output[1]))
        RE.ScrollCaret()
        Gui.Control["sb"].SetText("FindRegEx: Occurrence founded at (" . (r+Min) . ";" . (r+Min+StrLen(output[1])) . ").")

        return r
    }

    NotFound(q, find_str)
    {
        DllCall("User32.dll\MessageBeep", "UInt", 0xFFFFFFFF)
        Gui.Control["sb"].SetText(q . ": Can't find the text `"" . find_str . "`".")
        return 0
    }

    Replace(*)
    {
        Enabled(0), RE.ReplaceSel(Gui.Control["ert"].Text, TRUE, TRUE)
        if ( Gui.Control["car"].Value )
            return Close()
        Gui.Control["sb"].SetText("Replace: the occurrence was replaced."), Enabled()
    }

    Replace_All(*)
    {
        local replace_str := Gui.Control["ert"].Text
        local count := Enabled(0,0)
        RE.SetSelection(Gui.Control["csl"].Value && Gui.Control["csl"].Enabled ? RE.GetSelection().start : 0)
        while ( Find_Next() )
            RE.ReplaceSel(replace_str, TRUE, TRUE), ++count
        if ( Gui.Control["car"].Value )
            return Close()
        Gui.Control["sb"].SetText("Replace all: " . count . " occurrences were replaced."), Enabled()
    }

    Count(*)
    {
        local find_str := Gui.Control["eft"].Text
        local rng      := { min:0 }, max := -1, count := 0, msg := " in total." . Enabled(0)
        local Flags    := (Gui.Control["cmc"].Value?4:0) | (Gui.Control["cmw"].Value?2:0)

        if ( Gui.Control["csl"].Value && Gui.Control["csl"].Enabled )
        {
            local sel := RE.GetSelection()
            rng.min := sel.start
            max := sel.end
            msg := " in selection."
        }

        while ( rng := RE.FindText(find_str,rng.min,max,1|Flags) )
        {
            if ( Gui.Control["cmb"].Value && RE.FindWordBreak(rng.min+1,4) !== rng.min )
                continue
            ++count
            rng.min := rng.max
        }

        Gui.Control["sb"].SetText("Count: " . count . " matches" . msg), Enabled()
    }

    CountRegEx(*)
    {
        local msg := Gui.Control["csl"].Value && Gui.Control["csl"].Enabled ? " in selection." : " in total.", count
        local rng := Gui.Control["csl"].Value && Gui.Control["csl"].Enabled ? RE.GetSelection() : { start:0, end:RE.GetTextLength() }
        Enabled(0), RegExReplace(RE.GetTextRange(rng.start,rng.end), Gui.Control["eft"].Text,, count)
        Gui.Control["sb"].SetText("Count: " . count . " matches" . msg), Enabled()
    }

    Check_RexEx(*)
    {
        Gui.Control["cmc"].Enabled := Gui.Control["cmw"].Enabled := Gui.Control["cmb"].Enabled := Gui.Control["bfp"].Enabled := !Gui.Control["crx"].Value
        if ( !Gui.Control["crx"].Value )
        {
            if ( Gui.Control["cmw"].Value )
                Gui.Control["cmb"].Enabled := FALSE
            else if ( Gui.Control["cmb"].Value )
                Gui.Control["cmw"].Enabled := FALSE
            Gui.Control["eft"].Text := RTrim(LTrim(Gui.Control["eft"].Text,"("),")")
        }
        else
            Gui.Control["eft"].Text := (Gui.Control["eft"].Text~="^\("?"":"(") . Gui.Control["eft"].Text . (Gui.Control["eft"].Text~="\)$"?"":")")
    }

    Size(Gui, MinMax, W, H)
    {
        if ( MinMax == -1 )  ; Minimized.
        {
            Gui.Hide()  ; Hide when minimized.
            RE.Gui.Show()
            RE.Ctrl.Focus()
        }
    }

    Close(*)
    {
        list.delete(RE.hWnd)
        if ( !list.count() )
        {
            OnMessage(0x06, fnc.WM_ACTIVATE, fnc.WM_ACTIVATE := 0)
            ;OnMessage(0x200, fnc.WM_MOUSEMOVE, fnc.WM_MOUSEMOVE := 0)
        }
        WinSetTransparent("Off", "ahk_id" . Gui.hWnd)
        DllCall("User32.dll\AnimateWindow", "UPtr", Gui.hWnd, "UInt", 175, "UInt", 0x90000, "Int")
        Gui.Destroy()
        RE.Gui.Show()
        RE.Ctrl.Focus()
    }

    Enabled(State := TRUE, R := "")
    {
        loop parse, "eft0ert0bfn0bfp0brp0bra0bcn0bws0cgs", 0
            Gui.Control[A_LoopField].Enabled := State
        return R
    }

    WM_ACTIVATE(wParam, lParam, Msg, hWnd)
    {
        local handle
        for handle in list
        {
            if ( WinActive("ahk_id" . list[handle].Gui.hWnd) )
            {
                local sel_type := list[handle].RE.SelectionType()
                local options  := list[handle].RE.GetOptions()
                WinSetTransparent(255, "ahk_id" . list[handle].Gui.hWnd)
                list[handle].Gui.Control["csl"].Enabled := !!sel_type

                list[handle].Gui.Control["ert"].Enabled
                := list[handle].Gui.Control["brp"].Enabled
                := list[handle].Gui.Control["bra"].Enabled
                := ! ( options & 0x800 )
            }
            else
            {
                WinSetTransparent(150, "ahk_id" . list[handle].Gui.hWnd)
                list[handle].Gui.Control["csl"].Value
                := ! list[handle].Gui.Control["csl"].Enabled
                := TRUE
            }
        }
    }
    /*
    WM_MOUSEMOVE(wParam, lParam, Msg, hWnd)
    {
        static timer := 0, lp := 0

        if ( lp !== lParam )
        {
            ToolTip()
            lp := lParam

            if ( timer )
                SetTimer(timer, "Delete")
            SetTimer(timer:=func("Timer"), -1000)
            
            Timer()
            {
                local ctrl := GuiCtrlFromHwnd(Hwnd)

                if ( ctrl )
                {
                    local handle
                    for handle in list
                    {
                        if ( list[handle].gui.hwnd == ctrl.gui.hwnd )
                        {
                            if ( ctrl.name == "crx" )
                            {
                                SetTimer("ToolTip", -3000)
                                ToolTip("Perl-compatible regular expression (PCRE).")
                            }
                            break
                        }
                    }
                }
                
                timer := 0
            }
        }
    }
    */
}
