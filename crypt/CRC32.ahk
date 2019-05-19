CRC32(Binary, Length)
{
    local

    if (Type(Binary) == "String")
    {
        Buffer := BufferAlloc(StrPut(Binary,Length))
       ,Length := StrPut(Binary, Buffer, StrLen(Binary), Length)
       ,Binary := Buffer.Ptr
    }

    return DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0       ; DWORD dwInitial.
                                              ,  "Ptr", Binary  ; BYTE *pData.
                                              ,  "Int", Length  ; INT iLen.
                                              , "UInt")         ; DWORD ReturnValue.
} ;https://source.winehq.org/WineAPI/RtlComputeCrc32.html





; MsgBox(Format("0x{:X}",CRC32("The quick brown fox jumps over the lazy dog","UTF-8")))  ; 0x414FA339.
