class Client
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static GUID   := ""
    static Handle := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        global AHkInstance
        local

        ; Creates a GUID, a unique 128-bit integer used for CLSIDs and interface identifiers.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/combaseapi/nf-combaseapi-cocreateguid.
        VarSetCapacity(GUID, 16)
        if R := DllCall("Ole32.dll\CoCreateGuid", "Ptr", &GUID, "UInt")
            throw Exception("AHkInstance::Client class, constructor.", -1, Format("CoCreateGuid Error 0x{:08X}.",R))

        ; Converts a globally unique identifier (GUID) into a string of printable characters.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/combaseapi/nf-combaseapi-stringfromguid2.            
        VarSetCapacity(Buffer, 2*38+2, 0)
        DllCall("Ole32.dll\StringFromGUID2", "Ptr", &GUID, "Str", Buffer, "Int", 39)
        AHkInstance.Client.GUID := Buffer

        Handle := 0
        R := DllCall("OleAut32.dll\RegisterActiveObject",  "UPtr", &this      ; IUnknown   The active object.
                                                        ,  "UPtr", &GUID      ; REFCLSID   The CLSID of the active object.
                                                        ,  "UInt", 0          ; DWORD      Flags. ACTIVEOBJECT_STRONG = 0. ACTIVEOBJECT_WEAK = 1.
                                                        , "UIntP", Handle     ; DWORD      Receives a handle.
                                                        , "UInt")             ; HRESULT    HRESULT error code.
        if R
            throw Exception("AHkInstance::Client class, constructor.", -1, Format("RegisterActiveObject Error 0x{:08X}.",R))
        AHkInstance.Client.Handle := Handle
    }
    

    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    Close()
    {
        global AHkInstance
        local

        if R := DllCall("OleAut32.dll\RevokeActiveObject", "UInt", AHkInstance.Client.Handle, "Ptr", 0, "UInt")
            throw Exception("AHkInstance::Client class, close method.", -1, Format("RevokeActiveObject Error 0x{:08X}.",R))

        this.base := ObjSetCapacity(this, 0*ObjDelete(this,"",Chr(0x10FFFF)))  ; Invalidate this object.
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Call(Func, Args*)
    {
        return %Func%(Args*)
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    G[VarName]
    {
        get 
        {
            global
            return %VarName%
        }

        set
        {
            global
            return %VarName% := value
        }
    }
}
