; The Taskbar.
; https://docs.microsoft.com/en-us/windows/win32/shell/taskbar#managing-taskbar-buttons

; ITaskbarList4 interface.
; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-itaskbarlist4
global g_ITaskbarList4 := 0
global g_ITaskbarList4_RefCount := 0





/*
    Initializes the taskbar list object.
    Return value:
        If the function succeeds, the return value is the current reference count.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        This function must be called to start using some of these functions.
        The TaskbarShutdown function must be called when you have finished using these functions.
*/
TaskbarStartup()
{
    if (g_ITaskbarList4_RefCount == 0)
    {
        g_ITaskbarList4 := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}", "{C43DC798-95D1-4BEA-9030-BB99E2983A1A}")
        ComCall(3, g_ITaskbarList4)  ; ITaskbarList::HrInit method.
    }
    return ++g_ITaskbarList4_RefCount
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist-hrinit





/*
    Cleans up resources allocated with a previous call to the TaskbarStartup function.
    Return value:
        Returns the current reference count.
    Remarks:
        Each call to the TaskbarStartup function should be paired with a call to the TaskbarShutdown function.
*/
TaskbarShutdown()
{
    if (g_ITaskbarList4_RefCount && !(--g_ITaskbarList4_RefCount))
    {
        ObjRelease(g_ITaskbarList4)
        g_ITaskbarList4 := 0
    }
    return g_ITaskbarList4_RefCount
}





