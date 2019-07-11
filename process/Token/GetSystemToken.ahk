#Include ..\ProcessGetList.ahk
#Include ..\ProcessOpen.ahk
#Include ProcessOpenToken.ahk
#Include TokenIsLocalSystem.ahk





/*
    Find NT AUTHORITY\System process and duplicate its token.
    Return value:
        If the function succeeds, the return value is a IProcessToken class object.
        If the function fails, the return value is zero.
    Remarks:
        The current process must have administrative rights and perhaps the SE_DEBUG_PRIVILEGE privilege (20).
*/
GetSystemToken()
{
    local

    for Each, Item in ProcessGetList()
    {
        ; PROCESS_QUERY_INFORMATION.
        if (Process := ProcessOpen(Item.ProcessId,0x400))
        {
            ; TOKEN_ASSIGN_PRIMARY |⠀TOKEN_DUPLICATE |⠀TOKEN_IMPERSONATE |⠀TOKEN_QUERY.
            if (Token := ProcessOpenToken(Process,0x1|0x2|0x4|0x8))
            {
                if (TokenIsLocalSystem(Token))
                    return Token
            }
        }
    }

    return 0
}
