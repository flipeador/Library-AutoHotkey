Base64ToComByteArray(Base64)
{
    ; Calculates the length of the buffer needed.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptstringtobinaryw.
    local RequiredSize := 0
    if !DllCall("Crypt32.dll\CryptStringToBinaryW",  "UPtr", &Base64       ; LPCWSTR pszString.
                                                  ,  "UInt", 0             ; DWORD   cchString.
                                                  ,  "UInt", 0x1           ; DWORD   IdwFlags. CRYPT_STRING_BASE64 (Base64 without headers).
                                                  ,  "UPtr", 0             ; BYTE    *pbBinary.
                                                  , "UIntP", RequiredSize  ; DWORD   *pcbBinary.
                                                  ,  "UPtr", 0             ; DWORD   *pdwSkip.
                                                  ,  "UPtr", 0)            ; DWORD   *pdwFlags.
        return 0

    ; Creates an array of bytes for use with COM (unsigned one-byte characters).
    local ComByteArray := ComObjArray(0x11, RequiredSize)  ; VT_UI1 (8-bit unsigned int). 

    ; Converts the Base64 string into an array of bytes.
    if !DllCall("Crypt32.dll\CryptStringToBinaryW",  "UPtr", &Base64
                                                  ,  "UInt", 0 
                                                  ,  "UInt", 0x1    
                                                  ,  "UPtr", NumGet(ComObjValue(ComByteArray)+8+A_PtrSize)   
                                                  , "UIntP", RequiredSize  
                                                  ,  "UPtr", 0     
                                                  ,  "UPtr", 0)   
        return 0

    return ComByteArray
} ; https://www.autohotkey.com/boards/viewtopic.php?t=36124