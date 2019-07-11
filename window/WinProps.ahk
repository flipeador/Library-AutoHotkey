; WM_NCDESTROY message.
; https://docs.microsoft.com/en-us/windows/win32/winmsg/wm-ncdestroy.
;OnMessage(0x82, "IWindowProperties.WM_NCDESTROY")  ; WM_NCDESTROY = 0x82.

/*
    About Window Properties:
        A window property is any data assigned to a window.
        A window property is usually a handle of the window-specific data, but it may be any value.
        Each window property is identified by a string name. 
        https://docs.microsoft.com/en-us/windows/win32/winmsg/about-window-properties

    About Atom Tables:
        https://docs.microsoft.com/en-us/windows/win32/dataxchg/about-atom-tables
*/





/*
    Enumerates all entries in the property list of a window.
    Parameters:
        hWnd:
            A Gui object or a handle to the window whose property list is to be enumerated.
    Return value:
        The return value is a Map object containing the properties. It is empty if the function did not find a property for enumeration.
        The key can be a string with the name of the property or an integer indicating an ATOM (0x0001-0xBFFF).
        The value is an integer (UPtr) indicating the data associated with the property.
    Remarks:
        To determine if a property exists, use the WinPropExist function instead.
*/
WinEnumProps(hWnd)
{
    local Properties := {}, PropEnumProc := CallbackCreate("PropEnumProc")
    DllCall("User32.dll\EnumPropsW", "Ptr", IsObject(hWnd)?hWnd.hWnd:hWnd, "Ptr", PropEnumProc)
    return CallbackFree(PropEnumProc) ? Properties : Properties
    PropEnumProc(hWnd, lpString, hData) {
        return (Properties[lpString>0&&lpString<0xC000?lpString:StrGet(lpString)]:=hData)?1:1
    } ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-propenumproca
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumpropsw





/*
    Adds a new entry or changes an existing entry in the property list of the specified window.
    Parameters:
        hWnd:
            A Gui object or a handle to the window whose property list receives the new entry.
        PropName:
            A string, a pointer to a null-terminated string or an ATOM (0x0001-0xBFFF) that identifies a string.
            If this parameter is an ATOM, it must be a global ATOM created by a previous call to the GlobalAddAtom function.
        Data:
            An integer (UPtr) that will be stored in the property list. The data handle can identify any value useful to the application.
    Return value:
        If the data and string are added to the property list, the return value is nonzero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    Remarks:
        Before a window is destroyed (before it returns from processing the WM_NCDESTROY message), an application must remove all entries it has added to the property list.
        The application must use the WinRemoveProp function to remove the entries.
        ---------------------------------------------------------------
        This function is subject to the restrictions of User Interface Privilege Isolation (UIPI).
        A process can only call this function on a window belonging to a process of lesser or equal integrity level.
        When UIPI blocks property changes, A_LastError will be set to 5.
*/
WinSetProp(hWnd, PropName, Data)
{
    return DllCall("User32.dll\SetPropW", "UPtr", IsObject(hWnd)             ? hWnd.hWnd : hWnd
                                        , "UPtr", Type(PropName) == "String" ? &PropName : PropName
                                        , "UPtr", Data)
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setpropw





/*
    Retrieves a data handle from the property list of the specified window.
    The string and handle must have been added to the property list by a previous call to the WinSetProp function.
    Parameters:
        hWnd:
            A Gui object or a handle to the window whose property list is to be searched.
        PropName:
            A string, a pointer to a null-terminated string or an ATOM (0x0001-0xBFFF) that identifies a string.
            If this parameter is an ATOM, it must be a global ATOM created by a previous call to the GlobalAddAtom function.
    Return value:
        If the property list contains the string, the return value is the associated data handle. Otherwise, the return value is zero.
    Remarks:
        This function does not provide a way to determine if the property exists, use function WinPropExist or WinEnumProps+WinPropCompare instead.
*/
WinGetProp(hWnd, PropName)
{
    return DllCall("User32.dll\GetPropW", "UPtr", IsObject(hWnd)             ? hWnd.hWnd : hWnd
                                        , "UPtr", Type(PropName) == "String" ? &PropName : PropName
                                        , "UPtr")
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getpropw





/*
    Removes an entry from the property list of the specified window. The specified character string identifies the entry to be removed.
    Parameters:
        hWnd:
            A Gui object or a handle to the window whose property list is to be removed.
        PropName:
            A string, a pointer to a null-terminated string or an ATOM (0x0001-0xBFFF) that identifies a string.
            If this parameter is an ATOM, it must be a global ATOM created by a previous call to the GlobalAddAtom function.
    Return value:
        If the property list contains the string, the return value is the associated data handle. Otherwise, the return value is zero.
    Remarks:
        This function only destroys the association between the data and the window.
        If appropriate, the application must free the data handles associated with entries removed from a property list.
        The application can remove only those properties it has added. It must not remove properties added by other applications or by the system itself.
        ---------------------------------------------------------------
        The WinRemoveProp function returns the data handle associated with the string so that the application can free the data associated with the handle.
        ---------------------------------------------------------------
        This function is subject to the restrictions of User Interface Privilege Isolation (UIPI).
        A process can only call this function on a window belonging to a process of lesser or equal integrity level.
        When UIPI blocks property changes, A_LastError will be set to 5.
*/
WinRemoveProp(hWnd, PropName)
{
    return DllCall("User32.dll\RemovePropW", "UPtr", IsObject(hWnd)             ? hWnd.hWnd : hWnd
                                           , "UPtr", Type(PropName) == "String" ? &PropName : PropName
                                           , "UPtr")
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-removepropw





/*
    Determines whether the specified property exists in the property list of the specified window.
    Parameters:
        hWnd:
            A Gui object or a handle to the window whose property list is to be searched.
        PropName:
            A string, a pointer to a null-terminated string or an ATOM (0x0001-0xBFFF) that identifies a string.
            If this parameter is an ATOM, it must be a global ATOM created by a previous call to the GlobalAddAtom function.
    Return value:
        If the property list contains the string, the return value is a Map object with the keys 'Name' and 'Data'.
        If the property list does not contains the string, the return value is zero.
*/
WinPropExist(hWnd, PropName)
{
    local Exist := 0, Index := 1, PropEnumProc := CallbackCreate((x,y,z)
    =>WinPropCompare(PropName,y)?!(Exist:={Name:PropName,Index:Index,Data:z}):Index++)
    DllCall("User32.dll\EnumPropsW", "Ptr", IsObject(hWnd)?hWnd.hWnd:hWnd, "Ptr", PropEnumProc)
    return CallbackFree(PropEnumProc) ? Exist : Exist
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumpropsw





/*
    Compares two window properties.
    Parameters:
        Prop1 / Prop2:
            A string, a pointer to a null-terminated string or an ATOM (0x0001-0xBFFF).
    Return value:
        If the two properties specified are the same, the return value is non-zero. Otherwise, it returns zero.
*/
WinPropCompare(Prop1, Prop2)
{
    Prop1 := Type(Prop1) == "Integer" ? (Prop1>0&&Prop1<0xC000) ? Prop1 : StrGet(Prop1) : String(Prop1)
   ,Prop2 := Type(Prop2) == "Integer" ? (Prop2>0&&Prop2<0xC000) ? Prop2 : StrGet(Prop2) : String(Prop2)
    return Type(Prop1) == Type(Prop2) && Prop1 == Prop2
}





/*  —> E.X.A.M.P.L.E <——
F1::
PropList := ""
for PropName, PropData in WinEnumProps(WinExist("A"))
{
    PropList .= Format("{}:`s0x{}{}`n", PropName
              , Format("{:0" . (2*A_PtrSize) . "X}",PropData)
              , Type(PropName) == "Integer" ? "`s(ATOM)" : "")
}
ToolTip(PropList)
return
*/
