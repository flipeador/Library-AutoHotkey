/*
    Copia bytes entre dos bloques de memoria.
    Parámetros:
        Source  : Un puntero al bloque de memoria del que copiar.
        Size    : El número de bytes en el bloque de memoria especificado en «Source» a copiar.
        Dest    : Un puntero al bloque de memoria en el que copiar (destino).
        DestSize: El tamaño del bloque de memoria especificado en «Dest», en bytes. Este parámetro es opcional.
    Return:
        Devuelve cero si se ejecuta correctamente; devuelve un código de error si se produce un error.
    Ejemplo:
        String := "Hola Mundo!"
        Size   := StrLen(String) * 2
        VarSetCapacity(Dest, Size, 0)
        CopyMemory(&String, Size, &Dest)
        MsgBox(StrGet(&Dest, Size, "UTF-16"))
*/
CopyMemory(Source, Size, Dest, DestSize := 0)
{
    Return DllCall("msvcrt.dll\memcpy_s", "UPtr", Dest, "UPtr", DestSize ? DestSize : Size, "UPtr", Source, "UPtr", Size, "Cdecl")
} ;https://msdn.microsoft.com/es-ar/library/wes2t00f.aspx
