#Include misc.ahk
#Include image.ahk





/*
    Replaces the contents of the specified system cursor.
    Parameters:
        hCursor:
            A handle to the cursor.
            ---------------------------------------------------------------------------------------
            The system destroys this cursor by calling the User32\DestroyCursor function.
            Therefore, this cursor cannot be loaded using the User32\LoadCursor function.
            To specify a cursor loaded from a resource, use the User32\CopyImage function.
        CursorID:
            The system cursor to replace with the contents of «hCursor».
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
SetSystemCursor(hCursor, CursorID)
{
    return DllCall("User32.dll\SetSystemCursor", "Ptr", hCursor, "UInt", CursorID)
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setsystemcursor





/*
    Changes or restores the system cursor(s).
    Parameters:
        Cursor:
            This parameter must be zero to restore the system cursors.
            This parameter can be: APPSTARTING, ARROW, CROSS, HAND, HELP, IBEAM, NO, SIZEALL, SIZENESW, SIZENS, SIZENWSE, SIZEWE, UPARROW or WAIT.
    Return value:
        Returns the number of cursors changed (it should be 14).
    Example:
        MsgBox(SetSystemCursor2("HAND")), MsgBox(SetSystemCursor2(0))
*/
SetSystemCursor2(Cursor)
{
    static Cursors := {APPSTARTING: 32650, ARROW: 32512, CROSS: 32515, HAND: 32649, HELP: 32651, IBEAM: 32513, NO: 32648, SIZEALL: 32646, SIZENESW: 32643, SIZENS: 32645, SIZENWSE: 32642, SIZEWE: 32644, UPARROW: 32516, WAIT: 32514}
    local
    if (!Cursor)
        return SystemParametersInfo(0x57)  ; SPI_SETCURSORS.
    n := 0, Cursor := Integer((Cursor is "Number") ? Cursor : Cursors.%Cursor%)
    for CursorName, CursorID in Cursors.OwnProps()
        if SetSystemCursor(hCursor:=CopyImage(LoadImage(0,Cursor,2,,,0x8000),2), CursorID)  ; LR_SHARED=0x8000.
            ++n
        else DestroyImage(hCursor, 2)  ; IMAGE_CURSOR = 2.
    return n  ; 14 = Ok.
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setsystemcursor
