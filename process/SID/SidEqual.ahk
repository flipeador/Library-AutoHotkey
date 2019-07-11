/*
    Tests two security identifier (SID) values for equality. Two SIDs must match exactly to be considered equal.
    Parameters:
        Sid1:
            A pointer to the first SID structure to compare. This structure is assumed to be valid.
        Sid2:
            A pointer to the second SID structure to compare. This structure is assumed to be valid.
    Return value:
        If the SID structures are equal, the return value is «Sid1».
        If the SID structures are not equal, the return value is zero. To get extended error information, check A_LastError.
        If either SID structure is not valid, the return value is undefined.
*/
SidEqual(Sid1, Sid2)
{
    return !Sid1 || !Sid2 ? 0
         : DllCall("Advapi32.dll\EqualSid", "Ptr", Sid1, "Ptr", Sid2)
         ? Sid1
         : 0
}
