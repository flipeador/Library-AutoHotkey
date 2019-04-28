/*
    HTTP Status Codes:
        https://docs.microsoft.com/es-es/windows/desktop/WinHttp/http-status-codes.
    Example:
        MsgBox("ResponseText:`n`t" . DownloadText("https://autohotkey.com/download/2.0/version.txt") . "`n`nErrorLevel:`n`t" . ErrorLevel)
*/
DownloadText(Url, Timeout := 30)
{
    local

    try
    {
        ; Creates an WinHttpRequest object.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/winhttprequest.
        WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")

        ; Opens an HTTP connection to an HTTP resource.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-open.
        WinHttpReq.Open("GET", Url, TRUE)

        ; Sends an HTTP request to an HTTP server.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-send.
        WinHttpReq.Send()

        ; Waits for an asynchronous Send method to complete, with optional time-out value, in seconds.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-waitforresponse.
        if WinHttpReq.WaitForResponse(Timeout) == 0
        {
            ErrorLevel := 408 ; HTTP_STATUS_REQUEST_TIMEOUT.
            return ""
        }

        ; Retrieves the HTTP status code from the last response.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-status.
        If WinHttpReq.Status !== 200  ; HTTP_STATUS_OK = 200.
        {
            ErrorLevel := WinHttpReq.Status
            return ""
        }

        ; Retrieves the response entity body as text.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-responsetext.
        ErrorLevel := FALSE
        return WinHttpReq.ResponseText
    }
    catch Exception
        ErrorLevel := StrSplit(Exception.Message, A_Space)[1]
    return ""
}
