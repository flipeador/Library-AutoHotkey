/*
    Retrieves a list with information for each process object running in the system.
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessName        The name of the executable file associated with the process (its process's image name).
            ProcessId          The process identifier that uniquely identifies the process.
            ParentProcessId    The identifier of the process that created this process (its parent process).
            BasePriority       The base priority of the process, which is the starting priority for threads created within the associated process.
            ThreadCount        The number of execution threads started by the process.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessGetList()
{
    local hSnapshot := DLLCall("Kernel32.dll\CreateToolhelp32Snapshot", "UInt", 0x00000002  ; DWORD dwFlags. TH32CS_SNAPPROCESS.
                                                                      , "UInt", 0           ; DWORD th32ProcessID.
                                                                      , "Ptr")              ; HANDLE.
    if (hSnapshot == -1)  ; INVALID_HANDLE_VALUE == ((HANDLE)(LONG_PTR)-1).
        return 0

    local ProcessList    := [ ]                                ; An array of associative objects containing information from each process.
    local PROCESSENTRY32 := BufferAlloc(A_PtrSize==4?556:568)  ; https://docs.microsoft.com/en-us/windows/win32/api/tlhelp32/ns-tlhelp32-tagprocessentry32.
    NumPut("UInt", PROCESSENTRY32.Size, PROCESSENTRY32)        ; DWORD dwSize (sizeof PROCESSENTRY32 structure).

    if DllCall("Kernel32.dll\Process32FirstW", "Ptr", hSnapshot, "Ptr", PROCESSENTRY32)
    {
        local Ptr := { cntThreads         : PROCESSENTRY32.Ptr + (A_PtrSize==4?20:28)
                     , th32ParentProcessID: PROCESSENTRY32.Ptr + (A_PtrSize==4?24:32)
                     , pcPriClassBase     : PROCESSENTRY32.Ptr + (A_PtrSize==4?28:36)
                     , szExeFile          : PROCESSENTRY32.Ptr + (A_PtrSize==4?36:44) }
        loop
        {
            ProcessList.Push( { ProcessId      : NumGet(PROCESSENTRY32         ,   "UInt")      ; DWORD th32ProcessID.
                              , ThreadCount    : NumGet(Ptr.cntThreads         ,   "UInt")      ; DWORD cntThreads.
                              , ParentProcessId: NumGet(Ptr.th32ParentProcessID,   "UInt")      ; DWORD th32ParentProcessID.
                              , BasePriority   : NumGet(Ptr.pcPriClassBase     ,   "UInt")      ; LONG  pcPriClassBase.
                              , ProcessName    : StrGet(Ptr.szExeFile          , "UTF-16") } )  ; CHAR  szExeFile[MAX_PATH].
        }
        until !DllCall("Kernel32.dll\Process32NextW", "Ptr", hSnapshot, "Ptr", PROCESSENTRY32)
    }

    DllCall("Kernel32.dll\CloseHandle", "Ptr", hSnapshot)
    return ProcessList.Length() ? ProcessList : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-createtoolhelp32snapshot





/*
    Retrieves a list with information for each process object running in the system.
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessName               The name of the executable file associated with the process (its process's image name).
            ProcessId                 The process identifier that uniquely identifies the process.
            ParentProcessId           The identifier of the process that created this process (its parent process).
            BasePriority              The base priority of the process, which is the starting priority for threads created within the associated process.
            ThreadCount               The number of execution threads started by the process.
            HandleCount               The total number of handles being used by the process in question.
            SessionId                 The session identifier for the session associated with the process.
            WorkingSetSize            The size, in bytes, of the current working set of the process.
            PeakWorkingSetSize        The peak size, in bytes, of the working set of the process.
            VirtualSize               The current size, in bytes, of virtual memory used by the process.
            PeakVirtualSize           The peak size, in bytes, of the virtual memory used by the process.
            PagefileUsage             The number of bytes of page file storage in use by the process.
            PeakPagefileUsage         The maximum number of bytes of page-file storage used by the process.
            PrivatePageCount          The number of memory pages allocated for the use of this process.
            QuotaPagedPoolUsage       The current quota charged to the process for paged pool usage, in bytes.
            QuotaNonPagedPoolUsage    The current quota charged to the process for nonpaged pool usage, in bytes.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ProcessGetList2()
{
    local Buffer   := BufferAlloc(1000000)  ; 1MB - I think it's enough space, we avoid two calls to NtQuerySystemInformation.
    local NtStatus := DllCall("Ntdll.dll\NtQuerySystemInformation", "Int", 5, "Ptr", Buffer, "UInt", Buffer.Size, "UIntP", 0, "UInt")

    if (NtStatus == 0)  ; STATUS_SUCCESS = 0.
    {
        local ProcessList     := []          ; An array of associative objects containing information from each process.
        local Ptr             := Buffer.Ptr  ; Pointer to structure SYSTEM_PROCESS_INFORMATION / SYSTEM_PROCESSES_INFORMATION (same data).
        local NextEntryOffset := 0           ; The start of the next item in the array is the address of the previous item plus the value in the NextEntryOffset member.

        loop
        {
            ProcessList.Push( { ThreadCount           : NumGet(Ptr, 4, "UInt")                                       ; ULONG     NumberOfThreads.
                              , ProcessName           : StrGet(NumGet(Ptr,56+A_PtrSize),NumGet(Ptr+56,"UShort")//2)  ; ImageName.Buffer (UNICODE_STRING structure).
                              , BasePriority          : NumGet(Ptr, 56+2*A_PtrSize, "UInt")                          ; KPRIORITY BasePriority.
                              , ProcessId             : NumGet(Ptr, 56+3*A_PtrSize, "UPtr")                          ; HANDLE    UniqueProcessId.
                              , ParentProcessId       : NumGet(Ptr, 56+4*A_PtrSize, "UPtr")                          ; PVOID     Reserved2/InheritedFromUniqueProcessId.
                              , HandleCount           : NumGet(Ptr, 56+5*A_PtrSize, "UInt")                          ; ULONG     HandleCount.
                              , SessionId             : NumGet(Ptr, 60+5*A_PtrSize, "UInt")                          ; ULONG     SessionId.
                              , PeakVirtualSize       : NumGet(Ptr, 64+6*A_PtrSize, "UPtr")                          ; SIZE_T    PeakVirtualSize.
                              , VirtualSize           : NumGet(Ptr, 64+7*A_PtrSize, "UPtr")                          ; SIZE_T    VirtualSize.
                              , PeakWorkingSetSize    : NumGet(Ptr, 64+9*A_PtrSize, "UPtr")                          ; SIZE_T    PeakWorkingSetSize.
                              , WorkingSetSize        : NumGet(Ptr, 64+10*A_PtrSize, "UPtr")                         ; SIZE_T    WorkingSetSize.
                              , QuotaPagedPoolUsage   : NumGet(Ptr, 64+12*A_PtrSize, "UPtr")                         ; SIZE_T    QuotaPagedPoolUsage.
                              , QuotaNonPagedPoolUsage: NumGet(Ptr, 64+14*A_PtrSize, "UPtr")                         ; SIZE_T    QuotaNonPagedPoolUsage.
                              , PagefileUsage         : NumGet(Ptr, 64+15*A_PtrSize, "UPtr")                         ; SIZE_T    PagefileUsage.
                              , PeakPagefileUsage     : NumGet(Ptr, 64+16*A_PtrSize, "UPtr")                         ; SIZE_T    PeakPagefileUsage.
                              , PrivatePageCount      : NumGet(Ptr, 64+17*A_PtrSize, "UPtr") } )                     ; SIZE_T    PrivatePageCount.
        }
        until (  (Ptr += (NextEntryOffset:=NumGet(Ptr,"UInt")))  ==  (Ptr-NextEntryOffset)  )                        ; ULONG     NextEntryOffset.
    }

    return (A_LastError := NtStatus) ? 0 : ProcessList
} ; https://docs.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntquerysysteminformation





/*
    Retrieves the process identifier for each process object running in the system.
    Parameters:
        Max:
            The maximum number of processes to retrieve. By default it retrieves the first 500.
    Return value:
        If the function succeeds, the return value is an array of process identifiers (may be empty).
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessEnum(Max := 500)
{
    local Buffer := BufferAlloc(4*Max), Size := 0, Processes := [ ]
    if !DllCall("Psapi.dll\EnumProcesses", "Ptr", Buffer, "UInt", Buffer.Size, "UIntP", Size)
        return 0
    loop (Size // 4)
        Processes.Push( NumGet(Buffer,4*(A_Index-1),"UInt") )
    return Processes
} ; https://docs.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-enumprocesses





/*
    Retrieves information about the active processes on the specified Remote Desktop Session Host (RD Session Host) server or Remote Desktop Virtualization Host (RD Virtualization Host) server.
    Parameters:
        Server:
            A handle to an Remote Desktop Session Host server.
            To indicate the server on which your application is running, specify 0 (WTS_CURRENT_SERVER_HANDLE).
        SessionId:
            The session for which to enumerate processes.
            To enumerate processes for all sessions on the server, specify -2 (WTS_ANY_SESSION).
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessName           The name of the executable file associated with the process (its process's image name).
            ProcessId             The process identifier that uniquely identifies the process on the RD Session Host server.
            ThreadCount           The number of execution threads started by the process.
            HandleCount           The total number of handles being used by the process in question.
            SessionId             The Remote Desktop Services session identifier for the session associated with the process.
            UserSid               The user security identifier (SID) in the primary access token of the process (Buffer object).
            WorkingSetSize        The size, in bytes, of the current working set of the process.
            PeakWorkingSetSize    The peak size, in bytes, of the working set of the process.
            PagefileUsage         The number of bytes of page file storage in use by the process.
            PeakPagefileUsage     The maximum number of bytes of page-file storage used by the process.
            UserTime              The amount of time, in milliseconds, the process has been running in user mode.
            KernelTime            The amount of time, in milliseconds, the process has been running in kernel mode.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
    Remarks:
        The caller must be a member of the Administrators group to enumerate processes that are running under another user session.
*/
WTSProcessEnum(Server := 0, SessionId := -2)
{
    local 

    if !DllCall("Wtsapi32.dll\WTSEnumerateProcessesExW",  "UPtr", IsObject(Server) ? Server.Handle : Server  ; HANDLE hServer,
                                                       , "UIntP", Level := 1                                 ; DWORD  *pLevel. WTS_PROCESS_INFO_EX.
                                                       ,  "UInt", SessionId                                  ; DWORD  SessionId.
                                                       , "UPtrP", pWTS_PROCESS_INFO_EX := 0                  ; LPWSTR *ppProcessInfo.
                                                       , "UIntP", Count := 0)                                ; DWORD  *pCount.
        return 0

    ProcessList := [ ]                   ; An array of associative objects containing information from each process.
    Ptr         := pWTS_PROCESS_INFO_EX  ; An array of WTS_PROCESS_INFO_EX structures.
    loop (Count)  ; The number of WTS_PROCESS_INFO_EX structures returned.
    {
        if (pUserSid := NumGet(Ptr,8+A_PtrSize))
            DllCall("Advapi32.dll\CopySid", "UInt", SidSize := DllCall("Advapi32.dll\GetLengthSid", "Ptr", pUserSid)
                                          ,  "Ptr", UserSid := BufferAlloc(SidSize)
                                          , "UPtr", pUserSid)
        ProcessList.Push( { SessionId         : NumGet(Ptr, 0, "UInt")                     ; DWORD         SessionId.
                          , ProcessId         : NumGet(Ptr, 4, "UInt")                     ; DWORD         ProcessId.
                          , ProcessName       : StrGet(NumGet(Ptr,8))                      ; LPSTR         pProcessName.
                          , UserSid           : pUserSid ? UserSid : 0                     ; PSID          pUserSid.
                          , ThreadCount       : NumGet(Ptr, 8+2*A_PtrSize, "UInt")         ; DWORD         NumberOfThreads.
                          , HandleCount       : NumGet(Ptr, 12+2*A_PtrSize, "UInt")        ; DWORD         HandleCount.
                          , PagefileUsage     : NumGet(Ptr, 16+2*A_PtrSize, "UInt")        ; DWORD         PagefileUsage.
                          , PeakPagefileUsage : NumGet(Ptr, 20+2*A_PtrSize, "UInt")        ; DWORD         PeakPagefileUsage.
                          , WorkingSetSize    : NumGet(Ptr, 24+2*A_PtrSize, "UInt")        ; DWORD         WorkingSetSize.
                          , PeakWorkingSetSize: NumGet(Ptr, 28+2*A_PtrSize, "UInt")        ; DWORD         PeakWorkingSetSize.
                          , UserTime          : NumGet(Ptr, 32+2*A_PtrSize, "UInt64")      ; LARGE_INTEGER UserTime.
                          , KernelTime        : NumGet(Ptr, 40+2*A_PtrSize, "UInt64") } )  ; LARGE_INTEGER KernelTime.
        Ptr += 48 + 2*A_PtrSize  ; Next WTS_PROCESS_INFO_EX structure.
    }

    DllCall("Wtsapi32.dll\WTSFreeMemoryExW", "Int", 1, "Ptr", pWTS_PROCESS_INFO_EX, "UInt", Count)
    return ProcessList
} ; https://docs.microsoft.com/en-us/windows/win32/api/wtsapi32/nf-wtsapi32-wtsenumerateprocessesexw
