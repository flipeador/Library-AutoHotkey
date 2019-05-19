/*
    Encode a string in URL Encoding.
    Parámetros:
        Url:
            The string to be encoded.
        Encoding
            The encoding to use. The standard is UTF-8. UTF-16 is a non-standard implementation and is not always recognized.
*/
URLEncode(Url, Encoding := "UTF-8")
{
    local
    static Unreserved := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"

    Encoded := ""

    if (Encoding = "UTF-16")
    {
        Loop Parse, Url
            Encoded .= InStr(Unreserved,A_LoopField) ? A_LoopField : Format("%u{:04X}",Ord(A_LoopField))
    }

    else if (Encoding = "UTF-8")
    {
        Buffer := BufferAlloc(StrPut(Url,"UTF-8"))
        StrPut(Url, Buffer, "UTF-8")

        while (Code := NumGet(Buffer,A_Index-1,"UChar"))
            Encoded .= InStr(Unreserved,Chr(Code)) ? Chr(Code) : Format("%{:02X}",Code)
    }

    else
        throw Exception("URLEncode function, invalid parameter #2.", -1)

    return Encoded
} ;http://rosettacode.org/wiki/URL_encoding#AutoHotkey | https://en.wikipedia.org/wiki/Percent-encoding





/*
    Decode a string in URL Encoding.
    Parameters:
        Url:
            The string to decode. The encoding is detected automatically.
*/
URLDecode(Url)
{
    local

    dec := ""
    T   := 0

    if (InStr(Url,"%u"))  ; UTF-16.
    {
        loop parse, Url
            dec .= A_LoopField == "%" ? Chr("0x" . SubStr(Url,A_Index+2,(T:=5)-1)) : ( --T > -1 ? "" : A_LoopField )
        return dec
    }

    Loop Parse, Url
        dec .= A_LoopField == "%" ? Chr("0x" . SubStr(Url,A_Index+1,T:=2)) : ( --T > -1 ? "" : A_LoopField )

    Buffer := BufferAlloc(StrPut(dec,"UTF-8"))
    Loop Parse, dec
        NumPut("UChar", Ord(A_LoopField), Buffer, A_Index-1)
    NumPut("UChar", 0x00, Buffer, Buffer.Size-1)

    return StrGet(Buffer, "UTF-8")
} ;https://autohotkey.com/boards/viewtopic.php?t=4868
