/*
    Intenta ejecutar este Script como Administrador.
    Return:
        0 = No se ha podido ejecutar como Administrador.
        1 = El Script ya cuenta con permisos de Administrador.
        2 = El Script se ha ejecutado como Administrador con éxito.
*/
RunAsAdmin()
{
    if ( A_Args.Length() && A_Args[1] == A_ThisFunc && A_Args.RemoveAt(1) )
        return A_IsAdmin ? 2 : FALSE

    if ( A_IsAdmin )
        return TRUE

    local Params := ""
    loop ( A_Args.Length() )
        Params .= " `"" . A_Args[A_Index] . "`""

    if ( A_IsCompiled )
        Run("*RunAs `"" . A_ScriptFullPath . "`" " . A_ThisFunc . Params)
    else
        Run("*RunAs `"" . A_AhkPath . "`" `"" . A_ScriptFullPath . "`" " . A_ThisFunc . Params)
    ExitApp
}










/*
; ========================================================================================================
; EJEMPLO
; ========================================================================================================
#SingleInstance Force  ; permitir única instancia
if ( RunAsAdmin() == 0 )  ; si no se ha podido ejecutar como administrador
{
    ; Muestra un mensaje y termina el script si el usuario elige la opcion "Cancelar".
    if ( MsgBox("No se ha podido ejecutar como administrador.",, 0x1031) == "Cancel" )
        ExitApp
}
*/
