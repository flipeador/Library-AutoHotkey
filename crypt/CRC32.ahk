CRC32(Binary, Length := 0)
{
    local

    if (Type(Binary) == "String")
    {
        Buffer := BufferAlloc(StrPut(Binary,"UTF-8"))
        Length := StrPut(Binary, Buffer, "UTF-8") - 1
        Binary := Buffer.Ptr
    }

    return DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0       ; DWORD dwInitial.
                                              ,  "Ptr", Binary  ; BYTE *pData.
                                              ,  "Int", Length  ; INT iLen.
                                              , "UInt")         ; DWORD ReturnValue.
} ;https://source.winehq.org/WineAPI/RtlComputeCrc32.html





; MsgBox(Format("0x{:X}",CRC32("The quick brown fox jumps over the lazy dog","UTF-8")))  ; 0x414FA339.
