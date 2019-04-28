class StreamWriter extends Subprocess.Pipe
{
    Write(Text)
    {
        return this.Stream.Write(Text)
    }

    RawWrite(Address, Bytes)
    {
        return this.Stream.RawWrite(Address, Bytes)
    }

    WriteFromFile(File, Bytes := -1, Encoding := "")
    {
        File := IsObject(File) ? File : FileOpen(File, "r-wd", Encoding)
        if Type(File) !== "File"
            return 0
        Bytes := Bytes == -1 ? File.Length : Bytes
        local Buffer, BytesRead, BytesWritten := 0
        VarSetCapacity(Buffer, Subprocess.BufferSize)
        while BytesRead := File.RawRead(&Buffer, Subprocess.BufferSize)
            BytesWritten += this.Stream.RawWrite(&Buffer, BytesRead)
        return BytesWritten
    }
}
