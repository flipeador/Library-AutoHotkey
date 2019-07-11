#Include SidCopy.ahk





/*
    Allocates and initializes a security identifier (SID) with up to eight subauthorities.
    Parameters:
        AuthorityId:
            A pointer to a SID_IDENTIFIER_AUTHORITY structure.
            This structure provides the top-level identifier authority value to set in the SID.
            This parameter can be a Buffer object or a string "0|0|0|0|0|0".
        SubAuthority:
            Subauthority values to place in the SID.
    Return value:
        If the function succeeds, the return value is a Buffer object representing the SID.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
SidAlloc(AuthorityId, SubAuthority*)
{
    if (Type(AuthorityId) == "String")
        AuthorityId := SID_IDENTIFIER_AUTHORITY(StrSplit(AuthorityId,"|")*)

    local SubAuthorityCount := SubAuthority.Length()
    loop ( 6 - SubAuthorityCount )
        SubAuthority.Push(0)

    DllCall("Advapi32.dll\AllocateAndInitializeSid",    "Ptr", AuthorityId        ; pIdentifierAuthority.
                                                   ,  "UChar", SubAuthorityCount  ; nSubAuthorityCount.
                                                   ,  "UInt", SubAuthority[1]     ; nSubAuthority0.
                                                   ,  "UInt", SubAuthority[2]     ; nSubAuthority1.
                                                   ,  "UInt", SubAuthority[3]     ; nSubAuthority2.
                                                   ,  "UInt", SubAuthority[4]     ; nSubAuthority3.
                                                   ,  "UInt", SubAuthority[5]     ; nSubAuthority4.
                                                   ,  "UInt", SubAuthority[6]     ; nSubAuthority5.
                                                   ,  "UInt", SubAuthority[7]     ; nSubAuthority6.
                                                   ,  "UInt", SubAuthority[8]     ; nSubAuthority7.
                                                   , "UPtrP", pSID := 0)

    return pSID ? SidCopyFree(pSid) : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-allocateandinitializesid





/*
    The SID_IDENTIFIER_AUTHORITY structure represents the top-level authority of a security identifier (SID).
*/
SID_IDENTIFIER_AUTHORITY(Byte1, Byte2, Byte3, Byte4, Byte5, Byte6)
{
    local Buffer := BufferAlloc(6)
    NumPut("UChar", Byte1
         , "UChar", Byte2
         , "UChar", Byte3
         , "UChar", Byte4
         , "UChar", Byte5
         , "UChar", Byte6
         , Buffer)
    return Buffer
} ; https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-_sid_identifier_authority
