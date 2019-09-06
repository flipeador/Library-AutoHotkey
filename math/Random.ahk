#DllLoad Bcrypt.Dll





/*
    Generates a secure pseudo-random floating point number in the specified range.
    Parameters:
        Min:
            The smallest number that can be generated, which can be negative or positive.
        Max:
            The largest number that can be generated, which can be negative or positive.
    Return value:
        The return value is a pseudo-randomly generated floating point number.
    For example, to generate a random number between 10 and 20:
        Rand10_20 := Round(RandomFloat(10, 20))
*/
RandomFloat(Min, Max)
{
    local Buffer := RandomBuffer(BufferAlloc(8))
    NumPut("UChar", 15&NumGet(Buffer,6,"UChar"), "UChar", 0, Buffer, 6)
    return ((NumGet(Buffer,"UInt64")/0xFFFFFFFFFFFFF) * (Max - Min)) + Min
} ; http://www.autohotkey.com/board/topic/70530-random-number-crypt-secure-rand-numberbuffer/





/*
    Returns a boolean value based on a given probability.
    Parameters:
        Probability:
            Specifies the percentage of the probability, such as 10.0 (10.0%) or 25.5 (25.5%).
            As an example, If «probability» is 60% (60.0), 100 calls to this function should return ~60 TRUE values.
    Return value:
        The return value is always zero or one, depending on the specified probability.
*/
RandomBool(Probability)
{
    return Random(0.0,100.0) <= Probability
} ; https://alvinalexander.com/java/java-method-returns-random-boolean-based-on-probability





/*
    Generates random data.
    Parameters:
        Buffer:
            A buffer that receives the random data.
        Size:
            The size of the buffer, in bytes.
            This parameter is optional if «Buffer» is a Buffer object.
    Return value:
        If the function succeeds, the return value is «Buffer».
        If the function fails, the return value is zero.
*/
RandomBuffer(Buffer, Size := -1)
{
    local

    DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "UPtrP", hAlgorithm := 0  ; BCRYPT_ALG_HANDLE *phAlgorithm.
                                                    ,   "Str", "RNG"            ; LPCWSTR           pszAlgId. BCRYPT_RNG_ALGORITHM.
                                                    ,  "UPtr", 0                ; LPCWSTR           pszImplementation.
                                                    ,  "UInt", 0)               ; ULONG             dwFlags.

    DllCall("Bcrypt.dll\BCryptGenRandom", "UPtr", hAlgorithm                     ; BCRYPT_ALG_HANDLE hAlgorithm
                                        ,  "Ptr", Buffer                         ; PUCHAR            pbBuffer.
                                        , "UInt", Size < 0 ? Buffer.Size : Size  ; ULONG             cbBuffer.
                                        , "UInt", 0)                             ; ULONG             dwFlags.

    return DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr", hAlgorithm, "UInt", 0, "UInt")  ; NTSTATUS.
         ? 0       ; Error.
         : Buffer  ; Ok.
} ; https://docs.microsoft.com/en-us/windows/win32/seccng/cng-cryptographic-primitive-functions
