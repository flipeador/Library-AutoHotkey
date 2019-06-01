/*
    HTTP Status Codes:
        https://docs.microsoft.com/es-es/windows/desktop/WinHttp/http-status-codes.
*/
DownloadText(Url, Timeout := 30)
{
    local

    ; Creates an WinHttpRequest object.
    ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/winhttprequest.
    WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")  ; Msxm12.XMLHTTP

    try
    {
        ; IWinHttpRequest::Open method.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-open.
        WinHttpReq.Open("GET", RegExReplace(Url,"^(www\.).*","https://$0"), TRUE)

        ; IWinHttpRequest::SetRequestHeader method.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-setrequestheader.
        WinHttpReq.SetRequestHeader("Pragma", "no-cache")
        WinHttpReq.SetRequestHeader("Cache-Control", "no-cache")

        ; IWinHttpRequest::Send method.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-send.
        WinHttpReq.Send()

        ; IWinHttpRequest::WaitForResponse method.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-waitforresponse.
        if (WinHttpReq.WaitForResponse(Timeout) == 0)
        {
            ErrorLevel := 408  ; HTTP_STATUS_REQUEST_TIMEOUT
            return ""
        }

        ; Retrieves the HTTP status code from the last response.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-status.
        If (WinHttpReq.Status !== 200)  ; HTTP_STATUS_OK = 200.
        {
            ErrorLevel := WinHttpReq.Status
            return ""
        }

        ; IWinHttpRequest::ResponseText property.
        ; https://docs.microsoft.com/es-es/windows/desktop/WinHttp/iwinhttprequest-responsetext.
        ErrorLevel := FALSE
        return WinHttpReq.ResponseText
    }
    catch Exception
        ErrorLevel := Exception.Message

    ErrorLevel := TRUE
    return ""
}





; MsgBox(Format("Text:`n{}`n`nErrorLevel:`n{}",DownloadText("www.autohotkey.com/download/2.0/version.txt"),ErrorLevel))
