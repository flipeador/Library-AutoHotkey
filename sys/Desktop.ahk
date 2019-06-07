/*
    Sets the desktop wallpaper for the current user.
    Parameters:
        FileName:
            The name of an image file. It is recommended to use a BMP image.
        Flags:
            Specifies whether the user profile is to be updated, and if so, whether the WM_SETTINGCHANGE message is to be broadcast to all top-level windows to notify them of the change.
            0x0001  SPIF_UPDATEINIFILE                          Writes the new system-wide parameter setting to the user profile.
            0x0002  SPIF_SENDWININICHANGE / SPIF_SENDCHANGE     Broadcasts the WM_SETTINGCHANGE message after updating the user profile.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
DesktopSetWallpaper(FileName, Flags := 0)
{
    ; SPI_SETDESKWALLPAPER = 0x0014.
    return DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0014, "UInt", 0, "Ptr", &FileName, "UInt", Flags)
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-systemparametersinfow





/*
    Gets the desktop wallpaper for the current user.
    Return value:
        If the function succeeds, the return value is the path of the image file.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
        If there is no desktop wallpaper, the returned string is empty.
*/
DesktopGetWallpaper()
{
    ; SPI_GETDESKWALLPAPER = 0x0073.
    local Buffer := BufferAlloc(2000)
    local Result := DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0073, "UInt", Buffer.Size//2, "Ptr", Buffer, "UInt", 0)

    return Result ? StrGet(Buffer,"UTF-16") : 0
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-systemparametersinfow





/*
    Gets the control where icons are displayed on the desktop.
    Return value:
        If the function succeeds, the return value is the ListView control handle.
        If the function fails, the return value is zero.
*/
DesktopGetListView()
{
    local
    if (hListView := ControlGetHwnd("SysListView321", "ahk_class Progman"))
        return hListView
    if (hListView := DllCall("User32.dll\FindWindowEx","Ptr",DllCall("User32.dll\FindWindowEx","Ptr"
    ,DllCall("User32.dll\GetShellWindow","Ptr"),"Ptr",0,"Str","SHELLDLL_DefView","Ptr",0,"Ptr"),"Ptr",0,"Str","SysListView32","Ptr",0,"Ptr"))
        return hListView
    For i, WindowId in WinGetList("ahk_class WorkerW")
        if (WindowId := DllCall("User32.dll\FindWindowEx", "Ptr", WindowId, "Ptr", 0, "Str", "SHELLDLL_DefView", "Ptr", 0, "Ptr"))
            return DllCall("User32.dll\FindWindowEx", "Ptr", WindowId, "Ptr", 0, "Str", "SysListView32", "Ptr", 0, "Ptr")
    return 0
}





/*
    Restores or gets the position and text of all icons on the desktop.
    Parameters:
        Data:
            Specify the returned object to restore the position of the icons.
            Omit this parameter to retrieve the information.
    Return value:
        If it is to be restored, it returns the number of icons moved; Otherwise it returns an object.
        The object contains the following format: {IconText: {X,Y}}.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
    Credits:
        https://autohotkey.com/boards/viewtopic.php?f=6&t=3529
*/
DesktopIcons(Data := 0)
{
    local

    if !(hListView := DesktopGetListView())
        return 0

    ; LVM_GETITEMCOUNT message.
    ; https://docs.microsoft.com/en-us/windows/desktop/Controls/lvm-getitemcount.
    ItemCount := SendMessage(0x1004,,, hListView)  ; Gets the number of icons on the desktop.

    ; Opens the process of «hListView» with PROCESS_VM_READ|PROCESS_VM_OPERATION|PROCESS_VM_WRITE.
    ProcessId := WinGetPID("ahk_id" . hListView)
    hProcess  := DllCall("Kernel32.dll\OpenProcess", "UInt", 0x00000038, "Int", FALSE, "UInt", ProcessId, "Ptr")
    if !hProcess
        return !(ErrorLevel := 1)

    Buffer := BufferAlloc(2*32767)  ; LVITEMW.pszText: Buffer that receives the item text.
    POINT  := BufferAlloc(8)        ; POINT structure: https://docs.microsoft.com/en-us/windows/desktop/api/windef/ns-windef-tagpoint.

    ; LVITEMW structure.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/commctrl/ns-commctrl-lvitemw.
    Address := DllCall("Kernel32.dll\VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "Ptr", A_PtrSize==4?72:88, "UInt", 0x1000, "UInt", 0x0004, "Ptr")
    ; LVITEMW.pszText: Buffer in «hProcess» that receives the item text.
    pBuffer := DllCall("Kernel32.dll\VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "Ptr", Buffer.Size, "UInt", 0x1000, "UInt", 0x0004, "Ptr")
    ; Writes the address of the buffer and its size in the LVITEMW structure.
    DllCall("Kernel32.dll\WriteProcessMemory", "Ptr", hProcess, "Ptr", Address+16+A_PtrSize, "PtrP", pBuffer, "Ptr", A_PtrSize, "Ptr", 0)   ; LVITEMW.pszText.
    DllCall("Kernel32.dll\WriteProcessMemory", "Ptr", hProcess, "Ptr", Address+16+2*A_PtrSize, "IntP", Buffer.Size//2, "Ptr", 4, "Ptr", 0)  ; LVITEMW.cchTextMax.
    
    ; ==============================================================================================================
    ; Save
    ; ==============================================================================================================
    if (!Data)
    {
        Data := {}
        Loop (ItemCount)
        {
            ; LVM_GETITEMPOSITION message.
            ; https://docs.microsoft.com/en-us/windows/desktop/controls/lvm-getitemposition.
            SendMessage(0x1010, A_Index-1, Address, hListView)  ; Gets the position of the (A_Index-1)th icon.
            ; Reads the position written in «Address» to the 'POINT' buffer of our script.
            DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "Ptr", Address, "Ptr", POINT, "Ptr", POINT.Size, "Ptr", 0)

            ; LVM_GETITEMTEXT message.
            ; https://docs.microsoft.com/en-us/windows/desktop/Controls/lvm-getitemtext.
            SendMessage(0x1073, A_Index-1, Address, hListView)  ; Gets the text of the (A_Index-1)th icon.
            ; Read the text written in «Address» (LVITEMW.pszText/pBuffer) to the 'Buffer' buffer of our script.
            DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "Ptr", pBuffer, "Ptr", Buffer, "Ptr", Buffer.Size, "Ptr", 0)
            
            ObjRawSet(Data, StrGet(Buffer,"UTF-16")
                          , { X:NumGet(POINT,"Int") , Y:Numget(POINT,4,"Int") }
                     )
        }
    }

    ; ==============================================================================================================
    ; Restore
    ; ==============================================================================================================
    else
    {
        Count := 0
        Loop (ItemCount)
        {
            ; LVM_GETITEMTEXT message.
            ; https://docs.microsoft.com/en-us/windows/desktop/Controls/lvm-getitemtext.
            SendMessage(0x1073, A_Index-1, Address, hListView)  ; Gets the text of the (A_Index-1)th icon.
            ; Read the text written in «Address» (LVITEMW.pszText/pBuffer) to the 'Buffer' buffer of our script.
            DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "Ptr", pBuffer, "Ptr", Buffer, "Ptr", Buffer.Size, "Ptr", 0)

            if ObjHasKey(Data,ItemText:=StrGet(Buffer,"UTF-16"))
            {
                ; LVM_SETITEMPOSITION message.
                ; https://docs.microsoft.com/en-us/windows/desktop/Controls/lvm-setitemposition.
                ; The LOWORD specifies the new x-position of the item's upper-left corner, in view coordinates.
                ; The HIWORD specifies the new y-position of the item's upper-left corner, in view coordinates.
                Count += SendMessage(0x100F, A_Index-1, Data[ItemText].X&0xFFFF|(Data[ItemText].Y&0xFFFF)<<16, hListView)
            }
        }
        Data := Count
    }
    
    ; ==============================================================================================================
    DllCall("Kernel32.dll\VirtualFreeEx", "Ptr", hProcess, "Ptr", Address, "Ptr", 0, "UInt", 0x8000)
    DllCall("Kernel32.dll\VirtualFreeEx", "Ptr", hProcess, "Ptr", pBuffer, "Ptr", 0, "UInt", 0x8000)
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hProcess)

    return Data
}





