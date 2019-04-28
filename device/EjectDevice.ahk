/*
    Expulsar el dispositivo especificado. Puede ser una unidad de CD/DVD o un dispositivo removible (USB).
    Parámetros:
        RootPathName: El directorio raíz de la unidad.
        Retract     : Si es TRUE la unidad de CD/DVD se cierra (por defecto se abre).
    Return:
        -2 = No se ha podido expulsar el dispositivo.
        -1 = El dispositivo es inválido.
         0 = El dispositivo se ha expulsado con éxito.
         2 = ERROR_FILE_NOT_FOUND. El dispisitivo no existe.
        32 = ERROR_SHARING_VIOLATION. El dispositivo no se puede expulsar debido a que otra aplicación lo impide.
         X = Otro código de error.
*/
EjectDevice(RootPathName, Retract := FALSE)
{
    Local DriveType, Device, Size, R, STORAGE_DEVICE_NUMBER, BytesReturned, DeviceNumber, PNPDeviceID, hModule, VetoType, hDevInst, hParentDevInst, nVT, Obj
    
    RootPathName := SubStr(RootPathName, 1, 1) . ':'
    DriveType    := DllCall('Kernel32.dll\GetDriveTypeW', 'Str', RootPathName . '\')
    
    If (DriveType == 5)
    {
        DriveEject(RootPathName, Retract)
        Return (ErrorLevel ? -1 : 0)
    }

    If (DriveType != 2)
        Return (-1)

    If (!(Device := FileOpen('\\.\' . RootPathName, 'rw')))
        Return (A_LastError)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa363216(v=vs.85).aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb968800(v=vs.85).aspx
    Size   := VarSetcapacity(STORAGE_DEVICE_NUMBER, 4 * 3, 0)
    R      := DllCall('Kernel32.dll\DeviceIoControl', 'Ptr'  , Device.__Handle        ;hDevice
                                                    , 'UInt' , 0x2D1080               ;dwIoControlCode --> IOCTL_STORAGE_GET_DEVICE_NUMBER
                                                    , 'Ptr'  , 0                      ;lpInBuffer
                                                    , 'UInt' , 0                      ;nInBufferSize
                                                    , 'UPtr' , &STORAGE_DEVICE_NUMBER ;lpOutBuffer
                                                    , 'UInt' , Size                   ;nOutBufferSize
                                                    , 'UIntP', BytesReturned          ;lpBytesReturned
                                                    , 'Ptr'  , 0)                     ;lpOverlapped
    Device := ''

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb968801(v=vs.85).aspx
    If (NumGet(&STORAGE_DEVICE_NUMBER, 'UInt') != 7) ;DeviceType --> FILE_DEVICE_DISK
        Return (-1)

    DeviceNumber := NumGet(&STORAGE_DEVICE_NUMBER + 4, 'UInt')
    PNPDeviceID  := ''

    ; https://msdn.microsoft.com/en-us/library/aa394132(v=vs.85).aspx
    For Obj in ComObjGet('winmgmts:').ExecQuery('Select * from Win32_DiskDrive')
    {
        If (Obj.DeviceID == '\\.\PHYSICALDRIVE' . DeviceNumber && Obj.InterfaceType == 'USB')
        {
            PNPDeviceID := Obj.PNPDeviceID
            Break
        }
    }

    If (PNPDeviceID == '')
        Return (-1)

    hModule := DllCall('Kernel32.dll\LoadLibraryW', 'Str', 'SetupAPI.dll', 'Ptr')

    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff538742(v=vs.85).aspx
    DllCall('SetupAPI.dll\CM_Locate_DevNodeW', 'PtrP', hDevInst, 'UPtr', &PNPDeviceID, 'UInt', 0)

    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff538610(v=vs.85).aspx
    DllCall('SetupAPI.dll\CM_Get_Parent', 'PtrP', hParentDevInst, 'Ptr', hDevInst, 'UInt', 0, 'Cdecl')

    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff539806(v=vs.85).aspx
    VetoType := 1
    While (hParentDevInst && VetoType && A_Index < 4)
        DllCall('SetupAPI.dll\CM_Request_Device_EjectW', 'Ptr', hParentDevInst, 'PtrP', VetoType, 'Ptr', 0, 'UInt', 0, 'UInt', 0)

    DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)

    Return (nVT ? -2 : 0)
} ;http://ahkscript.org/boards/viewtopic.php?f=6&t=4491
