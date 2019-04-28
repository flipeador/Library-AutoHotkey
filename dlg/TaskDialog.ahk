/*
    Creates, displays, and operates a task dialog. This function can register a callback function to receive notification messages.
    The task dialog contains application-defined icons, messages, title, verification check box, command links, push buttons, and radio buttons.
    Parameters:
        Owner:
            The Gui object or handle to the owner window. This parameter can be zero.
            If this parameter is -1, the dialog is always on top.
        Content:
            The text to be used for the dialog's primary content.
            This parameter can be a pointer to a null terminated string. A null pointer means no content.
        Title:
            The text to be used for the task dialog title. An empty string means the current value of A_ScriptName.
            You can specify a subtitle in a new line. An empty string means no subtitle.
        Options:
            An object with options to further customize the dialog. The object can contain the following keys.
            ExpandedInfo:
                The text to be used for displaying additional information.
            ExpandedCtrlText:
                The text to be used to label the button for collapsing the expandable information.
            CollapsedCtrlText:
                The text to be used to label the button for expanding the expandable information.
            MainIcon:
                The icon that is to be displayed in the task dialog. This parameter can be a predefined icon value or a HICON.
            Footer:
                The text to be used in the footer area of the task dialog.
            FooterIcon:
                The icon to be displayed in the footer area of the task dialog. This parameter can be a predefined icon value or a HICON.
            Buttons:
                Specifies the push common buttons displayed in the task dialog. The first button in the dialog will be the default.
                This parameter must be a string with one or more of the following words.
                OK       0x0001  TDCBF_OK_BUTTON           The task dialog contains the push button: OK.
                YES      0x0002  TDCBF_YES_BUTTON          The task dialog contains the push button: Yes.
                NO       0x0004  TDCBF_NO_BUTTON           The task dialog contains the push button: No.
                CANCEL   0x0008  TDCBF_CANCEL_BUTTON       The task dialog contains the push button: Cancel. If this button is specified, the task dialog will respond to typical cancel actions (Alt-F4 and Escape).
                RETRY    0x0010  TDCBF_RETRY_BUTTON        The task dialog contains the push button: Retry.
                CLOSE    0x0020  TDCBF_CLOSE_BUTTON        The task dialog contains the push button: Close.
            CLButtons:
                An array of strings that specifies the custom buttons that are to be displayed in the task dialog. The first button in the dialog will be the default.
            DefButton:
                The default button for the task dialog. The first button in the dialog will be the default.
                The first custom button has ID 1, the second ID 2, etc.
                For common buttons, specify one of the following words: OK, YES, NO, CANCEL, RETRY or CLOSE.
            RButtons:
                An array of strings that specified the radio buttons that are to be displayed in the task dialog. The first button in the array is selected by default.
            DefRButton:
                The button ID of the radio button that is selected by default. The first button in the dialog will be the default.
                The first radio button has ID 1, the second ID 2, etc. If zero is specified, no radio button is checked.
            Checkbox:
                The text to be used to label the verification checkbox.
            Callback:
                An application-defined callback function object. The function receives 5 parameters: hWnd, Msg, wParam, lParam and RefData.
                Reference: https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nc-commctrl-pftaskdialogcallback.
            CallbackData:
                Application-defined reference data. This value is defined by the caller. It can be any type of data.
                This value is passed in the 'RefData' parameter of the callback function. By default it is zero.
            Width:
                The width of the task dialog's client area, in dialog units. If 0, the task dialog manager will calculate the ideal width.
            Timeout:
                Timeout, in milliseconds, to have the dialog close automatically if the user has not closed it within the specified time.
                This value must be an integer greater than zero.
                Once the time has passed, WinClose is called, this makes the Cancel button the chosen option.
                ErrorLevel is set to 1 if the timeout has been reached; Otherwise it is zero.
                'Options.Timeout' has no effect if 'Options.Callback' is a pointer.
            ProgressBar:
                Receives an object with the following keys.
                SetPos      A function object that allows set the current position of the progress bar.
                            Usage: Options.ProgressBar.SetPos.Call(Pos).
        Flags:
            Specifies the behavior of the task dialog. This parameter can be a combination of flags from the following group:
            0x0001  TDF_ENABLE_HYPERLINKS               Enables hyperlink processing for the strings specified in 'Content', 'ExpandedInfo' and 'Footer'.
                                                        Usage: <A HREF="executablestring">Hyperlink Text</A>.
            0x0008  TDF_ALLOW_DIALOG_CANCELLATION       Indicates that the dialog should be able to be closed using Alt-F4, Escape, and the title bar's close button even if no cancel button is specified.
            0x0010  TDF_USE_COMMAND_LINKS               Indicates that the custom buttons are to be displayed as command links (using a standard task dialog glyph) instead of push buttons.
                                                        When using command links, all characters up to the first new line character in the pszButtonText member will be treated as the command link's main text, and the remainder will be treated as the command link's note.
            0x0040  TDF_EXPAND_FOOTER_AREA              Indicates that the expanded information is displayed at the bottom of the dialog's footer area instead of immediately after the dialog's content.
            0x0080  TDF_EXPANDED_BY_DEFAULT             Indicates that the expanded information is displayed by default when the dialog is initially displayed.
            0x0100  TDF_VERIFICATION_FLAG_CHECKED       Indicates that the verification checkbox is checked by default when the dialog is initially displayed.
            0x0200  TDF_SHOW_PROGRESS_BAR               Indicates that a Progress Bar is to be displayed.
            0x0400  TDF_SHOW_MARQUEE_PROGRESS_BAR       Indicates that an Marquee Progress Bar is to be displayed.
            0x0800  TDF_CALLBACK_TIMER                  Indicates that the task dialog's callback is to be called approximately every 200 milliseconds.
            0x1000  TDF_POSITION_RELATIVE_TO_WINDOW     Indicates that the task dialog is positioned (centered) relative to the window specified by 'Owner'.
                                                        By default the task dialog is positioned (centered) relative to the monitor.
            0x2000  TDF_RTL_LAYOUT                      Indicates that text is displayed reading right to left.
            0x4000  TDF_NO_DEFAULT_RADIO_BUTTON         Indicates that no default radio button will be selected.
            0x8000  TDF_CAN_BE_MINIMIZED                Indicates that the task dialog can be minimized.
            By default the following flags apply: TDF_ALLOW_DIALOG_CANCELLATION and TDF_POSITION_RELATIVE_TO_WINDOW.
    Return value:
        If the function was successful, it returns an object with the following keys:
            Button:
                Receives the identifier of the button that was pressed.
                If a common button was pressed, it is one of the following words: OK, YES, NO, CANCEL, RETRY or CLOSE.
            Radio:
                Receives the identifier of the radio button that is checked.
            Checkbox:
                Receives the state of the verification checkbox.
        If the function was not successful, throws an exception.
            0x8007000E  E_OUTOFMEMORY          There is insufficient memory to complete the operation.
            0x80070057  E_INVALIDARG           One or more arguments are not valid.
            0x80004005  E_FAIL                 The operation failed. Unspecified failure.
    Remarks:
        If incorrect data has been detected, it returns an exception.
    Predefined icon values: 
        "?"    0x7F02  IDI_QUESTION             Question mark icon.
        "s"    0xFFFC  TD_SHIELD_ICON           A shield icon appears in the task dialog.
        "i"    0xFFFD  TD_INFORMATION_ICON      An icon consisting of a lowercase letter 'i' in a circle appears in the task dialog.
        "x"    0xFFFE  TD_ERROR_ICON            A stop-sign icon appears in the task dialog.
        "!"    0xFFFF  TD_WARNING_ICON          An exclamation-point icon appears in the task dialog.    
*/
TaskDialog(Owner, Content, Title := "", Options := "", Flags := 0x1008)
{
    local
    ; ========================================================================================================
    ; ========================================================================================================

    ; --------------------------------------------------------------------------------------------------------
    ; TASKDIALOGCONFIG structure.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/ns-commctrl-_taskdialogconfig.
    ; --------------------------------------------------------------------------------------------------------
    Size := A_PtrSize == 4 ? 96 : 160
    VarSetCapacity(TASKDIALOGCONFIG, Size, 0)
    NumPut(Size, &TASKDIALOGCONFIG, "UInt")

    Icons := {
               "s": 0xFFFC  ; TD_SHIELD_ICON.
             , "i": 0xFFFD  ; TD_INFORMATION_ICON.
             , "x": 0xFFFE  ; TD_ERROR_ICON.
             , "!": 0xFFFF  ; TD_WARNING_ICON.
            ; LoadIcon loads the icon resource only if it has not been loaded; otherwise, it retrieves a handle to the existing resource.
             , "?": DllCall("User32.dll\LoadIconW","Ptr",0,"Ptr",0x7F02,"Ptr")  ; IDI_QUESTION.
             }

    if Options == ""
        Options := { }
    else if Type(Options) !== "Object"
        throw Exception("TaskDialog function: invalid parameter #4.", -1)

    ; TASKDIALOGCONFIG.hwndParent:
    Owner := Type(Owner) == "Gui" ? Owner.hWnd : Owner
    if Type(Owner) !== "Integer"
        throw Exception("TaskDialog function: invalid parameter #1.", -1, "Invalid data type.")
    if Owner && Owner !== -1 && !DllCall("User32.dll\IsWindow", "Ptr", Owner, "Int")
        throw Exception("TaskDialog function: invalid parameter #1.", -1, "The specified window does not exist.")
    NumPut(Owner==-1?0:Owner, &TASKDIALOGCONFIG+4, "Ptr")

    ; TASKDIALOGCONFIG.pszContent:
    if Type(Content) !== "String" && ( Type(Content) !== "Integer" || ( Content && !(Content >> 16) ) )
        throw Exception("TaskDialog function: invalid parameter #2.", -1, Type(Content) == "Integer" ? "Invalid address." : "Invalid data type.")
    Content := Type(Content) == "String" ? Trim(Content,"`s`t`n`r") : Content
    NumPut(Type(Content) == "Integer" ? Content : &Content, &TASKDIALOGCONFIG+(A_PtrSize==4?32:52), "Ptr")

    ; TASKDIALOGCONFIG.pszMainInstruction:
    if Type(Title) !== "String"
        throw Exception("TaskDialog function: invalid parameter #3.", -1, "Invalid data type.")
    SubTitle := InStr(Title,"`n") ? Trim(SubStr(Title,InStr(Title,"`n")+1),"`s`t`n`r") : ""
    NumPut(SubTitle==""?0:&SubTitle, &TASKDIALOGCONFIG+(A_PtrSize==4?28:44), "Ptr")

    ; TASKDIALOGCONFIG.pszWindowTitle:
    Title := Trim(InStr(Title,"`n") ? SubStr(Title,1,InStr(Title,"`n")-1) : Title,"`s`t`n`r")
    Title := Title == "" ? A_ScriptName : Title
    NumPut(&Title, &TASKDIALOGCONFIG+(A_PtrSize==4?20:28), "Ptr")

    ; TASKDIALOGCONFIG.dwCommonButtons:
    if Options.HasKey("Buttons")
    {
        if Type(Options.Buttons) !== "String"
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Buttons: Invalid data type.")
        Buttons := 0
        for k, v in {OK:1,YES:2,NO:4,CANCEL:8,RETRY:0x10,CLOSE:0x20}
            Buttons |= InStr(Options.Buttons,k) ? v : 0
        NumPut(Buttons, &TASKDIALOGCONFIG+(A_PtrSize==4?16:24), "Int")
    }

    ; TASKDIALOGCONFIG.pszVerificationText:
    if Options.HasKey("Checkbox") && Type(Options.Checkbox) !== "String"
        throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Checkbox: Invalid data type.")
    NumPut(Options.HasKey("Checkbox")?Options.GetAddress("Checkbox"):0, &TASKDIALOGCONFIG+(A_PtrSize==4?60:92), "Ptr")

    ; TASKDIALOGCONFIG.pszExpandedInformation:
    if Options.HasKey("ExpandedInfo") && Type(Options.ExpandedInfo) !== "String"
        throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.ExpandedInfo: Invalid data type.")
    NumPut(Options.HasKey("ExpandedInfo")?Options.GetAddress("ExpandedInfo"):0, &TASKDIALOGCONFIG+(A_PtrSize==4?64:100), "Ptr")

    ; TASKDIALOGCONFIG.pszExpandedControlText:
    if Options.HasKey("ExpandedCtrlText") && Type(Options.ExpandedCtrlText) !== "String"
        throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.ExpandedCtrlText: Invalid data type.")
    NumPut(Options.HasKey("ExpandedCtrlText")?Options.GetAddress("ExpandedCtrlText"):0, &TASKDIALOGCONFIG+(A_PtrSize==4?68:108), "Ptr")

    ; TASKDIALOGCONFIG.pszCollapsedControlText:
    if Options.HasKey("CollapsedCtrlText") && Type(Options.CollapsedCtrlText) !== "String"
        throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.CollapsedCtrlText: Invalid data type.")
    NumPut(Options.HasKey("CollapsedCtrlText")?Options.GetAddress("CollapsedCtrlText"):0, &TASKDIALOGCONFIG+(A_PtrSize==4?72:116), "Ptr")

    ; TASKDIALOGCONFIG.hMainIcon:
    if Options.HasKey("MainIcon")
    {
        if Type(Options.MainIcon) !== "Integer" && (Type(Options.MainIcon) !== "String" || !RegExMatch(Options.MainIcon,"^(\?|s|i|x|!)$"))
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.MainIcon: " . (Type(Options.MainIcon)=="String"?"Invalid icon.":"Invalid data type."))
        Options.MainIcon := Options.MainIcon == "?" ? Icons[Options.MainIcon] : Options.MainIcon
        Flags |= Type(Options.MainIcon) == "Integer" ? 0x0002 : 0  ; TDF_USE_HICON_MAIN = 0x0002.
        NumPut(Flags&2?Options.MainIcon:Icons[Options.MainIcon], &TASKDIALOGCONFIG+(A_PtrSize==4?24:36), "Ptr")
    }

    ; TASKDIALOGCONFIG.pszFooter:
    if Options.HasKey("Footer")
    {
        if Type(Options.Footer) !== "String"
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Footer: Invalid data type.")

        if StrLen(Options.Footer)
        {
            NumPut(Options.HasKey("Footer")?Options.GetAddress("Footer"):0, &TASKDIALOGCONFIG+(A_PtrSize==4?80:132), "Ptr")

            ; TASKDIALOGCONFIG.hFooterIcon:
            if Options.HasKey("FooterIcon")
            {
                if Type(Options.FooterIcon) !== "Integer" && (Type(Options.FooterIcon) !== "String" || !RegExMatch(Options.FooterIcon,"^(\?|s|i|x|!)$"))
                    throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.FooterIcon: " . (Type(Options.FooterIcon)=="String"?"Invalid icon.":"Invalid data type."))
                Options.FooterIcon := Options.FooterIcon == "?" ? Icons[Options.FooterIcon] : Options.FooterIcon
                Flags |= Type(Options.FooterIcon) == "Integer" ? 0x0004 : 0  ; TDF_USE_HICON_FOOTER = 0x0004.
                NumPut(Flags&4?Options.FooterIcon:Icons[Options.FooterIcon], &TASKDIALOGCONFIG+(A_PtrSize==4?76:124), "Ptr")
            }
        }
    }

    ; TASKDIALOGCONFIG.pButtons:
    Count := 0, Offset := -A_PtrSize
    if Options.HasKey("CLButtons")
    {
        VarSetCapacity(TASKDIALOG_BUTTON, (4 + A_PtrSize) * Min(100,Options.CLButtons.Count()))
        loop Options.CLButtons.Count()
        {
            if Type(Options.CLButtons[A_Index]) == "String"
            {
                NumPut(99+(++Count), &TASKDIALOG_BUTTON+A_PtrSize*(Count-1)+4*(Count-1), "Int")                       ; nButtonID.
                NumPut(Options.CLButtons.GetAddress(A_Index), &TASKDIALOG_BUTTON+A_PtrSize*(Count-1)+4*Count, "Ptr")  ; pszButtonText.
            }
        }
        until Count == 100
        NumPut(&TASKDIALOG_BUTTON, &TASKDIALOGCONFIG+(A_PtrSize==4?40:64), "Ptr")
    }

    ; TASKDIALOGCONFIG.cButtons:
    NumPut(Count, &TASKDIALOGCONFIG+(A_PtrSize==4?36:60), "UInt")

    ; TASKDIALOGCONFIG.nDefaultButton:
    if Options.HasKey("DefButton")
    {
        if Type(Options.DefButton) !== "String" && Type(Options.DefButton) !== "Integer"
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.DefButton: Invalid data type.")
        if Type(Options.DefButton) == "String" && !RegExMatch(Options.DefButton,"i)^(OK|YES|NO|CANCEL|RETRY|CLOSE)$")
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.DefButton: Unknown button name.")
        if Type(Options.DefButton) == "Integer" && ( Options.DefButton < 1 || Options.DefButton > Count )
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.DefButton: Invalid button ID.")
        DefButton := Type(Options.DefButton) == "String" ? {OK:1,YES:6,NO:7,CANCEL:2,RETRY:4,CLOSE:8}[Options.DefButton] : 99+Options.DefButton
        NumPut(DefButton, &TASKDIALOGCONFIG+(A_PtrSize==4?44:72), "Int")
    }

    ; TASKDIALOGCONFIG.pRadioButtons:
    Count := 0, Offset := -A_PtrSize
    if Options.HasKey("RButtons")
    {
        VarSetCapacity(TASKDIALOG_RBUTTON, (4 + A_PtrSize) * Min(100,Options.RButtons.Count()))
        loop Options.RButtons.Count()
        {
            if Type(Options.RButtons[A_Index]) == "String"
            {
                NumPut(199+(++Count), &TASKDIALOG_RBUTTON+A_PtrSize*(Count-1)+4*(Count-1), "Int")                      ; nButtonID.
                NumPut(Options.RButtons.GetAddress(A_Index), &TASKDIALOG_RBUTTON+A_PtrSize*(Count-1)+4*Count, "Ptr")  ; pszButtonText.
            }
        }
        until Count == 100
        NumPut(&TASKDIALOG_RBUTTON, &TASKDIALOGCONFIG+(A_PtrSize==4?52:80), "Ptr")
    }
   
    ; TASKDIALOGCONFIG.cRadioButtons:
    NumPut(Count, &TASKDIALOGCONFIG+(A_PtrSize==4?48:76), "UInt")

    ; TASKDIALOGCONFIG.nDefaultRadioButton:
    if Options.HasKey("DefRButton") && ( Type(Options.DefRButton) !== "Integer" || Options.DefRButton < 0 || Options.DefRButton > Count )
        throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.DefRButton: " . (Type(Options.DefRButton) == "Integer" ? "Invalid button ID." : "Invalid data type."))
    NumPut(Options.HasKey("DefRButton")?199+Options.DefRButton:1, &TASKDIALOGCONFIG+(A_PtrSize==4?56:88), "Int")
    Flags |= Options.HasKey("DefRButton") && !Options.DefRButton ? 0x4000 : 0  ; TDF_NO_DEFAULT_RADIO_BUTTON = 0x4000.

    ; TASKDIALOGCONFIG.pfCallback:
    Callback := { 
                  Timeout: 0
                , RefData: 0
                , Pointer: CallbackCreate("TaskDialogCallbackProc")
                , FuncObj: 0
                , hDialog: 0
                , TimerFn: 0
                , Owner  : Owner
                , hPB    : 0  ; Progress Bar.
                }
    NumPut(Callback.Pointer, &TASKDIALOGCONFIG+(A_PtrSize==4?84:140), "Ptr")

    if Options.HasKey("Callback")
    {
        if Type(Options.Callback) !== "Func"
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Callback: Invalid data type.")
        if Options.Callback.MaxParams < 5
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Callback: The callback function requires 5 parameters.")
        Callback.FuncObj := Options.Callback
        if Options.HasKey("CallbackData")
            Callback.RefData := Options.CallbackData
    }

    ; TASKDIALOGCONFIG.lpCallbackData:
    NumPut(&Callback, &TASKDIALOGCONFIG+(A_PtrSize==4?88:148), "Ptr")

    ; TASKDIALOGCONFIG.cxWidth:
    if Options.HasKey("Width")
    {
        if Type(Options.Width) !== "Integer"
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Width: Invalid data type.")
        if Options.Width < 0
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Width: Invalid value.")
        NumPut(Options.Width, &TASKDIALOGCONFIG+(A_PtrSize==4?92:156), "UInt")
    }

    ; TASKDIALOGCONFIG.dwFlags:
    NumPut(Flags, &TASKDIALOGCONFIG+(A_PtrSize==4?12:20), "UInt")
    
    ; Timeout:
    if Options.HasKey("Timeout")
    {
        if Type(Options.Timeout) !== "Integer"
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Timeout: Invalid data type.")
        if Options.Timeout < 1
            throw Exception("TaskDialog function: invalid parameter #4.", -1, "Options.Timeout: Invalid value.")
        Callback.Timeout := Options.Timeout
        Callback.TimerFn := () => WinClose("ahk_id" . Callback.hDialog)
    }

    ; Progress Bar:
    if Flags & 0x0200  ; TDF_SHOW_PROGRESS_BAR.
    {
        Options.ProgressBar := {}
        ; https://docs.microsoft.com/en-us/windows/desktop/controls/pbm-setpos.
        Options.ProgressBar.SetPos := (pos) => SendMessage(0x402, pos,, Callback.hPB)
    }

    ; --------------------------------------------------------------------------------------------------------
    ; TaskDialogIndirect function.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nf-commctrl-taskdialogindirect.
    ; --------------------------------------------------------------------------------------------------------
    Button := Radio := Checkbox := 0
    R := DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TASKDIALOGCONFIG, "IntP", Button, "IntP", Radio, "IntP", Checkbox, "UInt")

    if !Options.HasKey("Callback") || Type(Options.Callback) ~= "^(String|Func)$"
        CallbackFree(NumGet(&TASKDIALOGCONFIG+(A_PtrSize==4?84:140),"Ptr"))

    if R
        throw Exception("TaskDialog function.", -1, Format("Error 0x{:08X}.",R))

    ; ========================================================================================================
    ; ========================================================================================================
    Buttons := { 1:"OK" , 6:"YES" , 7:"NO" , 2:"CANCEL" , 4:"RETRY" , 8:"CLOSE" }
    Button  := Buttons.HasKey(Button) ? Buttons[Button] : Button-99

    return { Button:Button , Radio:Radio?Radio-199:Radio , Checkbox:Checkbox }
}





