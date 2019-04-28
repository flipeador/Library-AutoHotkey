/*
    Busca un valor en un Array y si lo encuentra devuelve la posición, de lo contrario devuelve 0
    Parámetros:
        Array        : El array en el se va a buscar el valor especificado en Value.
        Value        : El valor a buscar. Puede ser un número, una cadena u otro objeto.
        CaseSensitive: Determina si la búsqueda distingue entre mayúsculas y minúsculas. Por defecto es FALSE.
        Bottom       : La posición desde la cual empezar la búsqueda. Por defecto es 1, el principio del array.
        Top          : La posición hasta la cual buscar. Por defecto es 0, el final array.
    Return:
        0     = El valor especificado en Value no se ha encontrado en el Array.
        [int] = Si el valor se ha encontrado, devuelve su posición.
    Ejemplo:
        Arr := ['A', 'B', 'C', 'AB', 'AC', 'BC', 'ABC']
        MsgBox(Array_HasValue(Arr, 'A'))        ;1
        MsgBox(Array_HasValue(Arr, 'B'))        ;2
        MsgBox(Array_HasValue(Arr, 'ABC'))      ;7
        MsgBox(Array_HasValue(Arr, 'BC'))       ;6
        MsgBox(Array_HasValue(Arr, 'AB'))       ;4
        MsgBox(Array_HasValue(Arr, 'Ab', TRUE)) ;0
        MsgBox(Array_HasValue(Arr, 'ABC',, 7))  ;7
        MsgBox(Array_HasValue(Arr, 'A',, 2))    ;0
*/
Array_HasValue(Array, Value, CaseSensitive := FALSE, Bottom := 1, Top := 0)
{
    Local Length

    Length := Array.Length()
    Bottom := Bottom < 1 ?      1 : Bottom > Length ? Length : Bottom
    Top    := Top   == 0 ? Length : Top    < Bottom ? Bottom : Top    > Length ? Length : Top
    
    While (Top >= Bottom)
        If ((CaseSensitive && Array[Bottom++] == Value) || (!CaseSensitive && Array[Bottom++] = Value))
            Return (--Bottom)

    Return (0)
}




/*
    Elimina un valor en el array.
    Parámetros:
        Array: El array en el que se va a eliminar el valor. Este array es el modificado.
        Value: El valor a eliminar. Puede ser un número, una cadena u otro objeto.
        CaseSensitive: Determina si la búsqueda distingue entre mayúsculas y minúsculas. Por defecto es FALSE.
        Bottom       : La posición desde la cual empezar la búsqueda. Por defecto es 1, el principio del array.
        Top          : La posición hasta la cual buscar. Por defecto es 0, el final array.
        Limit        : El límite de valores a eliminar, si hay más de uno. Por defecto solo elimina uno, si lo hay. Especificar 0 para sin límite.
    Return:
        Devuelve el número de elementos eliminados, o cero si no se ha encontrado ningún elemento.
*/
Array_Delete(Array, Value, CaseSensitive := FALSE, Bottom := 1, Top := 0, Limit := 1)
{
    Local Length
        , n := 0

    Length := Array.Length()
    Bottom := Bottom < 1 ?      1 : Bottom > Length ? Length : Bottom
    Top    := Top   == 0 ? Length : Top    < Bottom ? Bottom : Top    > Length ? Length : Top
    
    While (Top >= Bottom)
    {
        If ((CaseSensitive && Array[Bottom] == Value) || (!CaseSensitive && Array[Bottom] = Value))
        {
            ObjRemoveAt(Array, Bottom)
            If (++n == Limit)
                Break
        }
        ++Bottom
    }

    Return (n)
}
