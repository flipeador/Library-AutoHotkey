/*
    Envía un EMAIL.
    Parámetros:
        Password   : La contraseña del EMAIL del remitente.
        From       : El EMAIL del remitente. Esta función solo soporta una cuenta de gmail.
        To         : El EMAIL del destinatario.
        Subject    : Opcional. El asunto o título del mensaje.
        Body       : Opcional. El cuerpo del mensaje.
        Attachments: Opcional. Un array con archivos a adjuntar o URLs.
    Return:
        Devuelve 1 si tuvo éxito, o 0 en caso contrario.
    Observaciones:
        Antes de enviar un email, debe activar el acceso a aplicaciones menos seguras en el email del remitente.
        Less Secure Apps: https://www.google.com/settings/security/lesssecureapps
*/
SendEmail(Password, From, To, Subject := "", Body := "", Attachments := 0)
{
    local

    Try
    {
        CdoMsg          := ComObjCreate("CDO.Message")
        CdoMsg.From     := From
        CdoMsg.To       := To
        CdoMsg.Subject  := Subject
        CdoMsg.TextBody := Body

        For Each, Attachment In Attachments
            CdoMsg.AddAttachment(Attachment)

        CdoConf         := CdoMsg.Configuration.Fields
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver")            := "smtp.gmail.com"
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport")        := 465
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl")            := TRUE
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/sendusing")             := 2
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate")      := 1
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/sendusername")          := From
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword")          := Password
        CdoConf.Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") := 60

        CdoConf.Update()

        CdoMsg.Send()
    }
    Catch
        Return (FALSE)

    Return (TRUE)
} ;https://msdn.microsoft.com/en-us/library/ms526130(v=exchg.10).aspx
