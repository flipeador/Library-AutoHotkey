Code := "
(

global A_InstName := "%A_Name%"

oAHkInstance_Client := new AHkInstance_Client()

A_Parent := ComObjActive("%A_Client%")

A_Parent.G["AHkInstance"].Instances[A_InstName] := oAHkInstance_Client.GUID

A_Parent := ""





GetActiveObject(Name := "")
{
    local

    Parent := ComObjActive("%A_Client%")

    if Name == ""
        return Parent

    Instances := Parent.G["AHkInstance"].Instances

    return Instances.HasKey(Name) ? ComObjActive(Instances[Name]) : 0
}

class AHkInstance_Client
{
    static GUID   := ""
    static Handle := 0

    __New()
    {
        global AHkInstance_Client
        local

        VarSetCapacity(GUID, 16)
        if R := DllCall("Ole32.dll\CoCreateGuid", "Ptr", &GUID, "UInt")
            throw Exception("AHkInstance_Client class, constructor.", -1, Format("CoCreateGuid Error 0x{:08X}.",R))

        VarSetCapacity(Buffer, 2*38+2, 0)
        DllCall("Ole32.dll\StringFromGUID2", "Ptr", &GUID, "Str", Buffer, "Int", 39)
        AHkInstance_Client.GUID := Buffer

        Handle := 0
        if R := DllCall("OleAut32.dll\RegisterActiveObject", "UPtr", &this, "UPtr", &GUID, "UInt", 0, "UIntP", Handle, "UInt")           
            throw Exception("AHkInstance_Client class, constructor.", -1, Format("RegisterActiveObject Error 0x{:08X}.",R))
        AHkInstance_Client.Handle := Handle
    }

    __Delete()
    {
        this.Close()
    }

    Close()
    {
        global AHkInstance_Client
        local

        if R := DllCall("OleAut32.dll\RevokeActiveObject", "UInt", AHkInstance_Client.Handle, "Ptr", 0, "UInt")
            throw Exception("AHkInstance_Client class, close method.", -1, Format("RevokeActiveObject Error 0x{:08X}.",R))
    }

    Call(Func, Args*)
    {
        return %Func%(Args*)
    }

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
)"









Code := StrReplace(Code, "%A_Client%", AHkInstance.Client.GUID)
Code := StrReplace(Code, "%A_Name%", this.Name)
