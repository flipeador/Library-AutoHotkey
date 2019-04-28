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
    static Unreserved := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
    local Encoded := ""

    If ( Encoding = "UTF-16" )
        loop parse, Url
            Encoded .= InStr(Unreserved,A_LoopField) ? A_LoopField : Format("%u{:04X}",Ord(A_LoopField))
    else if ( Encoding = "UTF-8" )
    {
        local Buffer := "", Code := VarSetCapacity(Buffer,StrPut(Url,"UTF-8")) . StrPut(Url,&Buffer,"UTF-8")
        while ( Code := NumGet(&Buffer+A_Index-1,"UChar") )
            Encoded .= InStr(Unreserved,Chr(Code)) ? Chr(Code) : Format("%{:02X}",Code)
    }
    else
        throw Exception("Function URLEncode invalid parameter #2.", -1)

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
    local dec := "", T := 0

    if ( InStr(Url,"%u") )  ; UTF-16
    {
        loop parse, Url
            dec .= A_LoopField == "%" ? Chr("0x" . SubStr(Url,A_Index+2,(T:=5)-1)) : ( --T > -1 ? "" : A_LoopField )
        return dec
    }

    loop parse, Url
        dec .= A_LoopField == "%" ? Chr("0x" . SubStr(Url,A_Index+1,T:=2)) : ( --T > -1 ? "" : A_LoopField )
    local utf8 := "", _ := VarSetCapacity(utf8,StrPut(dec,"UTF-8"))
    loop Parse, dec
        NumPut(Ord(A_LoopField), &utf8 + A_Index - 1, "UChar")

    return StrGet(&utf8, "UTF-8")
} ;https://autohotkey.com/boards/viewtopic.php?t=4868
