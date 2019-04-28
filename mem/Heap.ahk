class Heap extends Memory
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Flags := 4, InitialSize := 0, MaximumSize := 0)
    {
        ; HEAP_NO_SERIALIZE = 1, HEAP_GENERATE_EXCEPTIONS = 4, HEAP_CREATE_ENABLE_EXECUTE = 0x40000
        this.Handle := DllCall("Kernel32.dll\HeapCreate", "UInt", Flags, "UPtr", InitialSize, "UPtr", MaximumSize, "Ptr")
        return this.Handle && this
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366599(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if ( this.Handle )
            ; Processes can call HeapDestroy without first calling the HeapFree function to free memory allocated from the heap.
            DllCall("Kernel32.dll\HeapDestroy", "UPtr", this.Handle)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366700(v=vs.85).aspx


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Alloc(Bytes, Flags := 4)
    {
        ; HEAP_NO_SERIALIZE = 1, HEAP_GENERATE_EXCEPTIONS = 4, HEAP_ZERO_MEMORY = 8
        this.ptr := DllCall("Kernel32.dll\HeapAlloc", "UPtr", this.Handle, "UInt", Flags, "UPtr", Bytes, "UPtr")
        return this.ptr && this
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366597(v=vs.85).aspx

    ReAlloc(Bytes, Flags := 4)
    {
        ; HEAP_NO_SERIALIZE = 1, HEAP_GENERATE_EXCEPTIONS = 4, HEAP_ZERO_MEMORY = 8, HEAP_REALLOC_IN_PLACE_ONLY = 0x10
        this.ptr := DllCall("Kernel32.dll\HeapReAlloc", "UPtr", this.Handle, "UInt", Flags, "UPtr", this.Ptr, "UPtr", Bytes, "UPtr")
        return this.ptr && this
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366704(v=vs.85).aspx

    Free(Flags := 0)
    {
        ; HEAP_NO_SERIALIZE = 1
        return DllCall("Kernel32.dll\HeapFree", "UPtr", this.Handle, "UInt", Flags, "UPtr", this.Ptr, "UInt") && !( this.ptr := 0 ) && this
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366701(v=vs.85).aspx

    Clone(Offset := 0, Bytes := -1)
    {
        local Mem := new Memory.Heap().Alloc(Bytes == -1 ? this.Size-Offset : Bytes)
        return this.CopyTo(Mem.Ptr, Offset, Mem.Size) ? Mem : 0
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    Size[Flags := 1]
    {
        Get {   
            ; HEAP_NO_SERIALIZE = 1
            return DllCall("Kernel32.dll\HeapSize", "UPtr", this.Handle, "UInt", Flags, "UPtr", this.Ptr, "UPtr")
        } ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366706(v=vs.85).aspx
    }
}
