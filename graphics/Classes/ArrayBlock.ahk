/*
    The IArrayBlockBase object represents an array that stores a fixed-size sequential collection of elements of the same type.
    This object is used to store a collection of data (Numbers).

    The following data types are supported:
        Char      An 8-bit integer, whose range is -128 (-0x80) to 127 (0x7F).
        UChar     An unsigned 8-bit integer, whose range is 0 to 255 (0xFF).
        Short     A 16-bit integer, whose range is -32768 (-0x8000) to 32767 (0x7FFF).
        UShort    A unsigned 16-bit integer, whose range is 0 to 65535 (0xFFFF).
        Int       A 32-bit integer, whose range is -2147483648 (-0x80000000) to 2147483647 (0x7FFFFFFF).
        UInt      A unsigned 32-bit integer, whose range is 0 to 4294967295 (0xFFFFFFFF).
        Int64     A 64-bit integer, whose range is -9223372036854775808 (-0x8000000000000000) to 9223372036854775807 (0x7FFFFFFFFFFFFFFF).
        UInt64    A unsigned 64-bit integer, whose range is 0 to 18446744073709551615 (0xFFFFFFFFFFFFFFFF).
        Ptr       Equivalent to Int or Int64 depending on whether the exe running the script is 32-bit or 64-bit.
        UPtr      Equivalent to UInt or UInt64 depending on whether the exe running the script is 32-bit or 64-bit.
        Float     A 32-bit floating point number, which provides 6 digits of precision.
        Double    A 64-bit floating point number, which provides 15 digits of precision.

    Remarks:
        Elements are addressed by their position within the array (known as an array index), where position 1 is the first element.

    Example:
        ArrayBlock("Float", 1.0, 2.0, 3.0)  ; Creates an array and initializes it with 3 real numbers.
        ArrayBlock(3, "Float")              ; Creates an array with capacity to store 3 real numbers (the initial data are garbage).
*/
class IArrayBlockBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static DataTypes := Map("char"  , 1
                          , "uchar" , 1
                          , "short" , 2
                          , "ushort", 2
                          , "int"   , 4
                          , "uint"  , 4
                          , "int64" , 8
                          , "uint64", 8
                          , "ptr"   , A_PtrSize
                          , "uptr"  , A_PtrSize
                          , "float" , 4
                          , "double", 8)


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Buffer        := 0   ; Buffer object containing the data.
    Ptr           := 0   ; Memory address of the buffer.
    Size          := 0   ; Buffer size.
    ValueType     := ""  ; Data type.
    ValueTypeSize := 0   ; Data type size.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Assigns an array buffer containing elements of a specific type. The ArrayBlock function can be used for this purpose.
        Parameters:
            DataType:
                A string with the data type.
                Supported data types: Char, UChar, Short, UShort, Int, UInt, Int64, UInt64, Ptr, UPtr, Float, Double.
            Capacity:
                Specifies the capacity in number of elements capable of storing in the buffer.
                The capacity can be changed at any time as required.
            Values:
                The elements with which the buffer will be initialized.
                The number of elements must not exceed the specified capacity.
                This parameter can be an Array, a Buffer-like object or a memory address.
                This parameter can be zero or omited.
            Count:
                The number of elements to be taken from «Values».
                This parameter is mandatory if «Values» is a memory address.
    */
    __New(DataType, Capacity, Values := 0, Count := -1)
    {
        this.InitBuff(DataType, Capacity, Values, Count)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    /*
        Allocates the memory and optionally write/copy the specified values from an array or buffer.
    */
    InitBuff(DataType, Capacity, Values := 0, Count := -1)
    {
        this.ValueType     := DataType
        this.ValueTypeSize := IArrayBlockBase.DataTypes[Format("{:L}",DataType)]
        this.Buffer        := BufferAlloc(this.ValueTypeSize*Capacity)
        this.Ptr           := this.Buffer.Ptr
        this.Size          := this.Buffer.Size
        switch Type(Values)
        {
        case "Integer":
            if (Values !== 0)
                DllCall("msvcrt.dll\memcpy", "Ptr", this, "Ptr", Values, "Ptr", this.ValueTypeSize*Count, "CDecl Ptr")
        case "Array":
            local Value
            for Value in Values
            {
                NumPut(this.ValueType, Value, this, this.ValueTypeSize*(A_Index-1))
                if (A_Index == Count)
                    break
            }
        default:
            DllCall("msvcrt.dll\memcpy", "Ptr", this, "Ptr", Values, "Ptr", Count<0?Min(Values.Size,this.Size):this.ValueTypeSize*Count, "CDecl Ptr")
        }
        return this
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Fills this object with the specified elements.
        Parameters:
            Target:
                An Array, Buffer-like object or memory address.
            Count:
                The number of elements in the array specified by «Target».
                This parameter is mandatory if «Target» specifies a memory address.
            Index:
                The starting index in which the elements are to be added.
        Return value:
            Returns the number of elements written.
        Remarks:
            If more elements are to be written than the current capacity of the object, you must first call the EnsureCapacity method to ensure sufficient capacity.
    */
    Fill(Target, Count := -1, Index := 0)
    {
        local
        BuffType := Type(Target)=="Array" ? 0 : Type(Target)=="Integer" ? 1 : 2  ; 0=arr|1=ptr|2=buff-l.
        Count    := Count<0 ? (BuffType?Target.Size//this.ValueTypeSize:Target.Length) : Count
        Index    := this.ValueTypeSize * (Index-1)  ; Offset.
        if (BuffType)  ; Buffer-like or memory address.
            DllCall("msvcrt.dll\memcpy", "Ptr", this.Ptr+Index, "Ptr", Target, "Ptr", this.ValueTypeSize*Count, "CDecl Ptr")
        else for Value in Target  ; Array.
        {
            NumPut(this.ValueType, Value, this, this.ValueTypeSize*(A_Index-1)+Index)
            if (A_Index == Count)
                break
        }
        return Count
    }

    /*
        Clones this object and optional converts the data type.
        Parameters:
            DataType:
                A string with the data type for this new object.
                If this parameter is zero, the new object has the same data type as this object.
        Return value:
            Returns a new IArrayBlockBase object.
    */
    Clone(DataType := 0)
    {
        local new_obj := ArrayBlock(this.Capacity, DataType||this.ValueType)
        if (new_obj.ValueType == this.ValueType)
            DllCall("msvcrt.dll\memcpy", "Ptr", new_obj, "Ptr", this, "Ptr", this.Size, "CDecl Ptr")
        else loop (new_obj.Capacity)
            NumPut(new_obj.ValueType, NumGet(this,this.ValueTypeSize*(A_Index-1),this.ValueType), new_obj, new_obj.ValueTypeSize*(A_Index-1))
        return new_obj
    }

    /*
        Ensures that the object has the capacity to store at least the specified number of elements.
        Parameters:
            Count:
                The minimum number of elements that the object must be able to store.
        Returns:
            Returns the current capacity.
    */
    EnsureCapacity(Count)
    {
        if (this.Capacity < Count)
            this.Capacity := Count
        return this.Capacity
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the exact number of elements this object can store.
        The current data are copied to the new buffer when the capacity is changed.
    */
    Capacity[]
    {
        get => this.Size // this.ValueTypeSize
        set {
            if (this.Capacity !== Value)
                this.InitBuff(this.ValueType, Value, this.Buffer)
        }
    }


    ; ===================================================================================================================
    ; SPECIAL METHODS AND PROPERTIES
    ; ===================================================================================================================
    /*
        Enumerates elements in this object.
        Syntax:
            for Value in IArrayBlockBase
            for Index, Value in IArrayBlockBase
    */
    __Enum(NumberOfVars)
    {
        static Enumerator := Func("IArrayBlockBase_Enumerator")
        return Enumerator.Bind(this, NumberOfVars)
    }

    /*
        Gets or sets the value at the specified index in this object.
    */
    __Item[Index]
    {
        get => NumGet(this, this.ValueTypeSize*(Index-1), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(Index-1))
    }
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
IArrayBlockBase_Enumerator(this, NumberOfVars, ByRef Key, ByRef Value := "")
{
    if (A_Index > this.Capacity)
        return 0  ; Break.
    if (NumberOfVars == 1)
        Key := NumGet(this, this.ValueTypeSize*(A_Index-1), this.ValueType)
    else Key   := A_Index
       , Value := NumGet(this, this.ValueTypeSize*(A_Index-1), this.ValueType)
    return -1  ; Continue.
}

ArrayBlock(Type, Values*)
{
    if (Type(Type) == "String")
        return IArrayBlockBase.New(Type, Values.Length, Values)  ; ArrayBlock("TypeName", Value1, Value2, ...)
    return IArrayBlockBase.New(Values[1], Type)                  ; ArrayBlock(Capacity, "TypeName")
}
