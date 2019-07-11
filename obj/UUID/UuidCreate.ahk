/*
    Creates a universally unique identifier (UUID).
    Return value:
        If the function succeeds, the return value is a Buffer object.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (HRESULT).
    Remarks:
        Use CreateUUID when you need an absolutely unique number that you will use as a persistent identifier in a distributed environment.
        To a very high degree of certainty, this function returns a unique value – no other invocation, on the same or any other system (networked or not), should return the same value.
*/
UuidCreate()
{
    local Buffer  := BufferAlloc(16)  ; sizeof(GUID) = 16.
    local HResult := DllCall("Ole32.dll\CoCreateGuid", "Ptr", Buffer, "UInt")

    if (HResult !== 0)
    {
        A_LastError := HResult
        return 0
    }

    return Buffer
} ; https://docs.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cocreateguid





GUIDCreate()
{
    return UuidCreate()
}





CLSIDCreate()
{
    return UuidCreate()
}





/*
    The UUID structure defines Universally Unique Identifiers (UUIDs).
    UUIDs provide unique designations of objects such as interfaces, manager entry-point vectors, and client objects.

    typedef struct _GUID {
        unsigned long  Data1;
        unsigned short Data2;
        unsigned short Data3;
        unsigned char  Data4[ 8 ];
    } GUID;

    https://docs.microsoft.com/en-us/previous-versions/aa379358(v=vs.80)
*/
