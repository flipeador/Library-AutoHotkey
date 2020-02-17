/*
    Reserves, commits, or changes the state of a region of memory within the virtual address space of a specified process.
    Parameters:
        Process:
            The handle to a process.
            The handle must have the PROCESS_VM_OPERATION access right.
        Address:
            The desired starting address for the region of pages that you want to allocate.
            If this parameter is zero, the function determines where to allocate the region.
        Bytes:
            The size of the region of memory to allocate, in bytes.
            If «Address» is zero, the function rounds «Bytes» up to the next page boundary.
            If «Address» is not zero, the function allocates all pages that contain one or more bytes in the range from «Address» to «Address»+«Bytes».
        AllocationType:
            The type of memory allocation. This parameter must contain one of the following values.
            ┌────────────┬────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value      │ Constant       │ Meaning                                                                                                                                                                │
            ├────────────┼────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x00001000 │ MEM_COMMIT     │ Allocates memory charges (from the overall size of memory and the paging files on disk) for the specified reserved memory pages.                                       │
            │ 0x00002000 │ MEM_RESERVE    │ Reserves a range of the process's virtual address space without allocating any actual physical storage in memory or in the paging file on disk.                        │
            │ 0x00080000 │ MEM_RESET      │ Indicates that data in the memory range specified by lpAddress and dwSize is no longer of interest.                                                                    │
            │ 0x01000000 │ MEM_RESET_UNDO │ Indicates that the data in the specified memory range specified by lpAddress and dwSize is of interest to the caller and attempts to reverse the effects of MEM_RESET. │
            └────────────┴────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
            This parameter can also specify the following values as indicated.
            ┌────────────┬─────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value      │ Constant        │ Meaning                                                                                                                                                   │
            ├────────────┼─────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x00100000 │ MEM_TOP_DOWN    │ Allocates memory at the highest possible address. This can be slower than regular allocations, especially when there are many allocations.                │
            │ 0x00400000 │ MEM_PHYSICAL    │ Reserves an address range that can be used to map Address Windowing Extensions (AWE) pages. This value must be used with MEM_RESERVE and no other values. │
            │ 0x20000000 │ MEM_LARGE_PAGES │ Allocates memory using large page support. Requires MEM_RESERVE and MEM_COMMIT.                                                                           │
            └────────────┴─────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
            Reference: (https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualallocex).
        Protect:
            The memory protection for the region of pages to be allocated.
            If «Address» specifies an address within an enclave, «Protect» cannot be PAGE_NOACCESS, PAGE_GUARD, PAGE_NOCACHE and PAGE_WRITECOMBINE.
            If the pages are being committed, you can specify any one of the memory protection constants.
            ┌───────┬────────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value │ Constant               │ Meaning                                                                                        │
            ├───────┼────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x01  │ PAGE_NOACCESS          │ Disables all access to the committed region of pages.                                          │
            │ 0x02  │ PAGE_READONLY          │ Enables read-only access to the committed region of pages.                                     │
            │ 0x04  │ PAGE_READWRITE         │ Enables read-only or read/write access to the committed region of pages.                       │
            │ 0x08  │ PAGE_WRITECOPY         │ Enables read-only or copy-on-write access to a mapped view of a file mapping object.           │
            │ 0x10  │ PAGE_EXECUTE           │ Enables execute access to the committed region of pages.                                       │
            │ 0x20  │ PAGE_EXECUTE_READ      │ Enables execute or read-only access to the committed region of pages.                          │
            │ 0x40  │ PAGE_EXECUTE_READWRITE │ Enables execute, read-only, or read/write access to the committed region of pages.             │
            │ 0x80  │ PAGE_EXECUTE_WRITECOPY │ Enables execute, read-only, or copy-on-write access to a mapped view of a file mapping object. │
            └───────┴────────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────┘
            The following are modifiers that can be used in addition to the options provided in the previous table.
            ┌───────┬───────────────────┬───────────────────────────────────────────────────────────────────────────────────────┐
            │ Value │ Constant          │ Meaning                                                                               │
            ├───────┼───────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x100 │ PAGE_GUARD        │ Pages in the region become guard pages. This value cannot be used with PAGE_NOACCESS. │
            │ 0x200 │ PAGE_NOCACHE      │ Sets all pages to be non-cachable.                                                    │
            │ 0x400 │ PAGE_WRITECOMBINE │ Sets all pages to be write-combined.                                                  │
            └───────┴───────────────────┴───────────────────────────────────────────────────────────────────────────────────────┘
            Reference: (https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants).
    Return value:
        If the function succeeds, the return value is the base address of the allocated region of pages.
        If the function fails, the return value is zero. A_LastError contains extended error information.
    Remarks:
        This function initializes the memory it allocates to zero.
*/
VirtualAlloc(Process, Address, Bytes, AllocationType := 0x1000, Protect := 0x04)
{
    return DllCall("Kernel32.dll\VirtualAllocEx",  "Ptr", Process         ; hProcess.
                                                , "UPtr", Address         ; lpAddress.
                                                , "UPtr", Bytes           ; dwSize.
                                                , "UInt", AllocationType  ; flAllocationType.
                                                , "UInt", Protect         ; flProtect.
                                                , "UPtr")                 ; LPVOID.
} ; https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualallocex





