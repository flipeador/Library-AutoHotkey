/*
    Opens the access token associated with a process.
    Parameters:
        hProcess:
            A handle to the process whose access token is opened.
            The process must have the PROCESS_QUERY_INFORMATION access permission.
        DesiredAccess:
            Specifies an access mask that specifies the requested types of access to the access token.
            These requested access types are compared with the Discretionary Access Control List (DACL) of the token to determine which accesses are granted or denied.
    Return value:
        If the function succeeds, the return value an IProcessToken class object.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    Access Rights for Access-Token Objects:
        https://docs.microsoft.com/en-us/windows/win32/secauthz/access-rights-for-access-token-objects
*/
ProcessOpenToken(hProcess, DesiredAccess := 0xF01FF)
{
    return new IProcessToken(hProcess, DesiredAccess)
}





class IProcessToken
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Handle := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(hProcess, DesiredAccess)
    {
        local

        NtStatus := DllCall("Ntdll.dll\NtOpenProcessToken",  "UPtr", IsObject(hProcess) ? hProcess.Handle : hProcess
                                                          ,  "UInt", DesiredAccess
                                                          , "UPtrP", hToken := 0
                                                          ,  "UInt")

        if (hToken == 0)
            return 0 * (A_LastError := NtStatus)
        this.Handle := hToken
    } ; https://undocumented.ntinternals.net/index.html?page=UserMode%2FUndocumented%20Functions%2FNT%20Objects%2FToken%2FNtOpenProcessToken.html


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    class FromHandle extends IProcessToken
    {
        ; ===================================================================================================================
        ; CONSTRUCTOR
        ; ===================================================================================================================
        __New(hToken)
        {
            this.Handle := ProcessTokenCheckHandle(hToken)
            if (this.Handle == 0)
                return 0
        }
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Handle)
            DllCall("Kernel32.dll\CloseHandle", "Ptr", this.Handle)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
}





ProcessTokenCheckHandle(Handle)
{
    return Handle ? Integer(Handle) : 0
}
