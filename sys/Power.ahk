/*
    Retrieves the active power scheme and returns a GUID that identifies the scheme.
    Return value:
        If the function succeeds, the return value is a Buffer object with the GUID (SchemeGuid).
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
PowerGetActiveScheme()
{
    local

    if (ErrorLevel := DllCall("PowrProf.dll\PowerGetActiveScheme", "Ptr", 0, "PtrP", pGUID:=0, "UInt"))
        return 0

    DllCall("Ntdll.dll\RtlMoveMemory", "Ptr", GUID:=BufferAlloc(16), "Ptr", pGUID, "Ptr", 16)
    DllCall("Kernel32.dll\LocalFree", "Ptr", pGUID)

    return GUID
} ; https://docs.microsoft.com/en-us/windows/desktop/api/Powersetting/nf-powersetting-powergetactivescheme





/*
    Sets the active power scheme for the current user.
    Parameters:
        SchemeGuid:
            The identifier of the power scheme.
            This parameter must be a pointer to a GUID structure (integer) or a Buffer object.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
    Remarks:
        Changes to the settings for the active power scheme do not take effect until you call the PowerSetActiveScheme function.
*/
PowerSetActiveScheme(SchemeGuid)
{
    return !(ErrorLevel := DllCall("PowrProf.dll\PowerSetActiveScheme", "Ptr", 0, "Ptr", SchemeGuid, "UInt"))
} ; https://docs.microsoft.com/en-us/windows/desktop/api/Powersetting/nf-powersetting-powersetactivescheme





/*
    Duplicates an existing power scheme.
    Parameters:
        SrcSchemeGuid:
            The identifier of the power scheme that is to be duplicated.
        DestSchemeGuid:
            A pointer to a GUID structure (integer) or a Buffer object.
            If the address is zero, the function allocates memory for a new GUID.
    Return value:
        If the function succeeds, the return value is a Buffer object with the GUID.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
PowerDuplicateScheme(SrcSchemeGuid, DestSchemeGuid := 0)
{
    local

    pDestSchemeGuid := p := IsObject(DestSchemeGuid) ? DestSchemeGuid.Ptr : DestSchemeGuid
    if (ErrorLevel := DllCall("PowrProf.dll\PowerDuplicateScheme", "Ptr", 0, "Ptr", SrcSchemeGuid, "PtrP", pDestSchemeGuid, "UInt"))
        return 0

    DllCall("Ntdll.dll\RtlMoveMemory", "Ptr", GUID:=BufferAlloc(16), "Ptr", pDestSchemeGuid, "Ptr", 16)
    DllCall("Kernel32.dll\LocalFree", "Ptr", p?0:pDestSchemeGuid)

    return GUID
} ; https://docs.microsoft.com/en-us/windows/desktop/api/PowrProf/nf-powrprof-powerduplicatescheme





/*
    Deletes the specified power scheme from the database.
    Parameters:
        SchemeGuid:
            See the PowerSetActiveScheme function.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
PowerDeleteScheme(SchemeGuid)
{
    return !(ErrorLevel := DllCall("PowrProf.dll\PowerDeleteScheme", "Ptr", 0, "Ptr", SchemeGuid, "UInt"))
} ; https://docs.microsoft.com/en-us/windows/desktop/api/powrprof/nf-powrprof-powerdeletescheme





PowerApplySettingChanges(SubGroupGuid, SettingGuid)  ; WIN_8+
{
    return !(ErrorLevel := DllCall("PowrProf.dll\PowerApplySettingChanges", "Ptr", SubGroupGuid, "Ptr", SettingGuid, "UInt"))
}





/*
    Sets the AC value index of the specified power setting.
    Parameters:
        SchemeGuid:
            See the PowerSetActiveScheme function.
        SubGroupGuid:
            The subgroup of power settings.
            This parameter must be a pointer to a GUID structure (integer) or a Buffer object.
            This parameter can refer to one of the following GUIDs. Use NO_SUBGROUP_GUID to refer to the default power scheme.
            NO_SUBGROUP_GUID                     fea3413e-7e05-4911-9a71-700331f1c294     Settings in this subgroup are part of the default power scheme.
            GUID_DISK_SUBGROUP                   0012ee47-9041-4b5d-9b77-535fba8b1442     Settings in this subgroup control power management configuration of the system's hard disk drives.
            GUID_SYSTEM_BUTTON_SUBGROUP          4f971e89-eebd-4455-a8de-9e59040e7347     Settings in this subgroup control configuration of the system power buttons.
            GUID_PROCESSOR_SETTINGS_SUBGROUP     54533251-82be-4824-96c1-47b60b740d00     Settings in this subgroup control configuration of processor power management features. 
            GUID_VIDEO_SUBGROUP                  7516b95f-f776-4464-8c53-06167f40cc99     Settings in this subgroup control configuration of the video power management features. 
            GUID_BATTERY_SUBGROUP                e73a048d-bf27-4f12-9731-8b2076e8891f     Settings in this subgroup control battery alarm trip points and actions. 
            GUID_SLEEP_SUBGROUP                  238C9FA8-0AAD-41ED-83F4-97BE242C8F20     Settings in this subgroup control system sleep settings. 
            GUID_PCIEXPRESS_SETTINGS_SUBGROUP    501a4d13-42af-4429-9fd1-a8218c268e20     Settings in this subgroup control PCI Express settings. 
        SettingGuid:
            The identifier of the power setting.
            This parameter must be a pointer to a GUID structure (integer) or a Buffer object.
        ValueIndex:
            The AC value index.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. To get extended error information, check ErrorLevel.
*/
PowerWriteACValueIndex(SchemeGuid, SubGroupGuid, SettingGuid, ValueIndex)
{
    return !(ErrorLevel := DllCall("PowrProf.dll\PowerWriteACValueIndex", "Ptr", 0, "Ptr", SchemeGuid, "Ptr", SubGroupGuid, "Ptr", SettingGuid, "UInt", ValueIndex, "UInt"))
} ; https://docs.microsoft.com/en-us/windows/desktop/api/Powersetting/nf-powersetting-powerwriteacvalueindex





/*
    Sets the DC index of the specified power setting. See the PowerWriteACValueIndex function.
*/
PowerWriteDCValueIndex(SchemeGuid, SubGroupGuid, SettingGuid, ValueIndex)
{
    return !(ErrorLevel := DllCall("PowrProf.dll\PowerWriteDCValueIndex", "Ptr", 0, "Ptr", SchemeGuid, "Ptr", SubGroupGuid, "Ptr", SettingGuid, "UInt", ValueIndex, "UInt"))
} ; https://docs.microsoft.com/en-us/windows/desktop/api/powersetting/nf-powersetting-powerwritedcvalueindex
