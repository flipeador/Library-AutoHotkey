#Include File.ahk
#Include Device.ahk





/*
    Prepares a local device instance for safe removal, if the device is removable. If the device can be physically ejected, it will be.
    Parameters:
        Device:
            Specifies the device to be ejected. Only the first character (device letter) is used.
    Return value:
        Returns TRUE if successful, or FALSE otherwise.
*/
DeviceEject(Device)
{
    local

    ; Opens the «Device» volume.
    if !(hVol := OpenFile("\\.\" . SubStr(Trim(Device),1,1) . ":"))
        return FALSE

    ; Gets the device type, device number, and, for a partitionable device, the partition number of a device.
    Info := DeviceIoControl(hVol,0x2D1080,,BufferAlloc(12))  ; IOCTL_STORAGE_GET_DEVICE_NUMBER.
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hVol)
    if (!Info)
        return FALSE
    ; Info.OutBuffer contains a STORAGE_DEVICE_NUMBER structure.

    ; Gets an object using WMI\Win32_DiskDrive containing information of the device.
    DeviceNumber := NumGet(Info.OutBuffer, 4, "UInt")  ; The number of this device.
    DiskDrive    := QueryWMIDeviceID(DeviceNumber)     ; Object.

    ; Checks the type of media used or accessed by this device.
    MediaType := "[" . DiskDrive.MediaType . "]"
    if (!InStr("[Removable Media][External hard disk media]",MediaType))
        return FALSE

    ; Gets a device instance handle to the device node that is associated with this device.
    PNPDeviceID := DiskDrive.PNPDeviceID       ; Windows Plug and Play device identifier.
    hDevInst    := LocateDevNode(PNPDeviceID)

    ; Gets a device instance handle to the parent node of the device node (devnode).
    hParentDevInst := DeviceGetParent(hDevInst)

    ; Prepares the local device instance for safe removal, if the device is removable. If the device can be physically ejected, it will be.
    return DeviceRequestEject(hParentDevInst)
} ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4491
