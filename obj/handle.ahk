/*
    Closes an open object handle.
    Parameters:
        Handle:
            A valid handle to an open object.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. A_LastError contains extended error information.
    Remarks:
        If the application is running under a debugger, the function will throw an exception if it receives either a handle value that is not valid or a pseudo-handle value.
*/
HandleClose(Handle)
{
    local
    if IsObject(Handle)
        for ThisHandle in Handle
            HandleClose(ThisHandle)
    else return DllCall("Kernel32.dll\CloseHandle", "Ptr", Handle)
} ; https://docs.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle





/*
    Checks whether the specified value could be a valid handle.
*/
HandleIsValid(Handle)
{
    return (Handle is "Integer")                          ; is "Integer".
        && (Handle := Integer(Handle))                    ; !=0.
        && (Format("{:p}",Handle) !== Format("{:p}",-1))  ; !=INVALID_HANDLE_VALUE.
         ? Handle  ; Ok.
         : 0       ; Error.
}





/*
    Sets certain properties of an object handle.
    Parameters:
        Handle:
            A handle to an object whose information is to be set.
        Mask:
            A mask that specifies the bit flags to be changed.
            Use the same constants shown in the description of «Flags».
        Flags:
            Set of bit flags that specifies properties of the object handle.
            This parameter can be 0 or one or more of the following values.
            ┌───────┬────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value │ Constant                       │ Meaning                                                                                                                          │
            ├───────┼────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x1   │ HANDLE_FLAG_INHERIT            │ A child process created with the bInheritHandles parameter of Kernel32\CreateProcess set to TRUE will inherit the object handle. │
            │ 0x2   │ HANDLE_FLAG_PROTECT_FROM_CLOSE │ Calling the Kernel32\CloseHandle function will not close the object handle.                                                      │
            └───────┴────────────────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
HandleSetInformation(Handle, Mask, Flags)
{
    return DllCall("Kernel32.dll\SetHandleInformation",  "Ptr", Handle  ; HANDLE hObject.
                                                      , "UInt", Mask    ; DWORD  dwMask.
                                                      , "UInt", Flags)  ; DWORD  dwFlags.
} ; https://docs.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-sethandleinformation
