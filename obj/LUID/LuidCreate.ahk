/*
    Creates a locally unique identifier (LUID).
    Return value:
        If the function succeeds, the return value is a Buffer object.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
LUIDCreate()
{
    local Buffer   := BufferAlloc(8)  ; sizeof(LUID) = 8.
    local NtStatus := DllCall("Ntdll.dll\NtAllocateLocallyUniqueId", "Ptr", Buffer, "UInt")

    if (NtStatus !== 0)
    {
        A_LastError := NtStatus
        return 0
    }

    return Buffer
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntddk/nf-ntddk-zwallocatelocallyuniqueid





/*
    The locally unique identifier (LUID) is a 64-bit value guaranteed to be unique only on the system on which it was generated.
    The uniqueness of an LUID is guaranteed only until the system is restarted.

    An LUID is not for direct manipulation. Drivers must use support routines and structures to manipulate LUID values.

    typedef struct _LUID {
      DWORD LowPart;   // Low order bits.
      LONG  HighPart;  // High order bits.
    } LUID, *PLUID;

    https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/igpupvdev/ns-igpupvdev-_luid
*/
