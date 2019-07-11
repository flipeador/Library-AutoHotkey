#Include SidIsValid.ahk





/*
    Copies a security identifier (SID).
    Parameters:
        Sid:
            A SID structure.
    Return value:
        If the function succeeds, the return value is a Buffer object representing the new SID.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
SidCopy(Sid)
{
    return SidCopyTo(Sid, BufferAlloc(SidIsValid(Sid)))
}





SidCopyTo(Sid, Buffer, Size := "")
{
    return DllCall("Advapi32.dll\CopySid", "UInt", Size == "" ? Buffer.Size : Size
                                         ,  "Ptr", Buffer
                                         ,  "Ptr", Sid)
         ? Buffer
         : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-copysid





SidCopyFree(Sid)
{
    local new_sid := SidCopy(Sid)
    if (new_sid)
        DllCall("Advapi32.dll\FreeSid", "Ptr", Sid, "Ptr")
    return new_sid
} ; https://docs.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-freesid
