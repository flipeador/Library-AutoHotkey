#DllLoad SetupAPI.dll





/*
    Gets a device instance handle to the device node that is associated with a specified device instance ID.
    Parameters:
        DeviceID:
            A string representing a device instance ID.
            If this parameter is an empty string, the function retrieves a device instance handle to the device at the root of the device tree.
            This parameter can be a device number, device identifier or a PnP device identifier.
        Flags:
            Flag values that apply if the caller supplies a device instance identifier:
            0x00000000  CM_LOCATE_DEVNODE_NORMAL          The function retrieves the device instance handle for the specified device only if the device is currently configured in the device tree.
            0x00000001  CM_LOCATE_DEVNODE_PHANTOM         The function retrieves a device instance handle for the specified device if the device is currently configured in the device tree or the device is a nonpresent device that is not currently configured in the device tree.
            0x00000002  CM_LOCATE_DEVNODE_CANCELREMOVE    The function retrieves a device instance handle for the specified device if the device is currently configured in the device tree or in the process of being removed from the device tree. If the device is in the process of being removed, the function cancels the removal of the device.
            0x00000004  CM_LOCATE_DEVNODE_NOVALIDATION    Not used.
            0x00000007  CM_LOCATE_DEVNODE_BITS            -
    Return value:
        If the function succeeds, the return value is the device instance handle to the device node.
        If the function fails, the return value is zero. ErrorLevel contains a Configuration Manager CONFIGRET status code.
*/
LocateDevNode(DeviceID, Flags := 0)
{
    if (InStr(DeviceID,"PHYSICALDRIVE") || DeviceID is "Number")  ; Device number/identifier?.
        DeviceID := (DeviceID:=QueryWMIDeviceID(DeviceID)) ? DeviceID.PNPDeviceID : A_Tab  ; Get the PnP device identifier.

    local hDevInst := 0
    return (ErrorLevel := DllCall("SetupAPI.dll\CM_Locate_DevNodeW", "UPtrP", hDevInst  ; pdnDevInst.
                                                                   ,  "WStr", DeviceID  ; pDeviceID.
                                                                   ,  "UInt", Flags     ; ulFlags.
                                                                   ,  "UInt"))          ; Return type.
         ? 0         ; Error.
         : hDevInst  ; Ok.
} ; https://docs.microsoft.com/en-us/windows/win32/api/cfgmgr32/nf-cfgmgr32-cm_locate_devnodew





/*
    Gets a device instance handle to the parent node of a specified device node (devnode) in the local machine's device tree.
    Parameters:
        hDevInst:
            The device instance handle that is bound to the local machine.
    Return value:
        If the function succeeds, the return value is the device instance handle to the parent node.
        If the function fails, the return value is zero. ErrorLevel contains a Configuration Manager CONFIGRET status code.
*/
DeviceGetParent(hDevInst)
{
    local hParentDevInst := 0
    return (ErrorLevel := DllCall("SetupAPI.dll\CM_Get_Parent", "UPtrP", hParentDevInst  ; pdnDevInst.
                                                              ,  "UPtr", hDevInst        ; dnDevInst.
                                                              ,  "UInt", 0               ; ulFlags.
                                                              ,  "UInt"))                ; Return type.
         ? 0               ; Error.
         : hParentDevInst  ; Ok.
} ; https://docs.microsoft.com/en-us/windows/win32/api/cfgmgr32/nf-cfgmgr32-cm_get_parent





/*
    Prepares a local device instance for safe removal, if the device is removable. If the device can be physically ejected, it will be.
    Parameters:
        hDevInst:
            The device instance handle that is bound to the local machine.
    Return value:
        If the function succeeds, the return value is «hDevInst».
        If the function fails, the return value is zero. ErrorLevel contains a Configuration Manager CONFIGRET status code.
*/
DeviceRequestEject(hDevInst)
{
    local VetoType := 0                     ; Receives a value indicating the reason for the failure.
    local VetoName := BufferAlloc(2*260,0)  ; Receives a string with the reason for the failure. MAX_PATH = 260.
    return (ErrorLevel := DllCall("SetupAPI.dll\CM_Request_Device_EjectW", "UPtr", hDevInst          ; dnDevInst.
                                                                         , "IntP", VetoType          ; pVetoType.
                                                                         ,  "Ptr", VetoName          ; pszVetoName.
                                                                         , "UInt", VetoName.Size//2  ; ulNameLength.
                                                                         , "UInt", 0                 ; ulFlags.
                                                                         , "UInt"))                  ; Return type.
         ? 0         ; Error.
         : hDevInst  ; Ok.
} ; https://docs.microsoft.com/en-us/windows/win32/api/cfgmgr32/nf-cfgmgr32-cm_request_device_ejectw





