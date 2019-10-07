#Warn
#SingleInstance Force

#Include ..\Device.ahk





for VolumeName in EnumerateVolumes()
{
    DeviceNames := ""
    for DeviceName in (QueryDosDevice(VolumeName) || ["Error"])
        DeviceNames := A_Tab . DeviceName . "`n"
    VolumePathNames := ""
    for VolumePathName in (GetVolumePathNames(VolumeName) || ["Error"])
        VolumePathNames .= A_Tab . VolumePathName . "`n"
    MsgBox(Format("VolumeName:`n`t{1}{4}DeviceNames:`n{2}{4}VolumePathNames:`n{3}",VolumeName,DeviceNames,VolumePathNames,"`n-----------------------`n"))
}

; https://docs.microsoft.com/en-us/windows/win32/fileio/displaying-volume-paths