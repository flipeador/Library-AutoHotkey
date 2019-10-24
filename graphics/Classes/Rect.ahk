#Include ArrayBlock.ahk





/*
    A IRectBase object describes a rectangle.
*/
class IRectBase extends IArrayBlockBase
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Unit := 0  ; Indicates the unit of measure for the rectangle.


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the X coordinate of the upper-left corner of the rectangle at the specified pair index in this object.
    */
    X[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1)), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1)))
    }

    Left[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1)), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1)))
    }

    L[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1)), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1)))
    }

    /*
        Gets or sets the Y coordinate of the upper-left corner of the rectangle at the specified pair index in this object.
    */
    Y[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+this.ValueTypeSize)
    }

    Top[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+this.ValueTypeSize)
    }

    T[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+this.ValueTypeSize)
    }

    /*
        Gets or sets the width at the specified pair index in this object.
    */
    Width[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize)
    }

    W[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize)
    }

    /*
        Gets the X coordinate of the lower-right corner of the rectangle at the specified pair index in this object.
    */
    Right[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize)
    }

    R[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+2*this.ValueTypeSize)
    }

    /*
        Gets or sets the height at the specified pair index in this object.
    */
    Height[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize)
    }

    H[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize)
    }

    /*
        Gets Y coordinate of the lower-right corner of the rectangle at the specified pair index in this object.
    */
    Bottom[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize)
    }

    B[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(4*(Index-1))+3*this.ValueTypeSize)
    }

    /*
        Gets the number of pairs of rectangles in this object.
    */
    Length[] => this.Capacity // 4
}


/*
    Integer pair.
*/
class IRect extends IRectBase
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
        this.InitBuff(IRect.DataType, Capacity, Values)
    }
}


/*
    Floating point pair.
*/
class IRectF extends IRectBase
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
        this.InitBuff(IRectF.DataType, Capacity, Values)
    }
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
Rect(Values*)
{
    return IRect.New(Values.Length?Values.Length+Mod(Values.Length,4):4, Values)
}

RectAlloc(Count)
{
    return IRect.New(4*Count)
}

ToRect(RectF)
{
    if !(RectF is IRectF)
        return RectF
    local Rect := IRect.New(RectF.Capacity)
    loop (Rect.Capacity)
        NumPut("Int", NumGet(RectF,4*(A_Index-1),"Float"), Rect, 4*(A_Index-1))
    return Rect
}

RectF(Values*)
{
    return IRectF.New(Values.Length?Values.Length+Mod(Values.Length,4):4, Values)
}

RectFAlloc(Count)
{
    return IRectF.New(4*Count)
}

ToRectF(Rect)
{
    if !(Rect is IRect)
        return Rect
    local RectF := IRectF.New(Rect.Capacity)
    loop (RectF.Capacity)
        NumPut("Float", NumGet(Rect,4*(A_Index-1),"Int"), RectF, 4*(A_Index-1))
    return RectF
}
