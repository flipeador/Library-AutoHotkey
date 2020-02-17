#Include ..\mci.ahk
#SingleInstance Force


Gui := GuiCreate(, "Media Control Interface (MCI)")
Gui.AddButton("w100", "Select").OnEvent("Click", "Select")
Gui.AddButton("w100", "Play").OnEvent("Click", "Play")
Gui.AddButton("w100", "Pause").OnEvent("Click", "Pause")
Gui.AddButton("w100", "Resume").OnEvent("Click", "Resume")
Gui.AddText("w150 vlen", "Length: 00:00:00")
Gui.Show("w200")
Gui.OnEvent("Close", "ExitApp")
return


Select(*)
{
    global
    mci := MCI_Open(FileSelect())
    Gui["len"].Text := "Length: " . mstotime(mci.GetStatus("length"))
}

Play(*)
{
    global
    mci.Play()
}

Pause(*)
{
    global
    mci.Pause()
}

Resume(*)
{
    global
    mci.Resume()
}

mstotime(ms)
{
    return Format("{:02}:{:02}:{:02}"  ; Floor(ms/86400000)  ; days
        , Floor(Mod(ms/3600000,24))
        , Floor(Mod(ms/60000,60))
        , Floor(Mod(ms/1000,60)))
} ; https://www.autohotkey.com/boards/viewtopic.php?t=45476#p217893
