ComVar(Type := 0xC)
{
    return new Class_ComVar(Type)
}


class Class_ComVar
{
    __New(Type)
    {
        local

        this.arr := ComObjArray(Type, 1)

        ; SafeArrayAccessData function.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/oleauto/nf-oleauto-safearrayaccessdata.
        DllCall("OleAut32.dll\SafeArrayAccessData", "Ptr", ComObjValue(this.arr), "PtrP", pData:=0)

        this.ref := ComObject(0x4000|Type, pData)
    }

    __Delete()
    {
        ; SafeArrayUnaccessData function.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/oleauto/nf-oleauto-safearrayunaccessdata.
        DllCall("OleAut32.dll\SafeArrayUnaccessData", "Ptr", ComObjValue(this.arr))
    }

    __Item[]
    {
        get => this.arr[0]
        set => this.arr[0] := Value
    }
}
