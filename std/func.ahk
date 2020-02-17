GetFuncObj(Function)
{
    try Function := IsObject(Function) ? Function : Func(Function)
    return (Type(Function) ~= "^Func|BoundFunc$")
         ? Function
         : 0
}