/*
    Releases, decommits, or releases and decommits a region of memory within the virtual address space of a specified process.
    Parameters:
        Process:
            The handle to a process.
            The handle must have the PROCESS_VM_OPERATION access right.
        Address:
            The starting address of the region of memory to be freed.
            If the «FreeType» parameter is MEM_RELEASE, «Address» must be the base address returned by the VirtualAlloc function when the region is reserved.
        Bytes:
            The size of the region of memory to free, in bytes.
            If the «FreeType» parameter is MEM_RELEASE, «Bytes» must be zero. The function frees the entire region that is reserved in the initial allocation call to VirtualAlloc.
        FreeType:
            The type of free operation. This parameter can be one of the following values.
            ┌────────┬───────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────┐
            │ Value  │ Constant                  │ Meaning                                                                               │
            ├────────┼───────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x0001 │ MEM_COALESCE_PLACEHOLDERS │ To coalesce two adjacent placeholders, specify MEM_RELEASE|MEM_COALESCE_PLACEHOLDERS. │
            │ 0x0002 │ MEM_PRESERVE_PLACEHOLDER  │ Frees an allocation back to a placeholder.                                            │
            │ 0x4000 │ MEM_DECOMMIT              │ Decommits the specified region of committed pages.                                    │
            │ 0x8000 │ MEM_RELEASE               │ Releases the specified region of pages, or placeholder.                               │
            └────────┴───────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────┘
            Reference: (https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualfreeex).
    Return value:
        If the function succeeds, the return value is a nonzero value.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
VirtualFree(Process, Address, Bytes := 0, FreeType := 0x8000)
{
    return DllCall("Kernel32.dll\VirtualFreeEx",  "Ptr", Process    ; hProcess.
                                               , "UPtr", Address    ; lpAddress.
                                               , "UPtr", Bytes      ; dwSize.
                                               , "UInt", FreeType)  ; dwFreeType.
} ; https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualfreeex





/*
    Changes the protection on a region of committed pages in the virtual address space of a specified process.
    Parameters:
        Process:
            A handle to the process whose memory protection is to be changed.
            The handle must have the PROCESS_VM_OPERATION access right.
        Address:
            The base address of the region of pages whose access protection attributes are to be changed.
        Bytes:
            The size of the region whose access protection attributes are changed, in bytes.
        Protect:
            The memory protection option. See the VirtualAlloc function.
            For mapped views, this value must be compatible with the access protection specified when the view was mapped.
            Reference: (https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants).
    Return value:
        If the function succeeds, the return value is the previous access protection of the first page in the specified region of pages.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
VirtualProtect(Process, Address, Bytes, Protect)
{
    local OldProtect := 0
    return DllCall("Kernel32.dll\VirtualProtectEx",   "Ptr", Process      ; hProcess.
                                                  ,  "UPtr", Address      ; lpAddress.
                                                  ,  "UPtr", Bytes        ; dwSize.
                                                  ,  "UInt", Protect      ; flNewProtect.
                                                  , "UIntP", OldProtect)  ; lpflOldProtect.
         ? OldProtect  ; Ok.
         : 0           ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualprotectex





/*
    Reads data from an area of memory in a specified process into an application-supplied buffer.
    Parameters:
        Process:
            A handle to the process with memory that is being read.
            The handle must have the PROCESS_VM_READ access right.
        BaseAddress:
            A pointer to the base address in the specified process from which to read.
        Buffer:
            A buffer that receives the contents from the address space of the specified process.
            ---------------------------------------------------------------------------------------
            If this parameter is omitted, the function allocates a Buffer of «Bytes» bytes.
            If the function succeeds, the return value is an object with properties 'Buffer', 'Ptr', 'Size' and 'BytesRead'.
            If the function fails, the return value is zero. A_LastError contains extended error information.
        Bytes:
            The number of bytes to be read from the specified process.
            This parameter can be omitted if «Buffer» specifies a Buffer object.
    Return value:
        If the function succeeds, the return value is the number of bytes transferred into the specified buffer.
        If the function fails, the return value is <0. A_LastError contains extended error information.
    Remarks:
        The entire area to be read must be accessible or the operation fails.
        Before any data transfer occurs, the system verifies that all data in the base address and memory of the specified size is accessible for read access, and if it is not accessible the function fails.
*/
VirtualRead(Process, BaseAddress, Buffer := "", Bytes := "")
{
    local BytesRead := 0, BufferObj := 0  ; Ntdll.dll\NtReadVirtualMemory | Kernel32.dll\Toolhelp32ReadProcessMemory.
    return DllCall("Kernel32.dll\ReadProcessMemory",   "Ptr", Process                                                ; hProcess.
                                                   ,   "Ptr", BaseAddress                                            ; lpBaseAddress.
                                                   ,   "Ptr", Buffer=="" ? (BufferObj:=BufferAlloc(Bytes)) : Buffer  ; lpBuffer.
                                                   ,  "UPtr", Bytes =="" ? Buffer.Size                     : Bytes   ; nSize.
                                                   , "UPtrP", BytesRead)                                             ; *lpNumberOfBytesRead.
         ? (BufferObj ? {Buffer:BufferObj,Ptr:BufferObj.Ptr,Size:Bytes,BytesRead:BytesRead} : BytesRead   )  ; Ok.
         : (BufferObj ? 0                                                                   : -A_LastError)  ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-readprocessmemory

VirtualReadValue(Process, BaseAddress, Type, Size)
{
    local Buffer := VirtualRead(Process, BaseAddress,, Size)
    return Buffer ? NumGet(Buffer,Type) : ""
}

VirtualReadString(Process, BaseAddress, Length := "", Encoding := "UTF-16")
{
    local
    if (Length is "Number")  ; Length = Characters.
        return (Buffer := VirtualRead(Process,BaseAddress,,StrPut("",Encoding)*Length))
             ? StrGet(Buffer,Length,Encoding) : 0
    B := BufferAlloc(StrPut("",Encoding)), S := ""
    while (VirtualRead(Process,BaseAddress+B.Size*(A_Index-1),B) == B.Size)
        if StrLen(S2:=StrGet(B,1,Encoding))
            S .= S2
        else break
    return S
}





/*
    Writes data from an application-supplied buffer to an area of memory in a specified process.
    Parameters:
        Process:
            A handle to the process memory to be modified.
            The handle must have the PROCESS_VM_WRITE and PROCESS_VM_OPERATION access rights.
        BaseAddress:
            A pointer to the base address in the specified process to which data is written.
        Buffer:
            The buffer that contains data to be written in the address space of the specified process.
        Size:
            The number of bytes to be written to the specified process.
            This parameter can be omitted if «Buffer» specifies a Buffer object.
    Return value:
        If the function succeeds, the return value is the number of bytes transferred into the specified process.
        If the function fails, the return value is <0. A_LastError contains extended error information.
    Remarks:
        The entire area to be written to must be accessible, the function fails if the requested write operation crosses into an area of the process that is inaccessible.
        Before data transfer occurs, the system verifies that all data in the base address and memory of the specified size is accessible for write access, and if it is not accessible, the function fails.
*/
VirtualWrite(Process, BaseAddress, Buffer, Bytes := "")
{
    local BytesWritten := 0  ; Ntdll.dll\NtWriteVirtualMemory.
    return DllCall("Kernel32.dll\WriteProcessMemory",   "Ptr", Process                          ; hProcess.
                                                    ,   "Ptr", BaseAddress                      ; lpBaseAddress.
                                                    ,   "Ptr", Buffer                           ; lpBuffer.
                                                    ,  "UPtr", Bytes=="" ? Buffer.Size : Bytes  ; nSize.
                                                    , "UPtrP", BytesWritten)                    ; *lpNumberOfBytesWritten.
         ? BytesWritten  ; Ok.
         : -A_LastError  ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-writeprocessmemory

VirtualWriteValue(Process, BaseAddress, Type, Value, Size)
{
    local Buffer := BufferAlloc(Size)
    return VirtualWrite(Process, BaseAddress, NumPut(Type,Value,Buffer)&&Buffer, Size)
} ; https://docs.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-writeprocessmemory
