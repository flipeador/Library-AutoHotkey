/*
    Allocates the specified number of bytes from the heap.
    Parameters:
        Bytes:
            The number of bytes to allocate.
            If this parameter is zero and «Flags» specifies GMEM_MOVEABLE, the function returns a handle to a memory object that is marked as discarded.
        Flags:
            The memory allocation attributes.
            This parameter can be one or more of the following values.
            ┌────────┬───────────────┬──────────────────────────────────────────────────────────────┐
            │ Value  │ Constant      │ Meaning                                                      │
            ├────────┼───────────────┼──────────────────────────────────────────────────────────────┤
            │ 0x0000 │ GMEM_FIXED    │ Allocates fixed memory. The return value is a pointer.       │
            │ 0x0002 │ GMEM_MOVEABLE │ Allocates movable memory. Cannot be combined with GMEM_FIXED.│
            │ 0x0040 │ GMEM_ZEROINIT │ Initializes memory contents to zero.                         │
            └────────┴───────────────┴──────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is a handle to the newly allocated memory object.
        If the function fails, an exception is thrown describing the error.
*/
GlobalAlloc(Bytes, Flags := 0)
{
    local r := DllCall("Kernel32.dll\GlobalAlloc", "UInt", Flags  ; UINT    uFlags.
                                                 , "UPtr", Bytes  ; SIZE_T  dwBytes.
                                                 , "UPtr")        ; HGLOBAL ReturnValue.
    if !r
        throw Exception(Format("Function`sGlobalAlloc`serror`s0x{:08X}.",A_LastError), -1, Format("Kernel32.dll\GlobalAlloc`s{}`s{}.",Bytes,Flags))
    return r
} ; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globalalloc





/*
    Frees the specified global memory object and invalidates its handle.
    Parameters:
        hMem:
            A handle to the global memory object.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, an exception is thrown describing the error.
*/
GlobalFree(hMem)
{
    if DllCall("Kernel32.dll\GlobalFree", "UPtr", hMem, "UPtr")
        throw Exception(Format("Function`sGlobalFree`serror`s0x{:08X}.",A_LastError), -1, Format("Kernel32.dll\GlobalFree`s0x{:p}.",hMem))
    return hMem
}
