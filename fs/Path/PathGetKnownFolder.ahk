/*
    Retrieves the full path of a known folder identified by the folder's KNOWNFOLDERID.
    Parameters:
        FolderGuid:
            A GUID (KNOWNFOLDERID) that identifies the folder.
            {4BD8D571-6D19-48D3-BE97-422220080E43}  CSIDL_MYMUSIC       Music.
            {33E28130-4E1E-4676-835A-98395C3BC3BB}  CSIDL_MYPICTURES    Pictures.
            {18989B1D-99B5-455B-841C-AB7C74E4DDFC}  CSIDL_MYVIDEO       Videos.
            {AE50C081-EBD2-438A-8655-8A092E34987A}  CSIDL_RECENT        Recent Items.
            {8983036C-27C0-404B-8F08-102D10DCFD74}  CSIDL_SENDTO        SendTo.
            Reference: <https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid>.
        hToken:
            An access token that represents a particular user. Request a specific user's folder by passing the hToken of that user.
            ---------------------------------------------------------------------------------------
            If this parameter is zero, which is the most common usage, the function requests the known folder for the current user.
            If this parameter is -1, the function requests the known folder for the Default User.
            ---------------------------------------------------------------------------------------
            The Default User user profile is duplicated when any new user account is created, and includes special folders such as Documents and Desktop.
            Any items added to the Default User folder also appear in any new user account. Note that access to the Default User folders requires administrator privileges.
            ---------------------------------------------------------------------------------------
            The token must be opened with TOKEN_QUERY and TOKEN_IMPERSONATE rights. In some cases, you also need to include TOKEN_DUPLICATE.
            In addition to passing the user's hToken, the registry hive of that specific user must be mounted.
        Flags:
            Flags that specify special retrieval options.
            This value can be 0; otherwise, one or more of the KNOWN_FOLDER_FLAG values.
            Reference: <https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/ne-shlobj_core-known_folder_flag>.
    Return value:
        If the function succeeds, the return value is a string containing the folder path.
        The returned path does not include a trailing backslash ("\").
        If the function fails, throws an exception.
*/
PathGetKnownFolder(FolderGuid, hToken := 0, Flags := 0)
{
    local GUID := FolderGuid
    if (Type(FolderGuid) == "String")
    {
        GUID := BufferAlloc(16)
        DllCall("Ole32.dll\CLSIDFromString", "Ptr", &FolderGuid, "Ptr", GUID, "HRESULT")
    }

    local pBuffer := 0
    DllCall("Shell32.dll\SHGetKnownFolderPath",   "Ptr", GUID
                                              ,  "UInt", Flags
                                              ,   "Ptr", hToken
                                              , "UPtrP", pBuffer
                                              , "HRESULT")

    return Format("{}", StrGet(pBuffer), DllCall("Ole32.dll\CoTaskMemFree","Ptr",pBuffer))
} ; https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
