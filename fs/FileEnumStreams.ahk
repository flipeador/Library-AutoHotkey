/*
    Enumera los flujos de datos alternativos  (alternate data streams) en el archivo especificado.
    Parámetros:
        File:
            El nombre del archivo a analizar.
    Nota:
        Los nombres de Streams tienen el formato ":stream_name:$DATA". Al recuperarlos se eliminan los ":" y "$DATA".
        Para acceder a un stream se utiliza el formato "C:\File.ext:Stream_Name". Se pueden eliminar con FileDelete.
    Referencias:
        https://autohotkey.com/boards/viewtopic.php?f=5&t=50460&start=20#p225780
*/
FileEnumStreams(File)
{
    Local                Streams := []
        , WIN32_FIND_STREAM_DATA := ""

    VarSetCapacity(WIN32_FIND_STREAM_DATA, 8 + (260 + 36) * 2)
    Local Handle := DllCall("Kernel32.dll\FindFirstStreamW", "UPtr", &File, "UInt", 0, "UPtr", &WIN32_FIND_STREAM_DATA, "UInt", 0, "Ptr")
    If (!Handle)
        Return FALSE
    ObjPush(Streams, {Size: NumGet(&WIN32_FIND_STREAM_DATA, "Int64"), Name: SubStr(StrGet(&WIN32_FIND_STREAM_DATA + 8, "UTF-16"), 2, -6)})

    While (DllCall("Kernel32.dll\FindNextStreamW", "Ptr", Handle, "UPtr", &WIN32_FIND_STREAM_DATA, "Ptr"))
        ObjPush(Streams, {Size: NumGet(&WIN32_FIND_STREAM_DATA, "Int64"), Name: SubStr(StrGet(&WIN32_FIND_STREAM_DATA + 8, "UTF-16"), 2, -6)})

    Return Streams
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa365741(v=vs.85).aspx
