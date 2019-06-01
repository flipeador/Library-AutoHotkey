/*
    Retrieves the name of a non-existent temporary file. This function does not create any files.
    Parameters:
        DirName:
            The directory where the file will be located. If the directory does not exist, A_Temp is used.
        Prefix:
            A prefix string. This string will be added to the beginning of the filename.
            Followed by this string, a date in the YYYYMMDDHH24MISS format will be added.
        Ext:
            A string with the name of the file extension. An empty string indicates no extension.
    Return value:
        Returns a string with the file path.
*/
FileGetTemp(DirName := "", Prefix := "", Ext := "TMP")
{
    local

    DirName  := RTrim(DirExist(DirName) ? DirName : A_Temp, "\")
    Ext      := RegExReplace(Ext, "[/\\:\*\?`"<>\|\.]")
    Unique   := DateAdd(A_Now, -1, "Days")

    loop
        FileName := Format("{}\{}{}{}", DirName, Prefix, Unique:=DateAdd(Unique,1,"D"), Ext==""?"":"." . Ext)
    until !FileExist(FileName)

    Return FileName
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa364991(v=vs.85).aspx





/*
    Similar to the FileGetTemp function, but this function returns a file object (the file is created).
    Parameters:
        DirName / Prefix / Ext:
            See the FileGetTemp function.
        Flags / Encoding:
            The parameters of the FileOpen function.
    Return value:
        Returns a file object with all access: 'rw-rwd'.
    ErrorLevel:
        It is set to the name of the file that has been created.
*/
FileObjGetTemp(DirName := "", Prefix := "", Ext := "TMP", Flags := "rw-rwd", Encoding := "CP0")
{
    local

    while !(FileObj:=FileOpen(ErrorLevel:=FileGetTemp(DirName,Prefix,Ext),Flags,Encoding))
        continue

    return FileObj
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa364991(v=vs.85).aspx





/*
MsgBox(Format("FileName:`n{2}`n`nText:`n{1}",(((F:=FileObjGetTemp(,,"txt")).Write("Hello World!")&&F).Seek(0)&&F).Read(),ErrorLevel))
FileDelete(F:=ErrorLevel)
*/
