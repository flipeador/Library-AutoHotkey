#Include SidAlloc.ahk
#Include SidEqual.ahk





SidIsLocalSystem(Sid)
{
    ; SECURITY_NT_AUTHORITY. SECURITY_LOCAL_SYSTEM_RID.
    return SidEqual(Sid, SidAlloc("0|0|0|0|0|5",0x00000012))
}
