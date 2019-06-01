InternetCheckConnection(Url)
{
    return DllCall("WinINet.dll\InternetCheckConnectionW", "WStr", RegExReplace(Url, "^(www\.).*", "https://$0")
                                                         , "UInt", 1
                                                         , "UInt", 0)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa384346(v=vs.85).aspx





; MsgBox(InternetCheckConnection("www.google.com"))