/*
    PFTASKDIALOGCALLBACK callback function.
*/
TaskDialogCallbackProc(hWnd, Msg, wParam, lParam, RefData)
{
    local

    Callback := Object(RefData)

    if Msg == 0  ; TDN_CREATED.
    {
        DetectHiddenWindows("On")
        Callback.hDialog := hWnd
        if Callback.TimerFn
            SetTimer(Callback.TimerFn, -Callback.Timeout)
        if Callback.Owner == -1
            DllCall("User32.dll\SetWindowPos", "Ptr", hWnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x403, "Int")
        Callback.hPB := ControlGetHwnd("msctls_progress321", "ahk_id" . hWnd)  ; DllCall("User32.dll\FindWindowExW", "Ptr", hWnd, "Ptr", 0, "Str", "msctls_progress32", "Ptr", 0, "Ptr")
        Msg := "TDN_CREATED"
    }

    else if Msg == 1  ; TDN_NAVIGATED.
    {
        Msg := "TDN_NAVIGATED"
    }

    else if Msg == 2  ; TDN_BUTTON_CLICKED.
    {
        wParam := wParam=1?"OK":wParam=2?"CANCEL":wParam=4?"RETRY":wParam=6?"YES":wParam=7?"NO":wParam=8?"CLOSE":wParam-99
        Msg := "TDN_BUTTON_CLICKED"
    }

    else if Msg == 3  ; TDN_HYPERLINK_CLICKED.
    {
        lParam := StrGet(lParam,"UTF-16")
        Msg := "TDN_HYPERLINK_CLICKED"
    }

    else if Msg == 4  ; TDN_TIMER.
    {
        ; wParam = Milliseconds since dialog created or timer reset.
        Msg := "TDN_TIMER"
    }

    else if Msg == 5  ; TDN_DESTROYED.
    {
        if Callback.TimerFn
            SetTimer(Callback.TimerFn, "Delete")
        Msg := "TDN_DESTROYED"
    }

    else if Msg == 6  ; TDN_RADIO_BUTTON_CLICKED.
    {
        wParam -= 199
        Msg := "TDN_RADIO_BUTTON_CLICKED"
    }

    else if Msg == 7  ; TDN_DIALOG_CONSTRUCTED.
    {
        Msg := "TDN_DIALOG_CONSTRUCTED"
    }

    else if Msg == 8  ; TDN_VERIFICATION_CLICKED.
    {
        ; wParam = 1 if checkbox checked, 0 if not, lParam is unused and always 0.
        Msg := "TDN_VERIFICATION_CLICKED"
    }

    else if Msg == 9  ; TDN_HELP.
    {
        Msg := "TDN_HELP"
    }

    else if Msg == 10  ; TDN_EXPANDO_BUTTON_CLICKED.
    {
        ; wParam = 0 (dialog is now collapsed), wParam != 0 (dialog is now expanded).
        Msg := "TDN_EXPANDO_BUTTON_CLICKED"
    }

    r := Callback.FuncObj ? Callback.FuncObj.Call(hWnd,Msg,wParam,lParam,Callback.RefData) : 0

    if !Callback.FuncObj || Type(r) !== "Integer"
    {
        if Msg == "TDN_HYPERLINK_CLICKED"
        {
            Run(lParam)
        }
    }

    return Type(r) == "Integer" ? r : 0
}  ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nc-commctrl-pftaskdialogcallback





