/*
    Displays a ShellAbout dialog box.
    Parameters:
        Owner:
            The handle of the owner window. This value can be zero.
        Title:
            The text to be displayed in the title bar and on the first line of the dialog after the text "Microsoft".
            If the text contains a separator (#) that divides it into two parts, the first part in the title bar and the second part on the first line after the text "Microsoft".
            This parameter can be a string or a pointer to a null-terminated string.
        Text:
            The text to be displayed in the dialog box after the version and copyright information. This parameter can be zero.
        hIcon:
            The handle of an icon that the function displays in the dialog box.
            This parameter can be a string or a pointer to a null-terminated string.
            This parameter can be zero, in which case the function displays the Windows icon.
    Return value:
        TRUE if successful; otherwise, FALSE.
*/
ShellAbout(Owner := 0, Title := "", Text := 0, hIcon := 0)
{
    local

    Owner  := DllCall("User32.dll\IsWindow","Ptr",Owner) ? Owner : A_ScriptHwnd
    pTitle := Type(Title) == "Integer" ? Title : &(Title:=String(Title))
    pText  := Type(Text)  == "Integer" ? Text  : &(Text :=String(Text) )

    return DllCall("Shell32.dll\ShellAbout", "Ptr", Owner, "Ptr", pTitle?pTitle:&"", "Ptr", pText, "Ptr", hIcon)
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shellabouta





;ShellAbout(0, "")
