class Memory
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Handle     := 0
    Ptr        := 0


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    GetHandle()
    {
        local Handle := this.Handle
        return !( this.Handle := 0 ) && Handle
    }

    CopyFrom(Address, Offset, Bytes)
    {
        DllCall("msvcrt.dll\memcpy_s", "UPtr", this.Ptr+Offset, "UPtr", this.Size-Offset, "UPtr", Address, "UPtr", Bytes, "Cdecl")
        return this
    }

    CopyTo(Address, Offset, Bytes)
    {
        DllCall("msvcrt.dll\memcpy", "UPtr", Address, "UPtr", this.Ptr+Offset, "UPtr", Bytes, "Cdecl")
        return this
    }

    Fill(UChar, Offset := 0, Bytes := -1)    ; UChar   0-255
    {
        DllCall("NtDll.dll\RtlFillMemory", "UPtr", this.Ptr+Offset, "UPtr", Bytes == -1 ? this.Size-Offset : Bytes, "UChar", UChar)
        return this
    }

    Compare(Address, Offset := 0, Bytes := -1)
    {
        return DllCall("msvcrt.dll\memcmp", "UPtr", this.Ptr+Offset, "UPtr", Address, "UPtr", Bytes == -1 ? this.Size-Offset : Bytes, "CDecl")
    } ; https://msdn.microsoft.com/es-es/library/zyaebf12.aspx

    Trim(Offset, Bytes := -1)
    {
        DllCall("msvcrt.dll\memmove", "UPtr", this.Ptr, "UPtr", this.Ptr+Offset, "UPtr", Bytes := Bytes == -1 ? this.Size-Offset : Bytes, "Cdecl")
        return this.ReAlloc(Bytes)
    } ; https://msdn.microsoft.com/es-es/library/8k35d1fx.aspx

    Chr(UChar, Offset := 0, Count := -1)
    {
        return DllCall("msvcrt.dll\memchr", "UPtr", this.Ptr+Offset, "UChar", UChar, "UPtr", Count == -1 ? this.Size-Offset : Count, "CDecl UPtr")
    } ; https://msdn.microsoft.com/es-es/library/d7zdhf37.aspx


    ; ===================================================================================================================
    ; PUBLIC CLASSES
    ; ===================================================================================================================
    #Include Heap.ahk         ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366711(v=vs.85).aspx
    #Include Global.ahk       ; https://docs.microsoft.com/es-es/windows/desktop/Memory/global-and-local-functions
}
