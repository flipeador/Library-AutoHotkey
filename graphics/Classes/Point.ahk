#Include ArrayBlock.ahk





/*
    A IPointBase object stores 32-bit values that represents an ordered pair of X and Y coordinates that defines a point in a two-dimensional plane.
*/
class IPointBase extends IArrayBlockBase
{
    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Gets or sets the X coordinate at the specified coordinate pair index in this IPointBase object.
    */
    X[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(2*(Index-1)), this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(2*(Index-1)))
    }

    /*
        Gets or sets the X coordinate at the specified coordinate pair index in this IPointBase object.
    */
    Y[Index := 1]
    {
        get => NumGet(this, this.ValueTypeSize*(2*(Index-1))+this.ValueTypeSize, this.ValueType)
        set => NumPut(this.ValueType, Value, this, this.ValueTypeSize*(2*(Index-1))+this.ValueTypeSize)
    }

    /*
        Gets the number of pairs of points in this IPointBase object.
    */
    Length[] => this.Capacity // 2
}


/*
    Integer coordinates.
*/
class IPoint extends IPointBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static DataType := "Int"


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Capacity, Points := 0)
    {
        this.InitBuff(IPoint.DataType, Capacity, Points)
    }
}


/*
    Floating point coordinates.
*/
class IPointF extends IPointBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static DataType := "Float"


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Capacity, Points := 0)
    {
        this.InitBuff(IPointF.DataType, Capacity, Points)
    }
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
/*
    Creates a IPoint object and initializes it with the specified coordinate pairs.
    Parameters:
        Points:
            The coordinate pairs with which to initialize this object.
    Return value:
        Returns a IPoint object.
*/
Point(Points*)
{
    return IPoint.New(Points.Length?Points.Length+Mod(Points.Length,2):2, Points)
}

/*
    Creates a IPoint object with enough space to store the specified number of coordinate pairs.
    Parameters:
        Count:
            Specifies the number of coordinate pairs that the object should be able to store.
    Return value:
        Returns a IPoint object.
*/
PointAlloc(Count)
{
    return IPoint.New(2*Count)
}

/*
    Converts a IPointF object to a IPoint object, if necessary.
*/
ToPoint(PointF)
{
    if !(PointF is IPointF)
        return PointF
    local Point := IPoint.New(PointF.Capacity)
    loop (Point.Capacity)
        NumPut("Int", NumGet(PointF,4*(A_Index-1),"Float"), Point, 4*(A_Index-1))
    return Point
}

/*
    Creates a IPointF object and initializes it with the specified coordinate pairs.
    Parameters:
        Points:
            The coordinate pairs with which to initialize this object.
    Return value:
        Returns a IPointF object.
*/
PointF(Points*)
{
    return IPointF.New(Points.Length?Points.Length+Mod(Points.Length,2):2, Points)
}

/*
    Creates a IPointF object with enough space to store the specified number of coordinate pairs.
    Parameters:
        Count:
            Specifies the number of coordinate pairs that the object should be able to store.
    Return value:
        Returns a IPointF object.
*/
PointFAlloc(Count)
{
    return IPointF.New(2*Count)
}

/*
    Converts a IPoint object to a IPointF object, if necessary.
*/
ToPointF(Point)
{
    if !(Point is IPoint)
        return Point
    local PointF := IPointF.New(Point.Capacity)
    loop (PointF.Capacity)
        NumPut("Float", NumGet(Point,4*(A_Index-1),"Int"), PointF, 4*(A_Index-1))
    return PointF
}
