/*
    Retrieves a list with all processes in the system.
    Return value:
        If the function succeeds, the return value is an object with the keys 'ProcessId', 'ParentProcessId', 'ExeFile' and 'Threads'.
        If the function fails, the return value is zero.
*/
ProcessGetList()
{
    local

    hSnapshot := DLLCall("Kernel32.dll\CreateToolhelp32Snapshot", "UInt", 0x00000002, "UInt", 0, "Ptr")  ; TH32CS_SNAPPROCESS = 0x00000002.
    if (hSnapshot == -1)  ; INVALID_HANDLE_VALUE == ((HANDLE)(LONG_PTR)-1).
        return 0

    
    PROCESSENTRY32 := BufferAlloc(A_PtrSize==4?556:568)
    NumPut("UInt", PROCESSENTRY32.Size, PROCESSENTRY32)

    List := [ ]

    if DllCall("Kernel32.dll\Process32FirstW", "Ptr", hSnapshot, "Ptr", PROCESSENTRY32)
    {
        loop
        {
            List[A_Index] := { ProcessId      : NumGet(PROCESSENTRY32    , 8                  , "UInt"  )
                             , ParentProcessId: NumGet(PROCESSENTRY32    , A_PtrSize==4?24:32 , "UInt"  )
                             , ExeFile        : StrGet(PROCESSENTRY32.Ptr+(A_PtrSize==4?36:44), "UTF-16")
                             , Threads        : NumGet(PROCESSENTRY32    , A_PtrSize==4?20:28 , "UInt"  ) }
        }
        until !DllCall("Kernel32.dll\Process32NextW", "Ptr", hSnapshot, "Ptr", PROCESSENTRY32)
    }

    DllCall("Kernel32.dll\CloseHandle", "Ptr", hSnapshot)

    return List.Length() ? List : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-createtoolhelp32snapshot





/*
    Same as ProcessGetList, but using the NtQuerySystemInformation function.
    NOTE: NtQuerySystemInformation may be altered or unavailable in future versions of Windows.
    Currently ProcessGetList2 retrieves the same data as ProcessGetList, but NtQuerySystemInformation retrieves more information, see structure SYSTEM_PROCESS_INFORMATION.
*/
ProcessGetList2()
{
    local

    Size     := 0
    NtStatus := DllCall("Ntdll.dll\NtQuerySystemInformation", "Int", 5, "Ptr", 0, "UInt", 0, "UIntP", Size, "UInt")

    if (NtStatus !== 0xC0000004 || !Size)  ; STATUS_INFO_LENGTH_MISMATCH = 0xC0000004.
    {
        A_LastError := NtStatus
        return 0
    }

    Buffer   := BufferAlloc(Size*=2)  ; Double the returned buffer size to ensure sufficient space.
    NtStatus := DllCall("Ntdll.dll\NtQuerySystemInformation", "Int", 5, "Ptr", Buffer, "UInt", Size, "UIntP", Size, "UInt")  ; SystemProcessInformation = 5.

    if (NtStatus !== 0 || Buffer.Size < Size)  ; STATUS_SUCCESS = 0.
    {
        A_LastError := NtStatus
        return 0
    }

    Ptr  := Buffer.Ptr
    List := [ ]

    loop
    {
        List[A_Index] := { ProcessId      : NumGet(Ptr, 56+3*A_PtrSize)  ; UniqueProcessId.
                         , ParentProcessId: NumGet(Ptr, 56+4*A_PtrSize)  ; InheritedFromUniqueProcessId.
                         , ExeFile        : StrGet(NumGet(Ptr,56+A_PtrSize),NumGet(Ptr+56,"UShort")//2)    ; ImageName.Buffer (UNICODE_STRING structure).
                         , Threads        : NumGet(Ptr, 4, "UInt")                                      }  ; ThreadCount.
        Ptr += (NextEntryOffset := NumGet(Ptr,"UInt"))  ; The start of the next item in the array is the address of the previous item plus the value in the NextEntryOffset member.
    }
    until (NextEntryOffset == 0)

    return List
} ; https://docs.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntquerysysteminformation





/*
typedef struct _SYSTEM_PROCESS_INFORMATION {
    ULONG NextEntryOffset;
    ULONG NumberOfThreads;
    BYTE Reserved1[48];
    UNICODE_STRING ImageName;
    KPRIORITY BasePriority;
    HANDLE UniqueProcessId;
    PVOID Reserved2;
    ULONG HandleCount;
    ULONG SessionId;
    PVOID Reserved3;
    SIZE_T PeakVirtualSize;
    SIZE_T VirtualSize;
    ULONG Reserved4;
    SIZE_T PeakWorkingSetSize;
    SIZE_T WorkingSetSize;
    PVOID Reserved5;
    SIZE_T QuotaPagedPoolUsage;
    PVOID Reserved6;
    SIZE_T QuotaNonPagedPoolUsage;
    SIZE_T PagefileUsage;
    SIZE_T PeakPagefileUsage;
    SIZE_T PrivatePageCount;
    LARGE_INTEGER Reserved7[6];
} SYSTEM_PROCESS_INFORMATION, *PSYSTEM_PROCESS_INFORMATION;

typedef struct _SYSTEM_PROCESSES_INFORMATION {
    ULONG NextEntryDelta;
    ULONG ThreadCount;
    LARGE_INTEGER SpareLi1;
    LARGE_INTEGER SpareLi2;
    LARGE_INTEGER SpareLi3;
    LARGE_INTEGER CreateTime;
    LARGE_INTEGER UserTime;
    LARGE_INTEGER KernelTime;
    UNICODE_STRING ImageName;
    KPRIORITY BasePriority;
    HANDLE UniqueProcessId;
    HANDLE InheritedFromUniqueProcessId;
    ULONG HandleCount;
    ULONG SessionId;
    ULONG_PTR PageDirectoryBase;
    VM_COUNTERS VmCounters;
    IO_COUNTERS IoCounters;
    SYSTEM_THREAD_INFORMATION Threads[1];
} SYSTEM_PROCESSES_INFORMATION, *PSYSTEM_PROCESSES_INFORMATION;
*/





/*  ——> E.X.A.M.P.L.E <——
List := ""
for Each, Item in ProcessGetList()
    List .= Format("ProcessId:{6}{1}`nParentProcessId:`t{2}`nExeFile:{6}{3}`nThreads:{6}{4}{5}"
                 ,    Item.ProcessId,    Item.ParentProcessId,    Item.ExeFile,    Item.Threads
                 , "`n-----------------------------------------------------------`n", "`t`t`t")
FileOpen(A_Temp . "~ahktmp.txt", "w-wd", "UTF-8").Write(List)
Run(A_Temp . "~ahktmp.txt")
*/
