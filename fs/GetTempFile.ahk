/*
    Recupera un archivo temporal. Ningún archivo es creado por esta función.
    Parámetros:
        DirName : El directorio donde se ubicará el archivo. Si el directorio no existe, se utiliza A_Temp.
        Prefix  : La cadena de prefijo. Esta cadena se añadirá al comienzo del nombre del archivo.
        Unique  : Valor entero para ser utilizado en la creación del nombre de archivo temporal.
                  Si este valor es cero, la función intenta formar un nombre de archivo único usando la hora del sistema actual (A_Now).
                  Si el archivo ya existe, el número se incrementa en uno y las funcion prueba si este archivo ya existe. Esto continúa hasta que se encuentre un nombre de archivo único.
    Return:
        Devuelve una cadena con la ruta al archivo.
*/
GetTempFile(DirName := "", Prefix := "", Unique := 0)
{
    DirName  := DirExist(DirName) ? DirName : A_Temp
    Unique   := Unique == 0 ? A_Now : Unique

    Local FileName
    Loop
        FileName := DirName . "\" . Prefix . Unique++ . ".TMP"
    Until (!FileExist(FileName))

    Return FileName
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa364991(v=vs.85).aspx





/*
    Recupera un objeto de archivo temporal válido para escribir en él.
    Parámetros:
        FileName: Recibe una cadena con la ruta al archivo.
        DirName : El directorio donde crear el nuevo archivo. Si el directorio no existe, se utiliza A_Temp.
        Prefix  : La cadena de prefijo. Esta cadena se añadirá al comienzo del nombre del archivo.
        Unique  : Valor entero para ser utilizado en la creación del nombre de archivo temporal.
                  Si este valor es cero, la función intenta formar un nombre de archivo único usando la hora del sistema actual (A_Now).
                  Si el archivo ya existe, el número se incrementa en uno y las funcion prueba si este archivo ya existe. Esto continúa hasta que se encuentre un nombre de archivo único.
        Content : Especifica el contenido del archivo. Este parámetro puede ser un Array [pData, Size].
    Return:
        Devuelve un objeto de archivo con permiso de escritura. El objeto devuelto no comparte ningún acceso (lectura, escritura, eliminación).
    Ejemplo:
        MsgBox(GetTempFileObj(FileName, A_Desktop,,, "Hola Mundo!") . FileName)
*/
GetTempFileObj(ByRef FileName := "", DirName := "", Prefix := "", Unique := 0, Content := "")
{
    DirName  := DirExist(DirName) ? DirName : A_Temp
    Unique   := Unique == 0 ? A_Now : Unique

    Local FileObj
    Loop
        FileName := DirName . "\" . Prefix . Unique++ . ".TMP"
    Until (!FileExist(FileName) && (FileObj := FileOpen(FileName, "w-rwd", "UTF-16")))

    If (IsObject(Content))
        FileObj.Seek(0), FileObj.Length := 0, FileObj.RawWrite(Content[1], Content[2])
    Else If (Content != "")
        FileObj.Write(Content)

    Return (FileObj)
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa364991(v=vs.85).aspx
