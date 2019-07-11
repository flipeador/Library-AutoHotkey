/*
    Retrieves a specified type of information about an access token.
    The calling process must have appropriate access rights to obtain the information.
    Parameters:
        hToken:
            Handle for an access token from which information is to be retrieved.
            If «TokenInfoClass» is set to TokenSource, the handle must have TOKEN_QUERY_SOURCE access.
            For all other «TokenInfoClass» values, the handle must have TOKEN_QUERY access.
        TokenInfoClass:
            A value from the TOKEN_INFORMATION_CLASS enumerated type identifying the type of information to be retrieved.
    Return value:
        If the function succeeds, the return value is a Buffer object.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    TOKEN_INFORMATION_CLASS Enumeration:
        https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/ne-ntifs-_token_information_class
*/
TokenQueryInformation(hToken, TokenInfoClass)
{
    local

    NtStatus := DllCall("NtDll.dll\NtQueryInformationToken",  "UPtr", hToken := IsObject(hToken) ? hToken.Handle : hToken
                                                           ,   "Int", TokenInfoClass
                                                           ,  "UPtr", 0
                                                           ,  "UInt", 0
                                                           , "UIntP", Size := 0
                                                           ,  "UInt")

    if (NtStatus !== 0xC0000023 || !Size)    ; STATUS_BUFFER_TOO_SMALL = 0xC0000023.
    {
        A_LastError := NtStatus
        return 0
    }

    NtStatus := DllCall("NtDll.dll\NtQueryInformationToken",  "UPtr", hToken
                                                           ,   "Int", TokenInfoClass
                                                           ,   "Ptr", Buffer := BufferAlloc(Size)
                                                           ,  "UInt", Size
                                                           , "UIntP", Size
                                                           ,  "UInt")
    
    if (NtStatus !== 0)  ; STATUS_SUCCESS = 0.
    {
        A_LastError := NtStatus
        return 0
    }

    return Buffer
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/nf-ntifs-ntqueryinformationtoken
