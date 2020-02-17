#Include misc.ahk
#Include ..\process\process.ahk
#Include ..\process\memory.ahk





/*
    Sets the desktop wallpaper for the current user.
    Parameters:
        FileName:
            The name of an image file. It is recommended to use a BMP image.
        Flags:
            See the SystemParametersInfo function (misc.ahk).
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
DesktopSetWallpaper(FileName, Flags := 0)
{
    return SystemParametersInfo(0x14,, FileName, Flags)  ; SPI_SETDESKWALLPAPER.
}





/*
    Gets the desktop wallpaper for the current user.
    Return value:
        If the function succeeds, the return value is the path of the image file.
        If the function fails, the return value is zero. A_LastError contains extended error information.
        If there is no desktop wallpaper, the returned string is empty.
*/
DesktopGetWallpaper()
{
    local Buffer := BufferAlloc(2*32767)
    return SystemParametersInfo(0x73, Buffer.Size//2, Buffer)  ; SPI_GETDESKWALLPAPER.
         ? StrGet(Buffer)  ; Ok.
         : 0               ; Error.
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
    Restores or retrieves the position and text of all icons on the desktop.
    Parameters:
        Data:
            Specify the returned object to restore the position of the icons.
            Omit this parameter to retrieve the information.
    Return value:
        If it is to be restored, it returns the number of icons moved; Otherwise it returns an array.
        The array contains the following format: [{Text,X,Y}].
        If the function fails, the return value is zero.
    Example:
        MsgBox(Format("A_IsAdmin:`s{}.",A_IsAdmin?"TRUE":"FALSE"))
        for Item in (DeskIcons := DesktopIcons())
            IconList .= Format("{}`s({};{})`n", Item.Text, Item.X, Item.Y)
        MsgBox(Format("DesktopIcons()`n{}{}{1}Try moving some icons.","------------------------------`n",IconList))
        MsgBox(Format("Restored:`s{}",DesktopIcons(DeskIcons)))
*/
DesktopIcons(Data := 0)
{
    local

    ; Retrieves the handle of the desktop's ListView control.
    if !(hListView := DesktopGetListView())
        return 0

    ; LVM_GETITEMCOUNT message.
    ; Retrieves the number of icons on the desktop.
    ; Reference: (https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitemcount).
    if !(ItemCount := SendMessage(0x1004,,,hListView))
        return Data ? 0 : [ ]

    ; Opens the process of «hListView» with read and write access rights.
    if !(Process := ProcessOpen(WinGetPID(hListView),0x38))  ; PROCESS_VM_READ|PROCESS_VM_OPERATION|PROCESS_VM_WRITE.
        return 0

    ; LVITEMW structure.
    ; Allocates space in «Process» to store an LVITEMW structure.
    ; Reference: (https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-lvitemw).
    pLVITEM := VirtualAlloc(Process, 0, A_PtrSize==4?72:88)
    ; Allocates space in «Process» to store the item's text.
    pBuffer := VirtualAlloc(Process, 0, 520)  ; LVITEMW.pszText: Buffer in «Process» that receives the item text.
    ; Writes the address of the buffer and its size in the LVITEMW structure.
    VirtualWriteValue(Process, pLVITEM+16+A_PtrSize  , "UPtr", pBuffer, A_PtrSize)  ; LVITEMW.pszText: pBuffer.
    VirtualWriteValue(Process, pLVITEM+16+2*A_PtrSize, "UInt", 260, 4)              ; LVITEMW.cchTextMax: sizeof(pBuffer) in characters.

    ; ==============================================================================================================
    ; Save
    ; ==============================================================================================================
    if (!Data)
    {
        Data := [ ]
        Loop (ItemCount)
        {
            ; LVM_GETITEMPOSITION message.
            ; Retrieves the position of the (A_Index-1)th icon.
            ; Reference: (https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitemposition).
            SendMessage(0x1010, A_Index-1, pLVITEM, hListView)  ; Writes a POINT structure in «pLVITEM».
            ; Reads the position written in «pLVITEM» to a POINT buffer in our script.
            POINT := VirtualRead(Process, pLVITEM,, 8)  ; POINT structure: Stores the x/y coordinates for an icon.

            ; LVM_GETITEMTEXT message.
            ; Retrieves the text of the (A_Index-1)th icon.
            ; Reference: (https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitemtext).
            SendMessage(0x1073, A_Index-1, pLVITEM, hListView)  ; Writes a LVITEMW structure in «pLVITEM».
            ; Read the text written in «pLVITEM.pszText» to a buffer in our script.
            Text := VirtualReadString(Process, pBuffer, 260)  ; LVITEMW.pszText: Buffer that receives the item text.

            Data.Push({Text:Text,X:NumGet(POINT,"Int"),Y:Numget(POINT,4,"Int")})
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
            SendMessage(0x1073, A_Index-1, pLVITEM, hListView)  ; LVM_GETITEMTEXT message.
            Buffer := VirtualRead(Process, pBuffer,, 520)

            for Item in Data
                if !StrCompare(Item.Text, StrGet(Buffer))
                    ; LVM_SETITEMPOSITION message.
                    ; The LOWORD specifies the new x-position of the item's upper-left corner, in view coordinates.
                    ; The HIWORD specifies the new y-position of the item's upper-left corner, in view coordinates.
                    ; Reference: (https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setitemposition).
                    Count += !!SendMessage(0x100F, A_Index-1, (Item.X&0xFFFF)|((Item.Y&0xFFFF)<<16), hListView)
        }
        Data := Count
    }

    ; Frees the allocated buffers in «Process».
    VirtualFree(Process, pLVITEM)
    VirtualFree(Process, pBuffer)
    DllCall("Kernel32.dll\CloseHandle", "Ptr", Process)

    return Data
} ; https://autohotkey.com/boards/viewtopic.php?f=6&t=3529

DesktopSetIconPos(ItemName, X, Y)
{
    local
    for Item in (DeskIcons := DesktopIcons())
    {
        if !StrCompare(Item.Text, ItemName)
        {
            DeskIcons[A_Index].X := X
            DeskIcons[A_Index].Y := Y
            return DesktopIcons(DeskIcons)
        }
    }
    return 0
}

DesktopGetIconPos(ItemName)
{
    local
    for Item in DesktopIcons()
        if !StrCompare(Item.Text, ItemName)
            return Item
    return 0
}
