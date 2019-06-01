/*
    Retrieves the owner and the group name of the specified file.
    Parameters:
        FileName:
            The name of a file.
    Return value:
        If this function succeeds, the return value is an object with the keys: 'Owner' and 'Group'.
        If the function fails, the return value is zero.
*/
FileGetOwner(FileName)
{
    local

    try
    {
        ADsSecurityUtility              := ComObjCreate("ADsSecurityUtility")
        ADsSecurityUtility.SecurityMask := 0x1 | 0x2
        ADsSecurityDescriptor           := ADsSecurityUtility.GetSecurityDescriptor(FileName, 1, 1)
        return { Owner:ADsSecurityDescriptor.Owner , Group:ADsSecurityDescriptor.Group }
    }

    return 0
}





; MsgBox(Format("Domain\Username:`s{2}.`nGroup:`s{3}.",R:=FileGetOwner(FileSelect()),R.Owner,R.Group))
