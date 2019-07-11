#Include ProcessOpenToken.ahk





/*
    Creates a handle to a new access token that duplicates an existing token.
    Parameters:
        hToken:
            A handle to an existing access token that was opened with the TOKEN_DUPLICATE access right.
        TokenType:
            1  TokenPrimary          The new token is a primary token.
                                     If the existing token is an impersonation token, the existing impersonation token must have an impersonation level
                                     - (as provided by the ObjectAttributes parameter) of SecurityImpersonation or SecurityDelegation. Otherwise,
                                     - NtDuplicateToken returns STATUS_BAD_IMPERSONATION_LEVEL is returned. 
            2  TokenImpersonation    The new token is an impersonation token.
                                     If the existing token is an impersonation token, the requested impersonation level (as provided by the ObjectAttributes
                                     - parameter) of the new token must not be greater than the impersonation level of the existing token. Otherwise,
                                     - NtDuplicateToken returns STATUS_BAD_IMPERSONATION_LEVEL. 
        DesiredAccess:
            Bitmask that specifies the requested access rights for the new token.
            This function compares the requested access rights with the existing token's discretionary access control list (DACL) to determine which rights are granted or denied to the new token.
            To request the same access rights as the existing token, specify zero.
            To request all access rights that are valid for the caller, specify 0x02000000 (MAXIMUM_ALLOWED).
            This parameter is optional and can either be zero, MAXIMUM_ALLOWED, or a bitwise OR combination of one or more access rights.
        ObjectAttributes:
            A OBJECT_ATTRIBUTES structure that describes the requested properties for the new token.
            If this parameter is zero or if the SecurityDescriptor member of this structure is zero, the new token receives a default security descriptor and the new token handle cannot be inherited.
            - In that case, this default security descriptor is created from the user group, primary group, and DACL information that is stored in the caller's token.
        EffectiveOnly:
            A Boolean value that indicates whether the entire existing token should be duplicated into the new token or just the effective (currently enabled) part of the token.
            TRUE        Only the currently enabled parts of the source token will be duplicated.
            FALSE       The entire existing token will be duplicated. This is the default value.
            This provides a means for a caller of a protected subsystem to limit which optional groups and privileges are made available to the protected subsystem.
    Return value:
        If the function succeeds, the return value is a IProcessToken class object.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    Remakrs:
        Access tokens do not support the SYNCHRONIZE right.
    Access Rights for Access-Token Objects:
        https://docs.microsoft.com/en-us/windows/win32/secauthz/access-rights-for-access-token-objects
*/
TokenDuplicate(hToken, TokenType, DesiredAccess := 0, ObjectAttributes := 0, EffectiveOnly := 0)
{
    global IProcessToken
    local

    NtStatus := DllCall("Ntdll.dll\NtDuplicateToken",  "UPtr", IsObject(hToken) ? hToken.Handle : hToken
                                                    ,  "UInt", DesiredAccess
                                                    ,   "Ptr", ObjectAttributes
                                                    ,   "Int", EffectiveOnly
                                                    ,   "Int", TokenType
                                                    , "UPtrP", hNewToken := 0
                                                    ,  "UInt")

    if (hNewToken == 0)
    {
        A_LastError := NtStatus
        return 0
    }

    return new IProcessToken.FromHandle(hNewToken)
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/nf-ntifs-ntduplicatetoken
