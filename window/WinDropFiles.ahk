/*
    Simulates the drag of files to the specified window.
    Parameters:
        hWnd:
            A window handle.
        Files:
            An array with the files to include.
        X / Y:
            The drop point. The coordinates depend on «Flags».
        Flags:
            FALSE    The client coordinates of a point in the client area.
            TRUE     The screen coordinates of a point in a window's nonclient area.
    Return value:
        If the function succeeds, the return value is zero.
        If the function fails, the return value is a system error code.
    Remarks:
        This function does not work with applications that implement IDropSource and IDropTarget interfaces.
        Refer to this topic: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=8700&start=40#p164860.
*/
WinDropFiles(hWnd, Files, X := 0, Y := 0, Flags := 0)
{
    local

    ; Calculates the additional size required for the DROPFILES structure.
    ; Structure: DROPFILES+File1+null+LastFile+null+null (double null-terminated list of file names).
    Files := IsObject(Files) ? Files : Array(Files)
    Size  := 0
    for FileName in Files
        Size += StrPut(FileName)  ; Size, in bytes, of the file name, including the null-terminated character.

    ; DROPFILES structure.
    ; https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/ns-shlobj_core-dropfiles
    ; 20 = sizeof(DROPFILES). 2 = null character (double at the end).
    hDROPFILES := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x2, "Ptr", 20+Size+2, "Ptr")  ; Memory handle.
    pDROPFILES := DllCall("Kernel32.dll\GlobalLock", "Ptr", hDROPFILES, "Ptr")               ; Memory address.

    NumPut("UInt", 20                ; The offset of the file list from the beginning of this structure, in bytes.
         , "Int", X, "Int", Y        ; The drop point. The coordinates depend on «Flags».
         , "Int", Flags              ; FALSE: Client coordinates of a point in the client area. TRUE: Screen coordinates of a point in a window's nonclient area.
         , "Int", TRUE, pDROPFILES)  ; FALSE/TRUE: The file list contains ansi/unicode characters.

    ; Populates the file list in the DROPFILES structure.
    pFileList := pDROPFILES + 20  ; 20 = sizeof(DROPFILES). Start of the file list.
    for FileName in Files
        pFileList += StrPut(FileName, pFileList)  ; Write the name of the file, including the null-terminated character.
    NumPut("UShort", 0x0000, pFileList, Size)  ; Write the additional null-terminated character at the end of the file list.

    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hDROPFILES)  ; Decrements the lock count.

    ; WM_DROPFILES message.
    ; https://docs.microsoft.com/en-us/windows/win32/shell/wm-dropfiles
    RetVal := DllCall("User32.dll\PostMessageW", "Ptr", hWnd, "UInt", 0x233, "Ptr", hDROPFILES, "Ptr", 0, "Ptr")

    if (RetVal == 0)  ; If the PostMessageW function fails.
        DllCall("Kernel32.dll\GlobalFree", "Ptr", this.Handle, "Ptr")  ; Frees the specified global memory object and invalidates its handle.

    return RetVal == 0 ? Integer(A_LastError) : 0

}
