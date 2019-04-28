/*
    Reinicia un servicio.
    Return:
        -1 = Error de OpenSCManager.
        -2 = Error de OpenService.
         1 = Error al intentar detener el servicio. Si el servicio ya se encuentra detenido el error ERROR_SERVICE_NOT_ACTIVE (1062) de ControlService se ignora.
         2 = Error al intentar iniciar el servicio.
    Observaciones:
        En caso de error, puede consultar la variable A_LastError para más información.
    Ejemplo:
        MsgBox RestartService("spooler")
*/
RestartService(hService, NumServiceArgs := 0, ServiceArgVectors := 0, ByRef SERVICE_STATUS := "")    ; 0 = ERROR_SUCCESS
{
    If (Type(hService) == "Integer")
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682108(v=vs.85).aspx
        VarSetCapacity(SERVICE_STATUS, 7 * 4, 0)
        If (!DllCall("AdvApi32.dll\ControlService", "Ptr", hService, "UInt", 0x00000001, "UPtr", &SERVICE_STATUS) && A_LastError != 1062)    ; SERVICE_CONTROL_STOP = 0x00000001 | ERROR_SERVICE_NOT_ACTIVE = 1062
            Return 1    ; comprobando el valor de A_LastError nos aseguramos de que la función no falle si el servicio ya se encuentra detenido (ignoramos el "error" si ya se encuentra detenido)

        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms686321(v=vs.85).aspx
        Return DllCall("AdvApi32.dll\StartServiceW", "Ptr", hService, "UInt", NumServiceArgs, "UPtr", ServiceArgVectors) ? 0 : 2
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684323(v=vs.85).aspx
    Local hSCManager
    If (!(hSCManager := DllCall("Advapi32.dll\OpenSCManagerW", "Ptr", 0, "Ptr", 0, "UInt", 0xF003F, "Ptr")))
        Return -1

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684330(v=vs.85).aspx
    If (!(hService := DllCall("Advapi32.dll\OpenServiceW", "Ptr", hSCManager, "UPtr", &hService, "UInt", 0x0020|0x0010, "Ptr")))    ; SERVICE_STOP|SERVICE_START
    {
        DllCall("AdvApi32.dll\CloseServiceHandle", "Ptr", hSCManager)
        Return -2
    }

    Local R := RestartService(hService, NumServiceArgs, ServiceArgVectors, SERVICE_STATUS)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682028(v=vs.85).aspx
    DllCall("AdvApi32.dll\CloseServiceHandle", "Ptr", hService, "UInt")
    DllCall("AdvApi32.dll\CloseServiceHandle", "Ptr", hSCManager, "UInt")

    Return R
} ; https://autohotkey.com/boards/viewtopic.php?f=5&t=46419&p=209579#p209579
