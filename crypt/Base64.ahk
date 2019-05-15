Base64Encode(Binary, Length := "", Encoding := "UTF-16", Flags := 0x40000001)
{
    local

    if Encoding !== "UTF-16"
        Binary := 0*(VarSetCapacity(Buffer,(Length:=StrPut(Binary,Encoding)-1)+1)+StrPut(Binary,&Buffer,Encoding))+&Buffer

    pBinary := Type(Binary) == "String" ? &Binary : Binary
    Length  := Type(Binary) == "String" ? Length == "" ? 2*StrLen(Binary) : 2*Min(StrLen(Binary),Length) : Length

    if Type(pBinary) !== "Integer" || !pBinary
        throw Exception("Base64Encode function, invalid parameter #1.", -1, "Invalid address.")
    if Type(Length) !== "Integer" || Length < 0
        throw Exception("Base64Encode function, invalid parameter #2.", -1)

    ; Calculates the number of characters that must be allocated to hold the returned string.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptbinarytostringw.
    RequiredSize := 0
    if !DllCall("Crypt32.dll\CryptBinaryToStringW",  "UPtr", pBinary        ; BYTE    *pbBinary.
                                                  ,  "UInt", Length         ; DWORD   cbBinary.
                                                  ,  "UInt", Flags          ; DWORD   dwFlags.
                                                  ,  "UPtr", 0              ; BYTE    pszString.
                                                  , "UIntP", RequiredSize)  ; LPWSTR  *pcchString.
        return ""

    ; Converts the array of bytes into a formatted string.
    VarSetCapacity(Base64, 2*RequiredSize)  ; 'RequiredSize' includes the terminating NULL character.
    if !DllCall("Crypt32.dll\CryptBinaryToStringW",  "UPtr", pBinary        ; BYTE    *pbBinary.
                                                  ,  "UInt", Length         ; DWORD   cbBinary.
                                                  ,  "UInt", Flags          ; DWORD   dwFlags.
                                                  ,   "Str", Base64         ; BYTE    pszString.
                                                  , "UIntP", RequiredSize)  ; LPWSTR  *pcchString.
        return ""

    return Base64
}





Base64Decode(Base64, Length := 0, pBuffer := 0, Flags := 0x00000001)
{
    local

    pBase64 := Type(Base64) == "String" ? &Base64 : Base64

    if Type(pBase64) !== "Integer" || !pBase64
        throw Exception("Base64Decode function, invalid parameter #1.", -1, "Invalid address.")
    if Type(Length) !== "Integer" || Length < 0
        throw Exception("Base64Decode function, invalid parameter #2.", -1)

    ; Calculates the length of the buffer needed.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptstringtobinaryw.
    RequiredSize := 0
    if !DllCall("Crypt32.dll\CryptStringToBinaryW",  "UPtr", pBase64       ; LPCWSTR pszString.
                                                  ,  "UInt", Length        ; DWORD   cchString.
                                                  ,  "UInt", Flags         ; DWORD   IdwFlags.
                                                  ,  "UPtr", 0             ; BYTE    *pbBinary.
                                                  , "UIntP", RequiredSize  ; DWORD   *pcbBinary.
                                                  ,  "UPtr", 0             ; DWORD   *pdwSkip.
                                                  ,  "UPtr", 0)            ; DWORD   *pdwFlags.
        return FALSE

    if !pBuffer
        return RequiredSize

    return DllCall("Crypt32.dll\CryptStringToBinaryW",  "UPtr", pBase64       ; LPCWSTR pszString.
                                                     ,  "UInt", Length        ; DWORD   cchString.
                                                     ,  "UInt", Flags         ; DWORD   IdwFlags.
                                                     ,  "UPtr", pBuffer       ; BYTE    *pbBinary.
                                                     , "UIntP", RequiredSize  ; DWORD   *pcbBinary.
                                                     ,  "UPtr", 0             ; DWORD   *pdwSkip.
                                                     ,  "UPtr", 0)            ; DWORD   *pdwFlags.
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa380285(v=vs.85).aspx





Base64DecodeStr(Base64, Encoding := "UTF-16")
{
    local

    VarSetCapacity(Buffer, Base64Decode(Base64)+2, 0)
    return Base64Decode(Base64,,&Buffer) ? StrGet(&Buffer,Encoding) : ""
}
