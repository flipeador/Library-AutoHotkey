/*
    Validates a security identifier (SID) by verifying that the revision number is within a known range, and that the number of subauthorities is less than the maximum.
    Parameters:
        Sid:
            The SID structure to validate.
    Return value:
        If the SID structure is valid, the return value is the length, in bytes, of the SID.
        If the SID structure is not valid, the return value is zero.
*/
SidIsValid(Sid)
{
    return DllCall("Advapi32.dll\IsValidSid", "Ptr", Sid)
         ? DllCall("Advapi32.dll\GetLengthSid", "Ptr", Sid, "UInt")
         : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-isvalidsid
