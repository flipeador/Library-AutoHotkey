CryptBinaryToString(Binary, Size := -1, Flags := 0x40000001)
{
    local Buffer, Bytes := 0
    DllCall("Crypt32.dll\CryptBinaryToStringW",   "Ptr", Type(Binary) == "String" ? &Binary          : Binary
                                              ,  "UInt", Size         == -1       ? 2*StrLen(Binary) : Size
                                              ,  "UInt", Flags
                                              ,  "UPtr", 0
                                              , "UIntP", Bytes)
   ,DllCall("Crypt32.dll\CryptBinaryToStringW",   "Ptr", Type(Binary) == "String" ? &Binary          : Binary
                                              ,  "UInt", Size         == -1       ? 2*StrLen(Binary) : Size
                                              ,  "UInt", Flags
                                              ,   "Ptr", Buffer := BufferAlloc(2*Bytes)
                                              , "UIntP", Bytes)
    return StrGet(Buffer, Bytes)
} ; https://docs.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptbinarytostringw





CryptStringToBinary(String, Flags := 0x00000001)
{
    local Buffer, Bytes := 0
    DllCall("Crypt32.dll\CryptStringToBinaryW", "Ptr", &String, "UInt", 0, "UInt", Flags, "Ptr", 0, "UIntP", Bytes, "Ptr", 0, "Ptr", 0)
   ,DllCall("Crypt32.dll\CryptStringToBinaryW",  "UPtr", &String
                                              ,  "UInt", 0
                                              ,  "UInt", Flags
                                              ,   "Ptr", Buffer := BufferAlloc(Bytes)
                                              , "UIntP", Buffer.Size
                                              ,  "UPtr", 0
                                              ,  "UPtr", 0)
    return Buffer
} ; https://docs.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinaryw





/*
B64 := CryptBinaryToString("string i'm testing")
MsgBox(B64 . "`ncwB0AHIAaQBuAGcAIABpACcAbQAgAHQAZQBzAHQAaQBuAGcA")
MsgBox(StrGet(CryptStringToBinary(B64)))
*/
