/*
    Displays a dialog box that allows the user to choose an icon from the selection available embedded in a resource such as an executable or DLL file.
    Parameters:
        Owner:
            The handle of the owner window. This value can be zero.
        FileName:
            A string with the path of the default resource that contains the icons.
        IconIndex:
            Specifies the index of the initial selection. The default value is 1.
    Return value:
        If the function succeeds, the return value is an object with the keys 'FileName' and 'Icon'.
        If the function fails, the return value is zero.
*/
ChooseIcon(Owner := 0, FileName := "", IconIndex := 1)
{
    local Buffer := BufferAlloc(2*32767+2)
    StrPut(FileName, Buffer, "UTF-16")

    if !DllCall("Shell32.dll\PickIconDlg", "Ptr", Owner, "Ptr", Buffer, "UInt", Buffer.Size//2, "IntP", --IconIndex)
        return 0

    return { FileName: RegExReplace(StrGet(Buffer,"UTF-16"), "^%SystemRoot%", A_WinDir)
           , Icon    : IconIndex+1 }
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-pickicondlg





;MsgBox(ChooseIcon(, A_ComSpec).FileName)
