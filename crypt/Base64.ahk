Base64Encode(Binary, Length, Flags := 0x40000001)
{
    local

    if (Type(Binary) == "String")
    {
        Buffer := BufferAlloc(StrPut(Binary,Length))
       ,Length := StrPut(Binary, Buffer, StrLen(Binary), Length)
       ,Binary := Buffer.Ptr
    }

    ; Calculates the number of characters that must be allocated to hold the returned string.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptbinarytostringw.
    RequiredSize := 0
    if !DllCall("Crypt32.dll\CryptBinaryToStringW",  "UPtr", Binary         ; BYTE    *pbBinary.
                                                  ,  "UInt", Length         ; DWORD   cbBinary.
                                                  ,  "UInt", Flags          ; DWORD   dwFlags.
                                                  ,  "UPtr", 0              ; BYTE    pszString.
                                                  , "UIntP", RequiredSize)  ; LPWSTR  *pcchString.
        return ""

    ; Converts the array of bytes into a formatted string.
    Base64 := BufferAlloc(2*RequiredSize)  ; 'RequiredSize' includes the terminating NULL character.
    if !DllCall("Crypt32.dll\CryptBinaryToStringW",  "UPtr", Binary         ; BYTE    *pbBinary.
                                                  ,  "UInt", Length         ; DWORD   cbBinary.
                                                  ,  "UInt", Flags          ; DWORD   dwFlags.
                                                  ,  "UPtr", Base64.Ptr     ; BYTE    pszString.
                                                  , "UIntP", RequiredSize)  ; LPWSTR  *pcchString.
        return ""

    return StrGet(Base64, "UTF-16")
}





Base64Decode(Base64, Length := 0, Buffer := 0, Flags := 0x00000001, RequiredSize := 0)
{
    local

    pBase64 := Type(Base64) == "String" ? &Base64 : Base64

    ; Calculates the length of the buffer needed.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptstringtobinaryw.
    if !RequiredSize
        if !DllCall("Crypt32.dll\CryptStringToBinaryW",   "Ptr", pBase64       ; LPCWSTR pszString.
                                                      ,  "UInt", Length        ; DWORD   cchString.
                                                      ,  "UInt", Flags         ; DWORD   IdwFlags.
                                                      ,   "Ptr", 0             ; BYTE    *pbBinary.
                                                      , "UIntP", RequiredSize  ; DWORD   *pcbBinary.
                                                      ,   "Ptr", 0             ; DWORD   *pdwSkip.
                                                      ,   "Ptr", 0)            ; DWORD   *pdwFlags.
            return FALSE

    if !Buffer
        return RequiredSize

    return DllCall("Crypt32.dll\CryptStringToBinaryW",   "Ptr", pBase64       ; LPCWSTR pszString.
                                                     ,  "UInt", Length        ; DWORD   cchString.
                                                     ,  "UInt", Flags         ; DWORD   IdwFlags.
                                                     ,   "Ptr", Buffer        ; BYTE    *pbBinary.
                                                     , "UIntP", RequiredSize  ; DWORD   *pcbBinary.
                                                     ,   "Ptr", 0             ; DWORD   *pdwSkip.
                                                     ,   "Ptr", 0)            ; DWORD   *pdwFlags.
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa380285(v=vs.85).aspx





Base64DecodeStr(Base64, Encoding)
{
    local

    RequiredSize := Base64Decode(&Base64)
    Buffer       := BufferAlloc(RequiredSize+4)

    if !Base64Decode(&Base64,, Buffer,, RequiredSize)
        return ""

    NumPut("UInt", 0, Buffer, RequiredSize)

    return StrGet(Buffer, Encoding)
}
