File := FileSelect() . ":Zone.Identifier"
if (ErrorLevel)
    ExitApp()

; Reads the current zone identifier.
R := IniRead(File, "ZoneTransfer", "ZoneId")
MsgBox("ZoneId: " . (ErrorLevel?"ERROR":R))

; Writes a new zone identifier.
; URLZONE_INTERNET = 3.
IniWrite(3, File, "ZoneTransfer", "ZoneId")
MsgBox("Write: " . (ErrorLevel?"ERROR":"OK"))

; Reads the new zone identifier.
R := IniRead(File, "ZoneTransfer", "ZoneId")
MsgBox("ZoneId: " . (ErrorLevel?"ERROR":R))

; Deletes the file security zone.
R := FileDelete(File)
MsgBox("Delete: " . (R?"OK":"ERROR"))

ExitApp()