/*
    Gets an object using WMI\Win32_DiskDrive containing information of the specified device.
    Parameters:
        DeviceID:
            The unique identifier of the device.
            This parameter must be an integer or a string containing an integer anywhere.
    Return value:
        If the function succeeds, the return value is an object.
        If the function fails, the return value is zero.
    Remarks:
        A device number is a unique identifier of a device with other devices on the system.
        A device identifier is a string with the format "\\.\PHYSICALDRIVE<device_number>".
        A PnP (Windows Plug and Play) device identifier is a string with the format "<device-ID>\<instance-specific-ID>".
    Device Instance ID (PnP):
        https://docs.microsoft.com/en-us/windows-hardware/drivers/install/device-instance-ids
*/
QueryWMIDeviceID(DeviceID)
{
    local DiskDrive := 0  ; Default return value.
    DeviceID := "\\\\.\\PHYSICALDRIVE" . RegExReplace(DeviceID, "[^\d]")  ; DeviceID: "\\.\PHYSICALDRIVE<device_number>".
    ComObjGet("winmgmts:").ExecQuery(Format("Select * from Win32_DiskDrive where DeviceID='{}'",DeviceID))._NewEnum()[DiskDrive]
    return DiskDrive
} ; https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-diskdrive





/*
    Sends a control code directly to a specified device driver, causing the corresponding device to perform the corresponding operation.
    Parameters:
        hDevice:
            A handle to the device on which the operation is to be performed.
            The device is typically a volume, directory, file, or stream.
            To retrieve a device handle, use the Kernel32\CreateFile function.
        IoControlCode:
            The control code for the operation.
            This value identifies the specific operation to be performed and the type of device on which to perform it.
        InBuffer:
            The input buffer that contains the data required to perform the operation.
            The format of this data depends on the value of the «IoControlCode» parameter.
            This parameter can be zero if «IoControlCode» specifies an operation that does not require input data.
            This parameter must be a Buffer-like object with properties Ptr and Size.
        OutBuffer:
            The output buffer that is to receive the data returned by the operation.
            The format of this data depends on the value of the «IoControlCode» parameter.
            This parameter can be zero if «IoControlCode» specifies an operation that does not return data.
            This parameter must be a Buffer-like object with properties Ptr and Size.
        Overlapped:
            Specifies an OVERLAPPED structure.
            If the device was opened without specifying FILE_FLAG_OVERLAPPED, this parameter is ignored.
            If the device was opened with the FILE_FLAG_OVERLAPPED flag, the operation is performed as an overlapped (asynchronous) operation.
            The OVERLAPPED structure must contains a handle to an event object. Otherwise, the function fails in unpredictable ways.
            For overlapped operations, this function returns immediately, and the event object is signaled when the operation has been completed.
            By default, this function does not return until the operation has been completed or an error occurs.
    Return value:
        If the function succeeds, the return value is an object with properties InBuffer, OutBuffer and BytesReturned.
        If the function fails, the return value is zero. A_LastError contains a system error code.
*/
DeviceIoControl(hDevice, IoControlCode, InBuffer := 0, OutBuffer := 0, Overlapped := 0)
{
    local BytesReturned := 0
    return DllCall("Kernel32.dll\DeviceIoControl",  "UPtr", hDevice                    ; hDevice.
                                                 ,  "UInt", IoControlCode              ; dwIoControlCode.
                                                 ,   "Ptr", InBuffer                   ; lpInBuffer.
                                                 ,  "UInt", InBuffer&&InBuffer.Size    ; nInBufferSize.
                                                 ,   "Ptr", OutBuffer                  ; lpOutBuffer.
                                                 ,  "UInt", OutBuffer&&OutBuffer.Size  ; nOutBufferSize.
                                                 , "UIntP", BytesReturned              ; lpBytesReturned.
                                                 ,   "Ptr", Overlapped)                ; lpOverlapped.
         ? {InBuffer:InBuffer,OutBuffer:OutBuffer,BytesReturned:BytesReturned}  ; Ok.
         : 0                                                                    ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/ioapiset/nf-ioapiset-deviceiocontrol





/*
    Enumerates the volumes in the system.
    Return value:
        If the function succeeds, the return value is an Array of volume GUID paths for each volume.
        If the function fails, the return value is zero. A_LastError contains a system error code.
*/
EnumerateVolumes()
{
    local hFindVolume, List := 0, Buffer := BufferAlloc(2*260)
    If (hFindVolume := DllCall("Kernel32.dll\FindFirstVolumeW", "Ptr", Buffer, "UInt", Buffer.Size//2, "Ptr")) !== -1
    {
        List := [StrGet(Buffer)]
        while DllCall("Kernel32.dll\FindNextVolumeW", "Ptr", hFindVolume, "Ptr", Buffer, "UInt", Buffer.Size//2)
            List.Push(StrGet(Buffer))
        DllCall("Kernel32.dll\FindVolumeClose", "Ptr", hFindVolume)
    }
    return List
} ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstvolumew





/*
    Retrieves a list of drive letters and mounted folder paths for the specified volume.
    Parameters:
        VolumeName:
            A volume GUID path for the volume.
            A volume GUID path is of the form "\\?\Volume{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}\".
    Return value:
        If the function succeeds, the return value is an Array of drive letters ("X:\") and mounted folder paths.
        If the function fails, the return value is zero. A_LastError contains a system error code.
*/
GetVolumePathNames(VolumeName)
{
    local RequiredSize := 0
    DllCall("Kernel32.dll\GetVolumePathNamesForVolumeNameW", "Str", VolumeName, "Ptr", 0, "UInt", 0, "UIntP", RequiredSize)
    local Buffer := BufferAlloc(2*RequiredSize, 0)
    if !DllCall("Kernel32.dll\GetVolumePathNamesForVolumeNameW", "Str", VolumeName, "Ptr", Buffer, "UInt", Buffer.Size//2, "UIntP", 0)
        return 0

    local Name := "", Ptr := Buffer.Ptr, List := []
    while StrLen(Name:=StrGet(Ptr))
        List.Push(Name), Ptr += StrPut(Name)
    return List
} ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getvolumepathnamesforvolumenamew





/*
    Retrieves information about the specified MS-DOS device.
    Parameters:
        DeviceName:
            An MS-DOS device name string specifying the target of the query.
            This parameter can be a path or string like "\\?\Volume{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}\".
            If this parameter is an empty string, the function will return a list of all existing MS-DOS device names.
    Return value:
        If the function succeeds, the return value is an Array with one or more strings.
        - The first string stored into the Array is the current mapping for the device.
        - The other strings represent undeleted prior mappings for the device.
        If the function fails, the return value is zero. A_LastError contains a system error code.
*/
QueryDosDevice(DeviceName)
{
    DeviceName := RTrim(RegExReplace(DeviceName,"i)^(\\\\\?\\)?Volume"),"\")                          ; Remove "\\?\Volume" from the start and "\" at the end.
    DeviceName := SubStr(DeviceName,1,1)=="{" ? "Volume" . DeviceName : SubStr(DeviceName,1,1) . ":"  ; Add "Volume" or take the first character + ":".
    local Buffer := BufferAlloc(24*(2*(24+2)), 0)
    if !DllCall("Kernel32.dll\QueryDosDeviceW", "UPtr", DeviceName==""?0:&DeviceName  ; lpDeviceName.
                                              , "UPtr", Buffer.Ptr                    ; lpTargetPath.
                                              , "UInt", Buffer.Size                   ; ucchMax.
                                              , "UInt")                               ; Return type.

        return 0  ; Error.

    local Name := "", Ptr := Buffer.Ptr, List := []
    while StrLen(Name:=StrGet(Ptr))
        List.Push(Name), Ptr += StrPut(Name)
    return List  ; Ok.
} ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-querydosdevicew
