#Warn
#Include ..\Base64.ahk


Text := InputBox("Text to encode.",,, "AutoHotkey!")
if (ErrorLevel)
    ExitApp()

MsgBox(
       Format(
              "{1}`nEncoded UTF-16: {2}`nEncoded UTF-8: {3}`n`nDecoded UTF-16: {4}`nDecoded UTF-8: {5}"
            , Text . "`n-------------------------------------"
            , e16 := Base64Encode(Text, "UTF-16")
            , e8  := Base64Encode(Text, "UTF-8")
            , Base64DecodeStr(e16, "UTF-16")
            , Base64DecodeStr(e8, "UTF-8")
             )
      )
