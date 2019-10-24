#Include ArrayBlock.ahk





/*
    A ISizeBase object stores 32-bit values that represents an ordered pair of integers, typically the width and height of a rectangle.
*/
class ISizeBase extends IArrayBlockBase
{
    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the width at the specified pair index in this object.
    */
    Width[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(2*(Index-1)), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(2*(Index-1)))
    }

    W[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(2*(Index-1)), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(2*(Index-1)))
    }

    /*
        Gets or sets the height at the specified pair index in this object.
    */
    Height[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(2*(Index-1))+this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(2*(Index-1))+this.ValueTypeSize)
    }

    H[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(2*(Index-1))+this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(2*(Index-1))+this.ValueTypeSize)
    }

    /*
        Gets the number of pairs of integers in this object.
    */
    Length[] => this.Capacity // 2
}


/*
    Integer pair.
*/
class ISize extends ISizeBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static DataType := "Int"


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Capacity, Values := 0)
    {
        this.InitBuff(ISize.DataType, Capacity, Values)
    }
}


/*
    Floating point pair.
*/
class ISizeF extends ISizeBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static DataType := "Float"


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Capacity, Values := 0)
    {
        this.InitBuff(ISizeF.DataType, Capacity, Values)
    }
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
/*
    Creates a ISize object and initializes it with the specified pairs of integers.
    Parameters:
        Points:
            The pairs of integers with which to initialize this object.
    Return value:
        Returns a ISize object.
*/
Size(Values*)
{
    return ISize.New(Values.Length?Values.Length+Mod(Values.Length,2):2, Values)
}

/*
    Creates a ISize object with enough space to store the specified number of pairs of integers.
    Parameters:
        Count:
            Specifies the number of pairs of integers that the object should be able to store.
    Return value:
        Returns a ISize object.
*/
SizeAlloc(Count)
{
    return ISize.New(2*Count)
}

/*
    Converts a ISizeF object to a ISize object, if necessary.
*/
ToSize(SizeF)
{
    if !(SizeF is ISizeF)
        return SizeF
    local Size := ISize.New(SizeF.Capacity)
    loop (Size.Capacity)
        NumPut("Int", NumGet(SizeF,4*(A_Index-1),"Float"), Size, 4*(A_Index-1))
    return Size
}

/*
    Creates a ISizeF object and initializes it with the specified pairs of integers.
    Parameters:
        Points:
            The pairs of integers with which to initialize this object.
    Return value:
        Returns a ISizeF object.
*/
SizeF(Values*)
{
    return ISizeF.New(Values.Length?Values.Length+Mod(Values.Length,2):2, Values)
}

/*
    Creates a ISizeF object with enough space to store the specified number of pairs of integers.
    Parameters:
        Count:
            Specifies the number of pairs of integers that the object should be able to store.
    Return value:
        Returns a ISizeF object.
*/
SizeFAlloc(Count)
{
    return ISizeF.New(2*Count)
}

/*
    Converts a ISize object to a ISizeF object, if necessary.
*/
ToSizeF(Size)
{
    if !(Size is ISize)
        return Size
    local SizeF := ISizeF.New(Size.Capacity)
    loop (SizeF.Capacity)
        NumPut("Float", NumGet(Size,4*(A_Index-1),"Int"), SizeF, 4*(A_Index-1))
    return SizeF
}