/*
    Adds an item to the taskbar.
    Parameters:
        hWnd:
            A handle to the window to be added to the taskbar.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        Any type of window can be added to the taskbar, but it is recommended that the window at least have the WS_CAPTION style.
        Any window added with this method must be removed with the TaskbarDeleteTab function when the added window is destroyed.
*/
TaskbarAddTab(hWnd)
{
    return ComCall(4, g_ITaskbarList4, "Ptr", hWnd)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist-addtab





/*
    Deletes an item from the taskbar.
    Parameters:
        hWnd:
            A handle to the window to be deleted from the taskbar.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
*/
TaskbarDeleteTab(hWnd)
{
    return ComCall(5, g_ITaskbarList4, "Ptr", hWnd)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist-deletetab





/*
    Activates an item on the taskbar. The window is not actually activated; the window's item on the taskbar is merely displayed as active.
    Parameters:
        hWnd:
            A handle to the window on the taskbar to be displayed as active.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
*/
TaskbarActivateTab(hWnd)
{
    return ComCall(6, g_ITaskbarList4, "Ptr", hWnd)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist-activatetab





/*
    Marks a taskbar item as active but does not visually activate it.
    Parameters:
        hWnd:
            A handle to the window to be marked as active.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        The TaskbarSetActiveAlt function marks the item associated with «hWnd» as the currently active item for the window's process without changing the pressed state of any item.
        Any user action that would activate a different tab in that process will activate the tab associated with hwnd instead.
        The active state of the window's item is not guaranteed to be preserved when the process associated with hwnd is not active.
        To ensure that a given tab is always active, call TaskbarSetActiveAlt whenever any of your windows are activated. Calling TaskbarSetActiveAlt with a zero «hWnd» clears this state.
*/
TaskbarSetActiveAlt(hWnd)
{
    return ComCall(7, g_ITaskbarList4, "Ptr", hWnd)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist-setactivealt





/*
    Displays or updates a progress bar hosted in a taskbar button to show the specific percentage completed of the full operation.
    Parameters:
        hWnd:
            The handle of the window whose associated taskbar button is being used as a progress indicator.
        Completed:
            An application-defined value that indicates the proportion of the operation that has been completed at the time the function is called.
        Total:
            An application-defined value that specifies the value «Completed» will have when the operation is complete.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        When progress is complete, the application must call TaskbarSetProgressState with the TBPF_NOPROGRESS flag to dismiss the progress bar.
*/
TaskbarSetProgressValue(hWnd, Completed, Total := 100)
{
    return ComCall(9, g_ITaskbarList4, "Ptr", hWnd, "Int64", Completed, "Int64", Total)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist3-setprogressvalue





/*
    Sets the type and state of the progress indicator displayed on a taskbar button.
    Parameters:
        hWnd:
            The handle of the window in which the progress of an operation is being shown.
            This window's associated taskbar button will display the progress bar.
        State:
            Flags that control the current state of the progress button. Specify only one of the following flags; all states are mutually exclusive of all others.
            0  TBPF_NOPROGRESS       Stops displaying progress and returns the button to its normal state. Use this flag to dismiss the progress bar when the operation is complete or canceled.
            1  TBPF_INDETERMINATE    The progress indicator does not grow in size, but cycles repeatedly along the length of the taskbar button.
                                     This indicates activity without specifying what proportion of the progress is complete.
                                     Progress is taking place, but there is no prediction as to how long the operation will take.
            2  TBPF_NORMAL           The progress indicator grows in size from left to right in proportion to the estimated amount of the operation completed.
                                     This is a determinate progress indicator; a prediction is being made as to the duration of the operation.
            4  TBPF_ERROR            The progress indicator turns red to show that an error has occurred in one of the windows that is broadcasting progress. This is a determinate state.
                                     If the progress indicator is in the indeterminate state, it switches to a red determinate display of a generic percentage not indicative of actual progress.
            8  TBPF_PAUSED           The progress indicator turns yellow to show that progress is currently stopped in one of the windows but can be resumed by the user.
                                     No error condition exists and nothing is preventing the progress from continuing. This is a determinate state.
                                     If the progress indicator is in the indeterminate state, it switches to a yellow determinate display of a generic percentage not indicative of actual progress.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        Progress bar information is not shown in high contrast color schemes to guarantee that no accessibility needs are compromised.
        Note that a call to TaskbarSetProgressValue will switch a progress indicator currently in an indeterminate mode to a normal display and clear the TBPF_INDETERMINATE flag.
*/
TaskbarSetProgressState(hWnd, State)
{
    return ComCall(10, g_ITaskbarList4, "Ptr", hWnd, "Int", State)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist3-setprogressstate





/*
    A combination of TaskbarSetProgressValue and TaskbarSetProgressState functions.
    Parameters:
        hWnd:
            See the TaskbarSetProgressValue and TaskbarSetProgressState functions.
        Progress:
            A string that specifies the state and/or a progress value.
            For example: 15, "75", "Normal", "Paused 50", "Error 0".
        Total:
            See the TaskbarSetProgressValue function.
            This parameter is only meaningful if «Progress» contains a number.
    Return value:
        The return value for this function is not used.
        If the function fails, an exception is thrown describing the error.
*/
TaskbarSetProgress(hWnd, Progress, Total := 100)
{
    static States := {NoProgress:0, Indeterminate:1, Normal:2, Error:4, Paused:8}
    local
    if StrLen(Value:=RegExReplace(Progress,"[^\d]"))
        TaskbarSetProgressValue(hWnd, Value, Total)
    if StrLen(State:=RegExReplace(Progress,"i)[^a-z]"))
        TaskbarSetProgressState(hWnd, States.%State%)
} ; TaskbarSetProgressValue + TaskbarSetProgressState





/*
    Applies an overlay to a taskbar button to indicate application status or a notification to the user.
    Parameters:
        hWnd:
            The handle of the window whose associated taskbar button receives the overlay.
            This handle must belong to a calling process associated with the button's application and must be a valid HWND or the call is ignored.
        hIcon:
            The handle of an icon to use as the overlay.
            This should be a small icon, measuring 16x16 pixels at 96 dpi.
            If an overlay icon is already applied to the taskbar button, that existing overlay is replaced.
            --------------------------------------------
            This value can be zero. How a zero value is handled depends on whether the taskbar button represents a single window or a group of windows.
            • If the taskbar button represents a single window, the overlay icon is removed from the display.
            • If the taskbar button represents a group of windows and a previous overlay is still available (received earlier than the current overlay, but not yet freed by a NULL value), then that previous overlay is displayed in place of the current overlay.
            --------------------------------------------
            It is the responsibility of the calling application to free the icon when it is no longer needed.
            This can generally be done after you call TaskbarSetOverlayIcon because the taskbar makes and uses its own copy of the icon.
        Description:
            A string that provides an alt text version of the information conveyed by the overlay, for accessibility purposes.
            This parameter can be a string or a pointer to a null-terminated string.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, an exception is thrown describing the error.
    Remarks:
        To display an overlay icon, the taskbar must be in the default large icon mode.
        If the taskbar is configured through Taskbar and Start Menu Properties to show small icons, overlays cannot be applied and calls to this method are ignored.
        -------------------------------------------------------------------------------------------
        If Windows Explorer shuts down unexpectedly, overlays are not restored when Windows Explorer is restored.
        The application should wait to receive the TaskbarButtonCreated message that indicates that Windows Explorer has restarted and the taskbar button has been re-created, and then call TaskbarSetOverlayIcon again to reapply the overlay.
*/
TaskbarSetOverlayIcon(hWnd, hIcon, Description := 0)
{
    return ComCall(18, g_ITaskbarList4, "UPtr", hWnd
                                      , "UPtr", hIcon
                                      , "UPtr", Type(Description)=="String" ? &Description : Description)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist3-setoverlayicon





/*
    Retrieves the Toolbar control handle belonging to the notification tray.
*/
TaskbarGetTrayToolbar()
{
    local
    while (hToolbar := ControlGetHwnd("ToolbarWindow32" . A_Index, "ahk_class Shell_TrayWnd"))
        if (WinGetClass(DllCall("User32.dll\GetParent","Ptr",hToolbar,"Ptr")) == "SysPager")
            break
    return [hToolbar,ControlGetHwnd("ToolbarWindow321","ahk_class NotifyIconOverflowWindow")]
}





/* SIN TERMINAR POR FALTA DE INTERÉS =P
GetTrayInfo()
{
    ; recuperamos el identificador del control Toolbar
    Local hToolbar1 := GetTrayToolbar()    ; corresponde al Toolbar que contiene los iconos visible
        , hToolbar2 := ControlGetHwnd('ToolbarWindow321', 'ahk_class NotifyIconOverflowWindow')    ; Toolbar que contiene los iconos ocultos
    If (!hToolbar1)
        Return -1

    Local ProcessId := WinGetPID('ahk_id' . hToolbar1)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx
        ; abrimos el proceso para realizar operaciones de lectura y escritura en su memoria
        , hProcess  := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x0010|0x0020|0x0008, 'Int', FALSE, 'UInt', ProcessId, 'Ptr')    ; PROCESS_VM_READ|PROCESS_VM_WRITE|PROCESS_VM_OPERATION
    If (!hProcess)
        Return -2

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366890(v=vs.85).aspx
    ; sizeof(struct TBBUTTON) = x32: 20 | x64: 32
    Local sizeof_TBBUTTON := A_Is64bitOS ? 32 : 20
        , pTBBUTTON := DllCall('Kernel32.dll\VirtualAllocEx', 'Ptr', hProcess, 'UPtr', 0, 'UPtr', sizeof_TBBUTTON, 'UInt', 0x1000, 'UInt', 0x0004, 'UPtr')    ; MEM_COMMIT = 0x1000 | PAGE_READWRITE = 0x0004
    If (!pTBBUTTON && DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess) != '*')
        Return -2

    Local TrayInfo  := []
        , TBBUTTON, Data, Buffer, NumberOfBytesRead
    VarSetCapacity(TBBUTTON, sizeof_TBBUTTON), VarSetCapacity(Data, A_Is64bitOS ? 32 : 24), VarSetCapacity(Buffer, 256)
    For Each, hToolbar in hToolbar2 ? [hToolbar1, hToolbar2] : [hToolbar1]
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787297(v=vs.85).aspx
        ; recupera la cantidad de iconos en el control Toolbar
        Local ButtonCount := DllCall('User32.dll\SendMessageW', 'Ptr', hToolbar, 'UInt', 0x0418, 'Ptr', 0, 'Ptr', 0)    ; TB_BUTTONCOUNT := 0x0418
        If (!ButtonCount)
            Continue

        Loop (ButtonCount)
        {
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787319(v=vs.85).aspx
            DllCall('User32.dll\SendMessageW', 'Ptr', hToolbar, 'UInt', 0x0417, 'Ptr', A_Index-1, 'UPtr', pTBBUTTON)    ; TB_GETBUTTON := 0x0417

            ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms680553(v=vs.85).aspx
            DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr', hProcess, 'UPtr', pTBBUTTON, 'UPtr', &TBBUTTON, 'UPtr', sizeof_TBBUTTON, 'UPtrP', NumberOfBytesRead)

            ;TrayInfo[A_Index] := {Bitmap : NumGet(&TBBUTTON    , 'Int')
            ;                    , Command: NumGet(&TBBUTTON + 4, 'Int')}

            DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr', hProcess, 'UPtr', NumGet(&TBBUTTON + (A_Is64bitOS ? 24 : 16)), 'UPtr', &Buffer, 'UPtr', 256, 'UPtrP', NumberOfBytesRead)
            msgbox StrGet(&Buffer, 'UTF-16')
        }
    }

    DllCall('Kernel32.dll\VirtualFreeEx', 'Ptr', hProcess, 'UPtr', pTBBUTTON, 'Ptr', 0, 'UInt', 0x8000)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return TrayInfo
}
*/
