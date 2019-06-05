/*
    Retrieves the handle to the window that currently has the clipboard open.
    Return value:
        If the function succeeds, the return value is the handle to the window that has the clipboard open.
        If no window has the clipboard open, the return value is zero. To get extended error information, check A_LastError.
*/
ClipboardWindow()
{
    return DllCall("User32.dll\GetOpenClipboardWindow", "UPtr")
}





/*
    Opens the clipboard for examination and prevents other applications from modifying the clipboard content.
    Parameters:
        Owner:
            A handle to the window to be associated with the open clipboard.
            If this parameter is zero, the open clipboard is associated with the current task.
            If this parameter is an empty string, the open clipboard is associated with A_ScriptHwnd.
        Timeout:
            Specifies how long the script keeps trying to access the clipboard when the first attempt fails.
            This value must be an integer specifying the time out, in milliseconds.
        Delay:
            Time to wait between each attempt to open the clipboard, in milliseconds.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    Remarks:
        ClipboardOpen fails if another window has the clipboard open.
        An application should call the ClipboardClose function after every successful call to ClipboardOpen.
        The window identified by «Owner» does not become the clipboard owner unless the ClipboardEmpty function is called.
        If an application calls ClipboardOpen with «Owner» set to zero, ClipboardEmpty sets the clipboard owner to zero; this causes ClipboardSetData to fail.
*/
ClipboardOpen(Owner := "", Timeout := 1500, Delay := 50)
{
    local R, I := Timeout//Delay
    local hWnd := (Owner == "" || (Owner && !WinExist("ahk_id" . Owner))) ? A_ScriptHwnd : Owner
    while !(R:=DllCall("User32.dll\OpenClipboard", "Ptr", hWnd)) && (A_Index <= I)
        Sleep(Delay)
    return R ? (hWnd ? hWnd : -1) : 0
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-openclipboard





/*
    Closes the clipboard.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    Remarks:
        When the window has finished examining or changing the clipboard, close the clipboard by calling CloseClipboard. This enables other windows to access the clipboard.
        Do not place an object on the clipboard after calling CloseClipboard.
*/
ClipboardClose()
{
    return DllCall("User32.dll\CloseClipboard")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-closeclipboard





/*
    Empties the clipboard and frees handles to data in the clipboard.
    The function then assigns ownership of the clipboard to the window that currently has the clipboard open.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
ClipboardEmpty()
{
    return DllCall("User32.dll\EmptyClipboard")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-emptyclipboard





/*
    Registers a new clipboard format. This format can then be used as a valid clipboard format.
    Parameters:
        FormatName:
            The name of the new format.
            This parameter can be a string or a pointer to a null-terminated string.
    Return value:
        If the function succeeds, the return value identifies the registered clipboard format.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
ClipboardRegisterFormat(FormatName)
{
    return DllCall("User32.dll\RegisterClipboardFormatW", "Ptr", Type(FormatName)=="String"?&FormatName:FormatName, "UInt")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-registerclipboardformatw

ClipboardFormat(Format)
{
    return Type(Format) == "Integer" ? Format : ClipboardRegisterFormat(String(Format))
}





/*
    Determines whether the clipboard contains data in the specified format.
    Parameters:
        Format:
            A standard or registered clipboard format. For a description of the standard clipboard formats, see Standard Clipboard Formats.
            If this parameter is a string, function ClipboardRegisterFormat is called.
    Return value:
        If the clipboard format is available, the return value is the Format (integer value).
        If the clipboard format is not available, the return value is zero. To get extended error information, check A_LastError.
    Clipboard Formats:
        https://docs.microsoft.com/en-us/windows/desktop/dataxchg/clipboard-formats#standard-clipboard-formats
    Standard Clipboard Formats:
        https://msdn.microsoft.com/f0af4e61-7ef1-4263-b2c5-e4114515124f
*/
ClipboardFormatAvailable(Format)
{
    return DllCall("User32.dll\IsClipboardFormatAvailable", "UInt", Format:=ClipboardFormat(Format)) ? Format : 0
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-isclipboardformatavailable





/*
    Retrieves from the clipboard the name of the specified registered format.
    Parameters:
        Format:
            See the ClipboardFormatAvailable function. This value must be an integer.
    Return value:
        If the function succeeds, it returns the format name.
        If the function fails, the return value is zero (the format doesn't exist or is predefined). To get extended error information, check A_LastError.
*/
ClipboardGetFormat(Format)
{
    local Length, Buffer := BufferAlloc(1002)
    Length := DllCall("User32.dll\GetClipboardFormatNameW", "UInt", Format, "Ptr", Buffer, "Int", Buffer.Size-2)
    return Length ? StrGet(Buffer,Length,"UTF-16") : 0
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-getclipboardformatnamew





/*
    Determines if the specified format is displayable.
    Parameters:
        Format:
            See the ClipboardFormatAvailable function. This value must be an integer.
    Return value:
        Returns TRUE if the specified format is displayable; Otherwise, it returns FALSE.
*/
ClipboardDisplayableFormat(Format)
{
    ;    || CF_OWNERDISPLAY ||      CF_TEXT     ||  CF_ENHMETAFILE  ||    CF_BITMAP    ||
    return Format == 0x0080 || Format == 0x0081 || Format == 0x000E || Format == 0X0002
}





/*
    Retrieves data from the clipboard in a specified format. The clipboard must have been opened previously.
    Parameters:
        Format:
            See the ClipboardFormatAvailable function.
    Return value:
        If the function succeeds, the return value is the handle to a clipboard object in the specified format.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
ClipboardGetData(Format)
{
    return DllCall("User32.dll\GetClipboardData", "UInt", ClipboardFormat(Format), "UPtr")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-getclipboarddata





/*
    Places data on the clipboard in a specified clipboard format.
    Parameters:
        Format:
            See the ClipboardFormatAvailable function.
        hMem:
            A handle to the data in the specified format. It can be an object with the key 'Ptr'.
            If this parameter identifies a memory object, the object must have been allocated using the GlobalAlloc function with the GMEM_MOVEABLE flag.
    Return value:
        If the function succeeds, the return value is the handle to the data.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    Remarks:
        If ClipboardSetData succeeds, the system owns the object identified by the «hMem» parameter.
        The app may not write to or free the data once ownership has been transferred to the system, but it can lock and read from the data until the ClipboardClose function is called.
        The memory must be unlocked before the Clipboard is closed.
*/
ClipboardSetData(Format, hMem)
{
    return DllCall("User32.dll\SetClipboardData", "UInt", ClipboardFormat(Format), "Ptr", hMem, "UPtr")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setclipboarddata





/*
    Retrieves the preferred method of data transfer (preferred drop effect set by source).
    Return value:
        If the function succeeds, the return value is one of the following.
        1  DROPEFFECT_COPY      The source should copy the data. The original data is untouched.
        2  DROPEFFECT_MOVE      The source should remove the data.
        5                       This value also indicates copy (DROPEFFECT_COPY).
        ---------------------------------------------------
        Any other value is considered an error.
        -1        No data transfer operation found.
        -2        The clipboard could not be opened.
    Windows Clipboard Formats:
        https://www.codeproject.com/Reference/1091137/Windows-Clipboard-Formats
*/
ClipboardGetDropEffect()
{
    local
    return !ClipboardFormatAvailable("Preferred DropEffect")?-1:!ClipboardOpen()?-2:0
    *(DllCall("Kernel32.dll\GlobalUnlock","Ptr",0*(r:=NumGet(DllCall("Kernel32.dll\GlobalLock"
    ,"Ptr",h:=ClipboardGetData("Preferred DropEffect"),"Ptr"),"Int"))+h,"Ptr")+ClipboardClose())+r
}





/*
    Sets files in the clipboard ready to copy or move (cut).
    Parameters:
        Files:
            An array with the files to set. Can be a string with a single file.
        DropEffect:
            The preferred method of data transfer. See the ClipboardGetDropEffect function.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero.
*/
ClipboardSetFiles(Files, DropEffect := 1)
{
    local

    ; DROPFILES structure.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/ns-shlobj_core-_dropfiles.
    Size := 20  ; sizeof(DROPFILES).
    for i, File in Files := IsObject(Files) ? Files : [Files]
        Size += StrPut(File, "UTF-16")

    hMem := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x42, "Ptr", Size+2, "Ptr")  ; 2 = '\0'.
    pMem := DllCall("Kernel32.dll\GlobalLock", "Ptr", hMem, "Ptr")

    NumPut("UInt", 20, pMem)               ; DROPFILES.pFiles.
    pMem := NumPut("Int", TRUE, pMem, 16)  ; DROPFILES.fWide (Unicode).

    for i, File in Files
        pMem += StrPut(File, pMem, StrPut(File,"UTF-16")//2, "UTF-16")

    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hMem, "Ptr")

    ; Preferred DropEffect (DROPEFFECT).
    ; https://docs.microsoft.com/en-us/windows/desktop/com/dropeffect-constants.
    hDropEffect := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x02, "Ptr", 4, "Ptr")  ; UINT.
    NumPut("UInt", DropEffect, DllCall("Kernel32.dll\GlobalLock","Ptr",hDropEffect,"Ptr"))
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hDropEffect, "Ptr")

    ; ---------------------
    if ClipboardOpen()
    {
        if ClipboardEmpty()
            if !(hMem := ClipboardSetData(0xF,hMem) ? 0 : hMem)  ; CF_HDROP.
                hDropEffect := ClipboardSetData("Preferred DropEffect",hDropEffect) ? 0 : hDropEffect
        ClipboardClose()
    }

    DllCall("Kernel32.dll\GlobalFree", "Ptr", hMem)
    DllCall("Kernel32.dll\GlobalFree", "Ptr", hDropEffect)
    return hMem || hDropEffect ? 0 : Size
} ; https://docs.microsoft.com/en-us/windows/desktop/com/dropeffect-constants




/*
    Sets a Bitmap image into the clipboard.
    Parameters:
        hBitmap:
            A Bitmap handle. You can use the built-in LoadPicture function.
        Flags:
            This parameter can be one or more of the following values.
            0x00000008  LR_COPYDELETEORG       Deletes the image passed in «hBitmap».
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero.
*/
ClipboardSetImage(hBitmap, Flags := 0)
{
    local

    ; Creates a DIB section. Ensures that the GetObject function returns a DIBSECTION structure.
    ; This is necessary if, for example, a 'jpg' image is loaded using LoadPicture. In that case, the GetObject function returns a BITMAP structure.
    hBitmap := DllCall("User32.dll\CopyImage", "Ptr", hBitmap, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2000|Flags, "Ptr")
    ; Checks the Bitmap handle.
    if DllCall("Gdi32.dll\GetObjectType","Ptr",hBitmap) !== 7  ; OBJ_BITMAP.
        return 0

    ; Allocates a buffer to hold the DIBSECTION structure that receives the information about the specified graphics object.
    DIBSECTION := BufferAlloc(A_PtrSize == 4 ? 84 : 104)  ; sizeof(DIBSECTION)
    ; Fills the DIBSECTION buffer with the information about the specified graphics object.
    if DllCall("Gdi32.dll\GetObject", "Ptr", hBitmap, "Int", DIBSECTION.Size, "Ptr", DIBSECTION) !== DIBSECTION.Size  ; Check DIBSECTION.
        return 0

    ; Allocates a buffer to store the BITMAPINFOHEADER structure and the image data.
    SizeImage := NumGet(DIBSECTION, A_PtrSize==4?44:52, "Int")  ; DIBSECTION.BITMAPINFOHEADER.biSizeImage.
    hMem      := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x02, "Ptr", 40+SizeImage, "Ptr")  ; sizeof(BITMAPINFOHEADER) = 40.
    pMem      := DllCall("Kernel32.dll\GlobalLock", "Ptr", hMem, "Ptr")

    DllCall("msvcrt.dll\memcpy", "Ptr", pMem, "Ptr", DIBSECTION.Ptr+(A_PtrSize==4?24:32), "Ptr", 40, "CDecl Ptr")                    ; Copy DIBSECTION.BITMAPINFOHEADER.
    DllCall("msvcrt.dll\memcpy", "Ptr", pMem+40, "Ptr", NumGet(DIBSECTION,A_PtrSize==4?20:24,"Ptr"), "Ptr", SizeImage, "CDecl Ptr")  ; Copy Image (DIBSECTION.BITMAP.bmBits).

    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hMem, "Ptr")
    DllCall("Gdi32.dll\DeleteObject", "Ptr", hBitmap)

    ; Stores the image into the clipboard.
    if (R := ClipboardOpen())
    {
        R := ClipboardEmpty() && ClipboardSetData(8,hMem)
        ClipboardClose()
    }
    
    return R ? R : 0*DllCall("Kernel32.dll\GlobalFree","Ptr",hMem)
} ; https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-2





