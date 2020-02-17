/*
    Notifies the system of an event that an application has performed.
    An application should use this function if it performs an action that may affect the Shell.
    Parameters:
        EventID:
            Describes the event that has occurred.
            If more than one event is specified, the values contained in the dwItem1 and dwItem2 parameters must be the same, respectively, for all specified events.
        Flags:
            Flags that, when combined bitwise with SHCNF_TYPE, indicate the meaning of the Item1 and Item2 parameters.
        Item1:
            Optional. First event-dependent value.
        Item2:
            Optional. Second event-dependent value.
    Return value:
        The return value for this function is not used.
    Notifies the system that file type associations have been changed:
        SHChangeNotify(0x08000000)  ; SHCNE_ASSOCCHANGED.
*/
SHChangeNotify(EventID, Flags := 0, Item1 := 0, Item2 := 0)
{
    return DllCall("Shell32.dll\SHChangeNotify", "UInt", EventID
                                               , "UInt", Flags
                                               ,  "Ptr", Item1
                                               ,  "Ptr", Item2)
} ; https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shchangenotify





/*
    Retrieves or sets the value of one of the system-wide parameters.
    This function can also update the user profile while setting a parameter.
    Parameters:
        Action:
            The system-wide parameter to be retrieved or set.
        Param1 / Param2:
            Parameters whose usage and format depends on the system parameter being queried or set.
            If not otherwise indicated, you must specify zero for these parameters.
        Flags:
            This parameter can be zero, or it can be one or more of the following values.
            ┌────────────┬────────────────────┬──────────────────────────────────────────────────────────────────────────┐
            │   Value    │      Constant      │                                 Meaning                                  │
            ├────────────┼────────────────────┼──────────────────────────────────────────────────────────────────────────┤
            │ 0x00000001 │ SPIF_UPDATEINIFILE │ Writes the new system-wide parameter setting to the user profile.        │
            │ 0x00000002 │ SPIF_SENDCHANGE    │ Broadcasts the WM_SETTINGCHANGE message after updating the user profile. │
            └────────────┴────────────────────┴──────────────────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is a nonzero value (Param2||Param1||Action).
        If the function fails, the return value is zero. A_LastError contains extended error information.
    Reloads the system icons:
        SystemParametersInfo(0x58)  ; SPI_SETICONS.
    Reloads the system cursors:
        SystemParametersInfo(0x57)  ; SPI_SETCURSORS.
    Retrieves the current mouse speed:
        MsgBox(NumGet(SystemParametersInfo(0x70,,BufferAlloc(4)),"UInt"))  ; SPI_GETMOUSESPEED.
*/
SystemParametersInfo(Action, Param1 := 0, Param2 := 0, Flags := 0)
{
    return DllCall("User32.dll\SystemParametersInfoW", "UInt", Action                                     ; uiAction.
                                                     , "UInt", Param1                                     ; uiParam.
                                                     ,  "Ptr", Type(Param2)=="String" ? &Param2 : Param2  ; pvParam.
                                                     , "UInt", Flags)                                     ; fWinIni.
         ? (Param2 || Param1 || Action)  ; Ok.
         : 0                             ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa





/*
    Displays or hides the desktop.
    Remarks:
        This method has the same effect as the Show Desktop button on the taskbar.
        It either hides all open windows to show the desktop or it hides the desktop by showing all open windows.
    Return value:
        The return value for this function is not used.
*/
ShowDesktop()
{
    ComObjCreate("shell.application").ToggleDesktop()
} ; https://docs.microsoft.com/en-us/windows/win32/shell/shell-toggledesktop





/*
    Updates the desktop.
    Return value:
        Returns TRUE if successful, or FALSE otherwise.
*/
UpdateDesktop()
{
    return DllCall("User32.dll\PostMessageW"
        , "Ptr", DllCall("User32.dll\FindWindowW", "Str", "Progman", "Ptr", 0, "Ptr")
        , "UInt", 0x111, "Ptr", 0xA220, "Ptr", 0)  ; WM_COMMAND.
} ; https://docs.microsoft.com/en-us/windows/win32/menurc/wm-command





/*
    Activates the Start menu.
    Return value:
        Returns TRUE if successful, or FALSE otherwise.
*/
ShowStartMenu()
{
    return DllCall("User32.dll\PostMessageW"
        , "Ptr", DllCall("User32.dll\GetForegroundWindow", "Ptr")
        , "UInt", 0x112, "Ptr", 0xF130, "Ptr", 0)  ; WM_SYSCOMMAND |⠀SC_TASKLIST.
} ; https://docs.microsoft.com/en-us/windows/win32/menurc/wm-syscommand





/*
    Retrieves version information about the currently running operating system.
    Return value:
        The return value is an object with the following properties.
        ┌──────────────────┬───────────────────────────────────────────────────────────────────────────────────┐
        │     Property     │                                    Description                                    │
        ├──────────────────┼───────────────────────────────────────────────────────────────────────────────────┤
        │ MajorVersion     │ The major version number of the operating system.                                 │
        │ MinorVersion     │ The minor version number of the operating system.                                 │
        │ BuildNumber      │ The build number of the operating system.                                         │
        │ PlatformId       │ The operating system platform.                                                    │
        │ CSDVersion       │ The service-pack version string. An empty string if no service pack is installed. │
        │ ServicePackMajor │ The major version number of the latest service pack installed on the system.      │
        │ ServicePackMinor │ The minor version number of the latest service pack installed on the system.      │
        │ SuiteMask        │ The product suites available on the system.                                       │
        │ ProductType      │ The product type. This member contains additional information about the system.   │
        └──────────────────┴───────────────────────────────────────────────────────────────────────────────────┘
        Reference: (https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw).
*/
GetSystemVersion()
{
    local OSVERSIONINFOEX := BufferAlloc(284, 0)  ; _OSVERSIONINFOEXW structure.
    DllCall("Ntdll.dll\RtlGetVersion"
        , "Ptr", NumPut("UInt",OSVERSIONINFOEX.Size,OSVERSIONINFOEX)-4)
    return { MajorVersion    : NumGet(OSVERSIONINFOEX, 4, "UInt")
           , MinorVersion    : NumGet(OSVERSIONINFOEX, 8, "UInt")
           , BuildNumber     : NumGet(OSVERSIONINFOEX, 12, "UInt")
           , PlatformId      : NumGet(OSVERSIONINFOEX, 16, "UInt")
           , CSDVersion      : StrGet(OSVERSIONINFOEX.Ptr+20)
           , ServicePackMajor: NumGet(OSVERSIONINFOEX, 276, "UShort")
           , ServicePackMinor: NumGet(OSVERSIONINFOEX, 278, "UShort")
           , SuiteMask       : NumGet(OSVERSIONINFOEX, 280, "UShort")
           , ProductType     : NumGet(OSVERSIONINFOEX, 282, "UChar")  }
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-rtlgetversion
