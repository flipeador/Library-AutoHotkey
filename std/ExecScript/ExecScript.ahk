ExecScript(Script, CommandLine := "", WorkingDir := "", AhkPath := "", CreationFlags := 0)
{
    global Subprocess
    local

    ModuleFilename := AhkPath == "" ? A_AhkPath : AhkPath
    CommandLine    := Format("`"{}`" {} {}", ModuleFilename, "/CP65001 /ErrorStdOut *", CommandLine)
    WorkingDir     := DirExist(WorkingDir) ? WorkingDir : 0

    ahk := new Subprocess(CommandLine, WorkingDir, CreationFlags)
    if !ahk
        return 0

    ahk.StdIn.Encoding := "UTF-8"
    ahk.StdIn.Write(Script . "`nExitApp(0)`n#Persistent")
    ahk.StdIn.Close()

    ahk.StdOut.Encoding := "UTF-8"
    ahk.StdErr.Encoding := "UTF-8"

    return ahk
}