/*
    Gets a Bitmap image from the clipboard.
    Return value:
        If the function succeeds, the return value is a Bitmap handle.
        If the function fails, the return value is zero.
*/
ClipboardGetImage()
{
    local hBitmap := 0
    if ClipboardFormatAvailable(2) && ClipboardOpen()  ; CF_BITMAP = 2.
    {
        hBitmap := DllCall("User32.dll\CopyImage", "Ptr", ClipboardGetData(2), "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2000, "Ptr")
        ClipboardClose()
    }
    return hBitmap
}





/*
    Retrieves the selected text in the active window using the clipboard.
    Parameters:
        Options:
            0      The clipboard is restored to its original content. The function returns a string. This is the default value.
            1      The copied content remains in the clipboard. The function returns a string.
            2      Returns a ClipboardAll object instead of the selected text; It can be used to restore the contents of the clipboard later.
        Timeout:
            Seconds to wait until the clipboard contains data (can contain a decimal point). Specifying 0 is the same as specifying 0.5.
    Return value:
        Returns a string or a ClipboardAll object, depending on the value specified in «Options».
*/
ClipboardGetSelText(Options := 0, Timeout := 2)
{
    local

    ClipSaved := ClipboardAll()
    Clipboard := "", Send("^c")
    Content   := (R:=ClipWait(Timeout,1)) ? Clipboard : ""

    if (!R || Options == 0)
        Clipboard := ClipSaved

    return Options == 2 ? ClipSaved : Content
}





/*
    Sends the specified text to the active window using the clipboard.
    Parameter:
        Text:
            A string with the text to be sent.
        RestoreDelay:
            The delay, in milliseconds, to restore the clipboard to its original content.
            Default is 500 milliseconds. If zero is specified, the clipboard will not be restored.
*/
ClipboardSendText(Text, RestoreDelay := 500)
{
    static ClipSaved := 0

    if ((Text := String(Text)) == "")
        return

    if (!ClipSaved && RestoreDelay > 0)
        ClipSaved := ClipboardAll()

    Clipboard := Text
    Send("^v")

    if (RestoreDelay > 0)
        SetTimer("RestoreClipboard", -RestoreDelay)

    RestoreClipboard()
    {
        Clipboard := ClipSaved
        ClipSaved := 0
    }
}