/*
    Retrieves the position of a single icon on the desktop with the specified text.
    Parameters:
        ItemName:
            The text of an icon (file name) on the desktop.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
DesktopSetIconPos(ItemName, X, Y)
{
    local DeskIcons := DesktopIcons()

    if !DeskIcons || !ObjHasKey(DeskIcons,ItemName)
        return DeskIcons ? !(ErrorLevel := -1) : 0

    ObjRawSet(DeskIcons, ItemName, {x:x, y:y})
    return DesktopIcons(DeskIcons)
}





/*
    Retrieves the position of a single icon on the desktop with the specified text.
    Parameters:
        ItemName:
            The text of an icon (file name) on the desktop.
    Return value:
        If the function succeeds, the return value is an object with the keys 'X' and 'Y'.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
DesktopGetIconPos(ItemName)
{
    local DeskIcons := DesktopIcons()
    return !DeskIcons ? 0
         : !ObjHasKey(DeskIcons,ItemName) ? !(ErrorLevel := -1)
         : DeskIcons[ItemName]
}





/*
MsgBox(Format("A_IsAdmin:`s{}.",A_IsAdmin?"TRUE":"FALSE"))
For IconText, Point in Data := DesktopIcons()
    IconList .= Format("{}`s({};{})`n", IconText, Point.X, Point.Y)
MsgBox(Format("DesktopIcons()`n{}{}{1}Try moving some icons.","------------------------------`n",IconList))
MsgBox(Format("Restored:`s{}",DesktopIcons(Data)))
*/
