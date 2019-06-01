/*
    Enumerates the streams with a ::$DATA stream type in the specified file or directory.
    Parameters:
        FileName:
            The fully qualified file name.
    Return value:
        If this function succeeds, the return value is an array of objects with the keys: 'Size' and 'Name'.
        If the function fails, the return value is zero.
    Related:
        https://www.autohotkey.com/boards/viewtopic.php?f=5&t=50460&start=20#p225780
*/
FileEnumStreams(FileName)
{
    local

    Streams                := [ ]
    WIN32_FIND_STREAM_DATA := BufferAlloc(600)  ; 8+2*(260+36) = LARGE_INTEGER+WCHAR[MAX_PATH+36].
    A_LastError            := 0

    if Handle := DllCall("Kernel32.dll\FindFirstStreamW", "Ptr", &FileName, "UInt", 0, "Ptr", WIN32_FIND_STREAM_DATA, "UInt", 0, "Ptr")
    {
        loop
            Streams.Push( { Size: NumGet(WIN32_FIND_STREAM_DATA, "Int64")
                          , Name: StrGet(WIN32_FIND_STREAM_DATA.Ptr+8, 260+36, "UTF-16")
                          } )
        until !DllCall("Kernel32.dll\FindNextStreamW", "Ptr", Handle, "Ptr", WIN32_FIND_STREAM_DATA, "Ptr")
    }

    return A_LastError == 0x00000026 ? Streams : 0  ; ERROR_HANDLE_EOF (38).
} ; https://docs.microsoft.com/en-us/windows/desktop/api/fileapi/ns-fileapi-_win32_find_stream_data





/*
for i, Stream in FileEnumStreams(FileSelect())
    MsgBox(Format("Stream`s#{3}:`n{2}`s({1}`sBytes).",Stream.Size,Stream.Name,A_Index))
*/
