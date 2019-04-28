class StreamReader extends Subprocess.Pipe
{
    Read(Characters)
    {
        return this.Stream.Read(Characters)
    }

    ReadAll()
    {
        local Str := "", Buffer, Bytes, Encoding := this.Encoding
        local n   := Encoding == "UTF-16" ? 2 : 1
        VarSetCapacity(Buffer, Subprocess.BufferSize)
        while Bytes := this.Stream.RawRead(&Buffer, Subprocess.BufferSize)
            Str .= StrGet(&Buffer, Bytes//n, Encoding)
        return Str
    }

    RawRead(Address, Bytes)
    {
        return this.Stream.RawRead(Address, Bytes)
    }
}
