/*
    Retrieves the final path for the specified file handle or file object.
    Parameters:
        File:
            A handle to a file or directory, or a file object.
        Flags:
            The type of result to return. This parameter can be one of the following values.
            0x0  FILE_NAME_NORMALIZED     Return the normalized drive name. This is the default.
            0x8  FILE_NAME_OPENED         Return the opened file name (not normalized).
            -----------------------------
            This parameter can also include one of the following values.
            0x0  VOLUME_NAME_DOS          Return the path with the drive letter. This is the default. 
            0x1  VOLUME_NAME_GUID         Return the path with a volume GUID path instead of the drive name.
            0x2  VOLUME_NAME_NT           Return the path with the volume device path.
            0x4  VOLUME_NAME_NONE         Return the path with no drive information.
            -----------------------------
            The default value is -1 (or <0), returns the path without any prefix.
    Return value:
        If the function succeeds, the return value is a string with the file path.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
PathFromHandle(File, Flags := -1)
{
    local

    ; Allocates a buffer to hold the path.
    Buffer := BufferAlloc(2*32767)

    ; Returns the length of the string received, in characters, not including the terminating null character.
    Length := DllCall("Kernel32.dll\GetFinalPathNameByHandleW", "UPtr", IsObject(File) ? File.Handle : File
                                                              , "UPtr", Buffer.Ptr
                                                              , "UInt", Buffer.Size
                                                              , "UInt", Flags > -1 ? Flags : 0
                                                              , "UInt")

    return Flags > -1 ? StrGet(Buffer,Length,"UTF-16") : LTrim(StrGet(Buffer,Length,"UTF-16"),"\\?\")
} ; https://docs.microsoft.com/en-us/windows/desktop/api/fileapi/nf-fileapi-getfinalpathnamebyhandlew





;MsgBox(PathFromHandle(FileOpen(FileSelect(),"r")))
