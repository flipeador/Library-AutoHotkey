/*
    Retrieve an array with the Urls detected in the specified string.
    Parámeters:
        Text:
            String to search for URLs.
        Unreserved:
            A RegEx pattern that specifies the valid characters in a URL.
    Return value:
        Returns an array containing objects with the keys 'url', 'start' and 'end'.
    What characters are valid in a URL?:
        https://stackoverflow.com/questions/7109143/what-characters-are-valid-in-a-url
    Example:
        for i, obj in StrGetUrl("X.www.google.com|wwww.autohotkey.com|")
            MsgBox("Url: " . obj.url . "`nStart: " . obj.start . "`nEnd: " . obj.end)
*/
StrGetUrl(ByRef Text, Unreserved := "\w\./:\?&=\-_~\+\=\$@")
{
    local pos := [0], arr := []
    local txt := Text . A_Space

    while ( pos[1] := RegExMatch(txt,"i)((ftp|http(s|))\://|www\.)[\w]+",,pos[1]+1) )
        arr.push( {   url: RTrim(SubStr(txt,pos[1],(pos[2]:=RegExMatch(txt,"[^" . Unreserved . "]",,pos[1]))-pos[1]),"./:;?@&=+$,{|^[``")
                  , start: pos[ 1 ]
                  ,   end: pos[ 2 ]   } )

    return arr
}





/*
    Search for a Url in a specific position from a string.
    Parámeters:
        Caret:
            The caret position on the string specified in the Text parameter.
    Return value:
        Returns an object with the keys 'url', 'start' and 'end'.
    Example:
        MsgBox("Url: " . (o:=GetUrlCaret("www.google.com www.autohotkey.com",1)).url . "`nStart: " . o.start . "`nEnd: " . o.end)
        MsgBox("Url: " . (o:=GetUrlCaret("www.google.com www.autohotkey.com",16)).url . "`nStart: " . o.start . "`nEnd: " . o.end)
*/
GetUrlCaret(ByRef Text, Caret, Unreserved := "\w\./:\?&=\-_~\+\=\$@")
{
    local pos := [0], url := ""
    local txt := Text . A_Space

    while ( pos[1] := RegExMatch(txt,"i)((ftp|http(s|))\://|www\.)[\w]+",,pos[1]+1) )
    {
        url := RTrim(SubStr(txt,pos[1], (pos[2]:=RegExMatch(txt,"[^" . Unreserved . "]",,pos[1]))-pos[1]), "./:;?@&=+$,{|^[``")
        if ( caret >= pos[1] && caret <= pos[2] )
            return { url:url, start:pos[1], end:pos[2] }
    }

    return ""
}
