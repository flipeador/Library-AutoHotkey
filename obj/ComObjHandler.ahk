ComObjHandler(Methods := "", QueryInterface := 0, AddRef := 0, Release := 0)  ; Methods: "[ClassName:][&ParamCount]Method1|[&ParamCount]Method2|..."
{
    local

    Methods   := StrSplit(Trim(Methods,"`s`t`r`n"), [":",A_Space])
    ClassName := Trim(Methods[1]) == "" ? "" : Trim(Methods[1]) . "."
    Methods   := Methods.Length() ==  1 ? [] : StrSplit(Trim(Methods[2]),["|",",",";"])

    Result    := { }

    ; Object's virtual function table.
    Size    := ((3 + Methods.Length()) * A_PtrSize) + A_PtrSize  ; +A_PtrSize = null pointer indicating the end.
    pVTable := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x40, "UPtr", Size, "UPtr")  ; GMEM_ZEROINIT = 0x40.

    NumPut("UPtr", Type(QueryInterface) == "Integer" ? (QueryInterface || CallbackCreate("ComObjHandler_QueryInterface")) : CallbackCreate(QueryInterface)
         , "UPtr", Type(AddRef)         == "Integer" ? (AddRef         || CallbackCreate("ComObjHandler_AddRef")        ) : CallbackCreate(AddRef        )
         , "UPtr", Type(Release)        == "Integer" ? (Release        || CallbackCreate("ComObjHandler_Release")       ) : CallbackCreate(Release       )
         , pVTable)

    for Each, Method in Methods
    {
        Match      := RegExMatch(Method, "&(\d*)", ParamCount)
        Method     := RegExReplace(Method, "&\d*")
        ParamCount := Match ? ParamCount[1] == "" ? Func(ClassName . Method).MinParams : ParamCount[1] : ""
        pCallback  := Method is "Integer" ? Integer(Method) : CallbackCreate(ClassName . Method,Match?"&":"",ParamCount)
        NumPut("UPtr", pCallback, pVTable, (2+A_Index)*A_PtrSize)
        ObjRawSet(Result, "p" . (Method is "Integer" ? A_Index : Method), pCallback)
    }

    Result.Size   := Size - A_PtrSize
    Result.VTable := pVTable

    ; ---------------

    Result.Ptr := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0, "UPtr", A_PtrSize+4, "UPtr")  ; GMEM_FIXED = 0.
    NumPut("UPtr", pVTable  ; VTable.
         , "UInt", 1        ; RefCount (32-bit unsigned integer).
         , Result.Ptr)

    return Result
}





ComObjHandler_QueryInterface(Ptr, IID, pObject)
{
    ; DllCall("Ole32.dll\CLSIDFromString", "Str", "{00000000-0000-0000-C000-000000000046}", "Ptr", IID_IUnknown)
    ; DllCall("Ole32.dll\IsEqualGUID", "Ptr", IID, "Ptr", IID_IUnknown)
    NumPut("UPtr", 0, pObject)
    return 0x80004002  ; E_NOINTERFACE.
} ; https://docs.microsoft.com/en-us/windows/desktop/api/unknwn/nf-unknwn-iunknown-queryinterface%28refiid_void%29





ComObjHandler_AddRef(Ptr)
{
    local RefCount := NumGet(Ptr, A_PtrSize, "UInt")
    NumPut("UInt", ++RefCount, Ptr, A_PtrSize)
    return RefCount
} ; https://docs.microsoft.com/en-us/windows/desktop/api/unknwn/nf-unknwn-iunknown-addref





ComObjHandler_Release(Ptr)
{
    local

    RefCount := NumGet(Ptr, A_PtrSize, "UInt")
    if (RefCount > 0)
    {
        NumPut("UInt", --RefCount, Ptr, A_PtrSize)
        if (RefCount == 0)
        {
            pVTable := NumGet(Ptr, "UPtr")
            while pCallback := NumGet(pVTable, (A_Index-1)*A_PtrSize, "UPtr")
                CallbackFree(pCallback)
            if DllCall("Kernel32.dll\GlobalFree", "Ptr", pVTable, "Ptr")
            || DllCall("Kernel32.dll\GlobalFree", "Ptr", Ptr, "Ptr")
                throw Exception("0x0000000", -1, "ComObjHandler_Release, GlobalFree")
        }
    }
    return RefCount
} ; https://docs.microsoft.com/en-us/windows/desktop/api/unknwn/nf-unknwn-iunknown-release





/*  EXAMPLE ---> <---
Handler := ComObjHandler("MyInterface:&Method1|&Method2",,, "Handler_OnRelease")  ; & = &1 = for x86.
MsgBox(Format("Handler.Ptr = {}`nHandler.Size = {} bytes`nHandler.VTable = {}`nMyInterface.Method1() = {}`nMyInterfaceMethod2() = {}"
            , Handler.Ptr    . " (" . Format("0x{:016X}",Handler.Ptr)     . ")"
            , Handler.Size
            , Handler.VTable . " (" . Format("0x{:016X}", Handler.VTable) . ")"
            , DllCall(Handler.pMethod1, "Int", 256, "Str")
            , DllCall(Handler.pMethod2, "Int", 666, "Str")
            )
      )
ObjRelease(Handler.Ptr)
ExitApp()

Handler_OnRelease(Ptr)
{
    local RefCount := ComObjHandler_Release(Ptr)  ; !
    MsgBox("Released.`n`nRefCount: " . RefCount)
}

class MyInterface
{
    Method1()
    {
        return &(A_ThisFunc . ":" . NumGet(this,"Int"))  ; 'this' is the address of the parameter list: CallbackCreate(..,"&",1).
    }

    Method2()
    {
        return &(A_ThisFunc . ":" . NumGet(this,"Int"))
    }
}
*/
