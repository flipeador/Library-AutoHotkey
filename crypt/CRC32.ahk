; MsgBox(Format("0x{:X}",CRC32("The quick brown fox jumps over the lazy dog")))  ; 0x414FA339.
CRC32(Binary, Length := 0)
{
    local

    if Type(Binary) == "String"
        Binary := 0*(VarSetCapacity(Buffer,(Length:=StrPut(Binary,"UTF-8")-1)+1)+StrPut(Binary,&Buffer,"UTF-8"))+&Buffer

    return DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0       ; DWORD dwInitial.
                                              , "UPtr", Binary  ; BYTE *pData.
                                              ,  "Int", Length  ; INT iLen.
                                              , "UInt")         ; DWORD ReturnValue.
} ;https://source.winehq.org/WineAPI/RtlComputeCrc32.html
