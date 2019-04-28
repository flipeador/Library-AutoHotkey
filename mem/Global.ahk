class Global extends Memory
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Size := 0, Flags := 2)
    {
        ; GMEM_FIXED = 0, GMEM_MOVEABLE = 2, GMEM_ZEROINIT = 40
        this.Handle := DllCall("Kernel32.dll\GlobalAlloc", "UInt", this.Flags:=Flags, "UPtr", Size, "Ptr")
        if !( Flags & 2 )
            this.ptr := this.Handle
        return this.Handle && this
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/WinBase/nf-winbase-globalalloc


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if ( this.Handle )
        {
            this.UnLockAll()
            if ( DllCall("Kernel32.dll\GlobalFree", "UPtr", this.Handle, "UPtr") )
                throw Exception("Memory.Global.__Delete Error", -1, this.Handle)
        }
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/WinBase/nf-winbase-globalfree


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    GetHandle()
    {
        this.UnLockAll()
        local Handle := this.Handle
        return !( this.Handle := 0 ) && Handle
    }

    ReAlloc(Size, Flags := 2)
    {
        ; GMEM_FIXED = 0, GMEM_MOVEABLE = 2, GMEM_ZEROINIT = 40
        this.UnLockAll()
        this.Handle := DllCall("Kernel32.dll\GlobalReAlloc", "UPtr", this.Handle, "UPtr", Size, "UInt", this.Flags:=Flags, "UPtr")
        return this.Handle && this
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/WinBase/nf-winbase-globalrealloc

    Free()    ; #define GlobalDiscard( h )      GlobalReAlloc( (h), 0, GMEM_MOVEABLE )
    {
        this.ptr := this.ReAlloc( 0, 2 )
        return this
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/WinBase/nf-winbase-globaldiscard

    Lock()
    {
        this.ptr := DllCall("Kernel32.dll\GlobalLock", "UPtr", this.Handle, "UPtr")
        return this.ptr && this
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/WinBase/nf-winbase-globallock

    UnLock()
    {
        return DllCall("Kernel32.dll\GlobalUnlock", "UPtr", this.Handle, "UInt") || ( this.ptr := 0 )
    } ; https://docs.microsoft.com/es-es/windows/desktop/api/winbase/nf-winbase-globalunlock

    UnLockAll()
    {
        if ( this.Flags & 2 )
            while ( this.UnLock() )
                continue
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    Size[]
    {
        Get {   
            return DllCall("Kernel32.dll\GlobalSize", "UPtr", this.Handle, "UPtr")
        } ; https://docs.microsoft.com/en-us/windows/desktop/api/WinBase/nf-winbase-globalsize
    }

    LockCount[]
    {
        get {
            return DllCall("Kernel32.dll\GlobalFlags", "UPtr", this.Handle, "UInt")
        } ; https://docs.microsoft.com/es-es/windows/desktop/api/winbase/nf-winbase-globalflags
    }
}
