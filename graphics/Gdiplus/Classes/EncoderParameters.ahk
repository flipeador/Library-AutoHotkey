/*
    An EncoderParameter object holds a parameter that can be passed to an image encoder.
    An EncoderParameter object can also be used to receive a list of possible values supported by a particular parameter of a particular image encoder.

    EncoderParameter Class:
        https://docs.microsoft.com/en-us/previous-versions/ms534434%28v%3dvs.85%29

    Remarks:
        Use the Gdiplus::EncoderParameters method to instantiate this object.
*/
class EncoderParameter
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static Size  := 24+A_PtrSize  ; sizeof(EncoderParameter).


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr  := 0             ; Buffer.
    Size := 24+A_PtrSize  ; Buffer size.
    Val  := 0             ; Value.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Ptr) => this.Ptr := Ptr
    static New(Ptr) => Ptr ? base.New(Ptr) : 0


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    SetData(Guid, NumberOfValues, Type, Value)
    {
        this.Guid           := Guid
        this.NumberOfValues := NumberOfValues
        this.Type           := Type
        this.Value          := Value
        return this.Value
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the GUID that represent the parameter category. See Image Encoder Constants.
        Get: Returns a pointer to the GUID (16 bytes).
        Set: Value must be a string, a memory address or a Buffer-like object (data is copied).
    */
    Guid[]
    {
        get => this.Ptr
        set {
            if (Type(Value) == "String")
                DllCall("Ole32.dll\CLSIDFromString", "Str", Value, "Ptr", this)
            else DllCall("NtDll.dll\RtlCopyMemory", "Ptr", this, "Ptr", Value, "Ptr", 16)
        }
    }

    /*
        Gets or sets the number of values in the array pointed to by the Value property.
    */
    NumberOfValues[]
    {
        get => NumGet(this, 16, "UInt")
        set => NumPut("UInt", Value, this, 16)
    }

    /*
        Gets or sets the data type of the parameter (Value property).
        The EncoderParameterValueType Enumeration defines several possible value types.
    */
    Type[]
    {
        get => NumGet(this, 20, "UInt")
        set => NumPut("UInt", Value, this, 20)
    }

    /*
        Gets or sets the parameter. The parameter is a pointer to a block of custom metadata.
    */
    Value[]
    {
        get => NumGet(this, 24, "UPtr")
        set {
            this.Val := Value
            NumPut("UPtr", Type(Value)=="String"?&this.Val:IsObject(Value)?Value.Ptr:Value, this, 24)
        }
    }
}





/*
    An EncoderParameters object is an array of Gdiplus::EncoderParameter objects along with a data member that specifies the number of EncoderParameter objects in the array.

    EncoderParameters Class:
        https://docs.microsoft.com/en-us/previous-versions/ms534435(v=vs.85)
*/
class EncoderParameters
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer    := 0
    Ptr       := 0
    Size      := 0
    Parameter := []


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Count)
    {
        this.Buffer := BufferAlloc(A_PtrSize+Count*Gdiplus.EncoderParameter.Size, 0)
        this.Ptr    := this.Buffer.Ptr
        this.Size   := this.Buffer.Size

        NumPut("UInt", Count, this.Buffer)  ; EncoderParameters::Count    Number of EncoderParameter objects in the array.

        loop (Count)
        {
            local Ptr              := this.Ptr + A_PtrSize + (A_Index-1)*Gdiplus.EncoderParameter.Size
            local EncoderParameter := Gdiplus.EncoderParameter.New(Ptr)  ; EncoderParameters::Parameter[A_Index]    Array of EncoderParameter objects.
            this.Parameter.Push(EncoderParameter)
        }
    }


    ; ===================================================================================================================
    ; SPECIAL METHODS AND PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the EncoderParameter object at the specified index.
    */
    __Item[Index]
    {
        get => this.Parameter[Index]
        set => this.Parameter[Index] := Value
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets the number of EncoderParameter objects in the array.
    */
    Count[] => NumGet(this.Buffer, "UInt")
}





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates a Gdiplus::EncoderParameters object.
    Parameters:
        CountOrBuffer:
            If this parameter is an integer, specifies the number of Gdiplus::EncoderParameter objects to allocate.
            If this parameter is a Buffer-like object, specifies an existing Gdiplus::EncoderParameters structure.
            The Size property of the Buffer-like object is ignored.
    Return value:
        The return value is a Gdiplus::EncoderParameters object containing one or more Gdiplus::EncoderParameter objects.
*/
static EncoderParameters(CountOrBuffer)
{
    if (!IsObject(CountOrBuffer))  ; Count.
        return Gdiplus.EncoderParameters.New(CountOrBuffer)

    local EncoderParameters := Gdiplus.EncoderParameters(NumGet(CountOrBuffer,"UInt"))
    loop (EncoderParameters.Count)
    {
        local Offset := A_PtrSize + (A_Index-1)*Gdiplus.EncoderParameter.Size
        DllCall("msvcrt.dll\memcpy", "UPtr", EncoderParameters.Ptr + Offset  ; Dest.
                                   , "UPtr", CountOrBuffer.Ptr     + Offset  ; Source.
                                   , "UPtr", Gdiplus.EncoderParameter.Size   ; Bytes.
                                   , "CDecl UPtr")
    }
    return EncoderParameters
}
