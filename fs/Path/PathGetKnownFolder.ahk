/*
    Retrieves the full path of a known folder identified by the folder's KNOWNFOLDERID.
    Parameters:
        FolderGuid:
            The KNOWNFOLDERID (GUID) that identifies the folder (String, Integer or Buffer object).
            {4BD8D571-6D19-48D3-BE97-422220080E43}    My Music.
            {33E28130-4E1E-4676-835A-98395C3BC3BB}    My Pictures.
            {18989B1D-99B5-455B-841C-AB7C74E4DDFC}    My Videos.
            {AE50C081-EBD2-438A-8655-8A092E34987A}    Recent Items.
            {8983036C-27C0-404B-8F08-102D10DCFD74}    SendTo.
            More: https://docs.microsoft.com/en-us/windows/desktop/shell/knownfolderid.
        hToken:
            An access token that represents a particular user. Request a specific user's folder by passing the hToken of that user.
            If this parameter is zero, which is the most common usage, the function requests the known folder for the current user.
            If this parameter is -1, the function requests the known folder for the Default User.
            The Default User user profile is duplicated when any new user account is created, and includes special folders such as Documents and Desktop.
            Any items added to the Default User folder also appear in any new user account. Note that access to the Default User folders requires administrator privileges.
            The token must be opened with TOKEN_QUERY and TOKEN_IMPERSONATE rights. In some cases, you also need to include TOKEN_DUPLICATE.
            In addition to passing the user's hToken, the registry hive of that specific user must be mounted. 
    Return value:
        If the function succeeds, the return value is a string with the folder path (does not include a trailing backslash).
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
PathGetKnownFolder(FolderGuid, hToken := 0)
{
    local

    if Type(FolderGuid) !== "String"
        GUID := FolderGuid
    else if ErrorLevel := DllCall("Ole32.dll\CLSIDFromString", "Ptr", &FolderGuid, "Ptr", GUID:=BufferAlloc(16), "UInt")
        return 0
    
    if ErrorLevel := DllCall("Shell32.dll\SHGetKnownFolderPath", "Ptr", GUID, "UInt", 0, "Ptr", hToken, "PtrP", Ptr:=0, "UInt")
        return 0

    return Format("{}", StrGet(Ptr,"UTF-16"), DllCall("Ole32.dll\CoTaskMemFree","Ptr",Ptr))
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath





;MsgBox(PathGetKnownFolder("{4BD8D571-6D19-48D3-BE97-422220080E43}"))
