/*
    Starts the Run file dialog that you see when launching applications from the Start/Run menu.
    Parameters:
        Owner:
            The handle of the owner window, receives notifications. This value can be zero.
        WorkingDir:
            The name of the Working directory.
            This parameter can be a string or a pointer to a null-terminated string.
            If this directory does not exist, the current working directory is used.
        Title:
            The dialog title, if zero default is displayed.
            This parameter can be a string or a pointer to a null-terminated string.
        Description:
            The dialog description, if zero default is displayed.
            This parameter can be a string or a pointer to a null-terminated string.
        hIcon:
            The dialog icon handle (integer), if zero default icon is used.
        Flags:
            You can specify one or more of the following values.
            0x00000001  RFF_NOBROWSE         Remove the browse button.
            0x00000002  RFF_NODEFAULT        No default item selected.
            0x00000004  RFF_CALCDIRECTORY    Calculate the working directory from the file name.
            0x00000008  RFF_NOLABEL          Remove the edit box label.
            0x00000014  RFF_NOSEPARATEMEM    Remove the Separate Memory Space check box, NT only.
*/
RunFileDlg(Owner := 0, WorkingDir := "", Title := 0, Description := 0, hIcon := 0, Flags := 0)
{
    local

    Owner        := DllCall("User32.dll\IsWindow","Ptr",Owner) ? Owner : A_ScriptHwnd
    WorkingDir   := Type(WorkingDir)  == "Integer" ? WorkingDir  : String(WorkingDir)
    pWorkingDir  := Type(WorkingDir)  == "Integer" ? WorkingDir  : DirExist(WorkingDir) ? &WorkingDir : &A_WorkingDir
    pTitle       := Type(Title)       == "Integer" ? Title       : &(Title      :=String(Title)      )
    pDescription := Type(Description) == "Integer" ? Description : &(Description:=String(Description))

    hModule     := DllCall("Kernel32.dll\GetModuleHandleW", "Str", "Shell32.dll", "Ptr")
    pRunFileDlg := DllCall("Kernel32.dll\GetProcAddress", "Ptr", hModule, "UInt", 61, "Ptr")

    DllCall(pRunFileDlg, "Ptr", Owner, "Ptr", hIcon, "Ptr", pWorkingDir, "Ptr", pTitle, "Ptr", pDescription, "UInt", Flags)
} ;https://www.winehq.org/pipermail/wine-patches/2004-June/011280.html | https://www.codeproject.com/articles/2734/using-the-windows-runfile-dialog-the-documented-an
