/*
    Retrieves information about the memory usage of the specified process.
    Parameters:
        Process:
            A handle to the process.
            The handle must have the PROCESS_QUERY_LIMITED_INFORMATION and PROCESS_VM_READ access rights.
    Return value:
        If the function succeeds, the return value is an associative object (Map) with the following keys:
            WorkingSetSize                The size, in bytes, of the current working set of the process.
            PeakWorkingSetSize            The peak size, in bytes, of the working set of the process.
            QuotaPagedPoolUsage           The current quota charged to the process for paged pool usage, in bytes.
            QuotaPeakPagedPoolUsage       The peak paged pool usage, in bytes.
            QuotaNonPagedPoolUsage        The current quota charged to the process for nonpaged pool usage, in bytes.
            QuotaPeakNonPagedPoolUsage    The peak nonpaged pool usage, in bytes.
            PagefileUsage                 The number of bytes of page file storage in use by the process.
            PeakPagefileUsage             The maximum number of bytes of page-file storage used by the process.
            PageFaultCount                The number of page faults.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessGetMemoryInfo(Process)
{
    local PROCESS_MEMORY_COUNTERS_EX := BufferAlloc(8+9*A_PtrSize)
    NumPut("UInt", PROCESS_MEMORY_COUNTERS_EX.Size, PROCESS_MEMORY_COUNTERS_EX)  ; DWORD  cb.
    if !DllCall("Psapi.dll\GetProcessMemoryInfo", "UPtr", IsObject(Process) ? Process.Handle : Process
                                                , "UPtr", PROCESS_MEMORY_COUNTERS_EX.Ptr
                                                , "UInt", PROCESS_MEMORY_COUNTERS_EX.Size)
        return 0

    local MemoryInfo := { PageFaultCount            : NumGet(PROCESS_MEMORY_COUNTERS_EX,             4, "UInt")    ; DWORD  PageFaultCount.
                        , PeakWorkingSetSize        : NumGet(PROCESS_MEMORY_COUNTERS_EX,             8, "UPtr")    ; SIZE_T PeakWorkingSetSize.
                        , WorkingSetSize            : NumGet(PROCESS_MEMORY_COUNTERS_EX,   8+A_PtrSize, "UPtr")    ; SIZE_T WorkingSetSize.
                        , QuotaPeakPagedPoolUsage   : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+2*A_PtrSize, "UPtr")    ; SIZE_T QuotaPeakPagedPoolUsage.
                        , QuotaPagedPoolUsage       : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+3*A_PtrSize, "UPtr")    ; SIZE_T QuotaPagedPoolUsage.
                        , QuotaPeakNonPagedPoolUsage: NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+4*A_PtrSize, "UPtr")    ; SIZE_T QuotaPeakNonPagedPoolUsage.
                        , QuotaNonPagedPoolUsage    : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+5*A_PtrSize, "UPtr")    ; SIZE_T QuotaNonPagedPoolUsage.
                        , PagefileUsage             : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+6*A_PtrSize, "UPtr")    ; SIZE_T PagefileUsage.
                        , PeakPagefileUsage         : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+7*A_PtrSize, "UPtr")    ; SIZE_T PeakPagefileUsage.
                        , PrivateUsage              : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+8*A_PtrSize, "UPtr") }  ; SIZE_T PrivateUsage.

    return MemoryInfo
}





/*
    Retrieves extended basic information of the specified process.
    Parameters:
        Process:
            A handle to the process.
            The handle must have the PROCESS_QUERY_LIMITED_INFORMATION and PROCESS_VM_READ access rights.
    Return value:
        If the function succeeds, the return value is an associative object (Map) with the following keys:
            ProcessId          The process identifier that uniquely identifies the process.
            ParentProcessId    The identifier of the process that created this process (its parent process).
            BasePriority       The base priority of the process, which is the starting priority for threads created within the associated process.
            PebBaseAddress     A pointer to a PEB structure containing process information.
            AffinityMask       The process affinity mask for the specified process.
            ExitStatus         The termination status of the specified process. STILL_ACTIVE = 259.
            Flags              Bit flags. Read: https://stackoverflow.com/questions/47300622/meaning-of-flags-in-process-extended-basic-information-struct.
                0x001  IsProtectedProcess    System protected process: other processes can't read/write its VM or inject a remote thread into it.
                0x002  IsWow64Process        WOW64 process, or 32-bit process running on a 64-bit Windows.
                0x004  IsProcessDeleting     Process was terminated, but there're open handles to it.
                0x008  IsCrossSessionCreate  Process was created across terminal sessions. Ex. CreateProcessAsUser.
                0x010  IsFrozen              Immersive process is suspended (applies only to UWP processes).
                0x020  IsBackground          Immersive process is in the Background task mode. UWP process may temporarily switch into performing a background task.
                0x040  IsStronglyNamed       UWP Strongly named process. The UWP package is digitally signed. Any modifications to files inside the package can be tracked. This usually means that if the package signature is broken the UWP app will not start.
                0x080  IsSecureProcess       Isolated User Mode process (new security mode in Windows 10), with more stringent restrictions on what can "tap" into this process.
                0x100  IsSubsystemProcess    Set when the type of the process subsystem is other than Win32 (like *NIX, such as Ubuntu.).
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ProcessGetBasicInfo(Process)
{
    local PROCESS_EXTENDED_BASIC_INFORMATION := BufferAlloc(A_PtrSize==4?32:64)  ; https://stackoverflow.com/questions/47300622/meaning-of-flags-in-process-extended-basic-information-struct.
    NumPut("UInt", PROCESS_EXTENDED_BASIC_INFORMATION.Size, PROCESS_EXTENDED_BASIC_INFORMATION)
    local NtStatus := DllCall("Ntdll.dll\NtQueryInformationProcess", "UPtr", IsObject(Process) ? Process.Handle : Process
                                                                   ,  "Int", 0  ; ProcessBasicInformation.
                                                                   , "UPtr", PROCESS_EXTENDED_BASIC_INFORMATION.Ptr
                                                                   , "UInt", PROCESS_EXTENDED_BASIC_INFORMATION.Size
                                                                   , "UPtr", 0
                                                                   , "UInt")

    if (NtStatus == 0)  ; STATUS_SUCCESS.
    {
        local ProcessInfo := { ExitStatus     : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION,   A_PtrSize, "UInt")    ; NTSTATUS  ExitStatus.
                             , PebBaseAddress : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 2*A_PtrSize, "UPtr")    ; PPEB      PebBaseAddress.
                             , AffinityMask   : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 3*A_PtrSize, "UPtr")    ; ULONG_PTR AffinityMask.
                             , BasePriority   : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 4*A_PtrSize, "UInt")    ; KPRIORITY BasePriority.
                             , ProcessId      : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 5*A_PtrSize, "UPtr")    ; HANDLE    UniqueProcessId.
                             , ParentProcessId: NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 6*A_PtrSize, "UPtr")    ; HANDLE    InheritedFromUniqueProcessId.
                             , Flags          : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 7*A_PtrSize, "UInt") }  ; ULONG     Flags.

    }

    return (A_LastError := NtStatus) ? 0 : ProcessInfo
}
