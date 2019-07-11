#Include TokenQueryInformation.ahk
#Include ..\SID\SidIsLocalSystem.ahk





/*
    Determines whether the current account is run by the system user.
    Parameters:
        hToken:
            Handle for an access token.

*/
TokenIsLocalSystem(hToken)
{
    local TOKEN_USER := TokenQueryInformation(hToken, 1)  ; TokenUser = 1.
    return SidIsLocalSystem(NumGet(TOKEN_USER))
}