/*  EXAMPLE - EXAMPLE -  EXAMPLE - EXAMPLE -  EXAMPLE -  EXAMPLE -  EXAMPLE -  EXAMPLE
Options              := { }
Options.Buttons      := "OK|YES|NO|CANCEL|RETRY|CLOSE"
Options.CLButtons    := ["Custom button #1", "Custom button #2`nCommand link's note."]
Options.DefButton    := "CLOSE"
Options.RButtons     := ["Radio button #1", "Radio button #2"]
Options.DefRButton   := 2
Options.Checkbox     := "Verification checkbox."
Options.ExpandedInfo := "Expanded information."
Options.Footer       := "<A HREF=`"notepad.exe`">Footer text</A>."
Options.FooterIcon   := "i"
Options.MainIcon     := "s"
Options.Callback     := Func("Callback")
Options.CallbackData := Options  ; RefData.
R := TaskDialog(-1, "Content", "Title`nSubtitle", Options, 0x1219)
MsgBox("Button: " . R.Button . "`nRadio: " . R.Radio . "`nCheckbox: " . R.Checkbox)
ExitApp

Callback(hWnd, Msg, wParam, lParam, RefData)
{
    local

    if Msg == "TDN_CREATED"
    {
        ; Sets the current position for a progress bar and redraws the bar to reflect the new position.
        RefData.ProgressBar.SetPos.Call(50)
    }

    else if Msg == "TDN_BUTTON_CLICKED"
    {
        if wParam == 1 || wParam == 2
        {
            TaskDialog(hWnd, "CLButton: #" . wParam, "`n" . Msg)
            return 1
        }
    }
}
*/
