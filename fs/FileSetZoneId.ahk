/*
    Sets the current security zone identifier for the specified file.
    Parameters:
        FileName:
            The absolute path of the file to be opened.
        ZoneId:
            The zone identifier used by Windows Internet Explorer. See the URLZONE enumeration.
            Any non-numeric value indicates that the security zone will be removed.
            URLZONE_INVALID             -1
            URLZONE_PREDEFINED_MIN      0
            URLZONE_LOCAL_MACHINE       0
            URLZONE_INTRANET            1
            URLZONE_TRUSTED             2
            URLZONE_INTERNET            3
            URLZONE_UNTRUSTED           4
            URLZONE_PREDEFINED_MAX      999
            URLZONE_USER_MIN            1000
            URLZONE_USER_MAX            10000
    Return value:
        If the function succeeded, returns TRUE; otherwise, the return value is FALSE.
    URLZONE enumeration:
        https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537175%28v%3dvs.85%29.
    Unblocks files that were downloaded from the Internet:
        FileSetZoneId(FileName, "")
*/
FileSetZoneId(FileName, ZoneId)
{
    local

    ; Persistent Zone Identifier object.
    ; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537029(v%3Dvs.85).

    ; IZoneIdentifier interface.
    ; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537032%28v%3dvs.85%29.
    ;                                |-- CLSID_PersistentZoneIdentifier --|    | ------ IID_IZoneIdentifier ------- |
    IZoneIdentifier := ComObjCreate("{0968E258-16C7-4DBA-AA86-462DD61E31A3}", "{CD45F185-1B21-48E2-967B-EAD743A8914E}")

    ; IPersistFile interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/objidl/nn-objidl-ipersistfile.
    ;                                             | -------- IID_IPersistFile -------- |
    IPersistFile := ComObjQuery(IZoneIdentifier, "{0000010B-0000-0000-C000-000000000046}")
    if !IPersistFile
        return FALSE

    if (ZoneId is "Number")
    {
        ; IZoneIdentifier::SetId method.
        ; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537037%28v%3dvs.85%29.
        R := DllCall(NumGet(NumGet(IZoneIdentifier)+4*A_PtrSize), "Ptr", IZoneIdentifier, "UInt", ZoneId, "UInt")
    }
    else
    {
        ; IZoneIdentifier::Remove method.
        ; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537034%28v%3dvs.85%29.
        R := DllCall(NumGet(NumGet(IZoneIdentifier)+5*A_PtrSize), "Ptr", IZoneIdentifier, "UInt")
    }

    if (R == 0)  ; S_OK.
    {
        ; IPersistFile::Save method.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/objidl/nf-objidl-ipersistfile-save.
        R := DllCall(NumGet(NumGet(IPersistFile)+6*A_PtrSize), "Ptr", IPersistFile, "Ptr", &FileName, "Int", FALSE, "UInt")
    }

    ObjRelease(IPersistFile)
    ObjRelease(IZoneIdentifier)

    return R == 0  ; S_OK.
}
