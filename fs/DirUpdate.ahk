/*
    Actualiza los archivos de un directorio comparando la fecha de modificación con los archivos de otro directorio.
    Parámetros:
        Source: El directorio con los archivos actualizados.
        Dest  : El directorio que se va a actualizar.
        Flag  : Determina el comportamiento de la función. Puede especificar una o más de las siguientes letras.
            D = Indica que todos los archivos que no existan en «Source» serán eliminados de «Dest». Los archivos omitidos no serán eliminados.
            R = Indica que se deben actualizar también los archivos archivos ubicados en sub-directorios de «Dest».
            I = En caso de que la fecha de moficiación de un archivo en «Dest» sea más reciente que el archivo en «Source», ignora el archivo en «Dest» y no lo sobre-escribe.
                Si no se especifica, la función por defecto sobre-escribe cualquier archivo en «Dest» si la fecha de modificación no es la misma que en «Source».
            T = Modo texto (sensible a mayúsculas y minúsculas). La función solo actualiza los archivos si el contenido de los archivos no es el mismo. Si se especifica, la opción «I» se ignora.
        Skip  : Especifica un array con los archivos a omitir (ruta parcial). La ruta de los archivos especificados es relativa a «Dest». Por ejemplo "folder\file.txt" -> "%Dest%\folder\file.txt".
                Si el archivo especificado no existe en «Dest» pero si en «Source», el archivo no será creado.
    Return:
        -1 = El directorio especificado en «Source» no existe.
        -2 = El directorio especificado en «Dest» no existe.
        {} = Devuelve un objeto con la información de la actualización. Este objeto tendrá las siguientes claves.
            DeletedFiles  = Un array con los archivos eliminados. Estos archivos pertenecen a «Dest».
            DeletedFilesE = Un array con los archivos que no han podido ser eliminados. Estos archivos pertenecen a «Dest».
            CopiedFiles   = Un array con los archivos modificados (copiados y sobre-escritos). Estos archivos pertenecen a «Source».
            CopiedFilesE  = Un array con los archivos que no han podido ser modificados. Estos archivos pertenecen a «Source».
            CreatedFiles  = Un array con los archivos creados, esto es, existen en «Source» pero no en «Dest». Estos archivos pertenecen a «Dest».
            CreatedFilesE = Un array con los archivos que no han podido ser creados. Estos archivos pertenecen a «Dest».
            SkippedFiles  = Un array con los archivos omitidos (ya están actualizados). Estos archivos pertenecen a «Dest».
            Count         = La cantidad de archivos leídos. Incluye tanto archivos de «Source» (que fueron creados en «Dest») como de «Dest».
    Observaciones:
        Esta función no modifica de ninguna manera los archivos especificados en «Source». Solo actúa sobre «Dest».
    Ejemplo:
        MsgBox !(Ret := DirUpdate(A_Desktop . "\a", A_Desktop . "\b", "DR")) ? "ERROR #" . Ret : "CopiedFiles: " . Ret.CopiedFiles.Length()
                                                                                               . "`nCopiedFilesE: " . Ret.CopiedFilesE.Length()
                                                                                               . "`nDeletedFiles: " . Ret.DeletedFiles.Length()
                                                                                               . "`nDeletedFilesE: " . Ret.DeletedFilesE.Length()
                                                                                               . "`nSkippedFiles: " . Ret.SkippedFiles.Length()
                                                                                               . "`nCreatedFiles: " . Ret.CreatedFiles.Length()
                                                                                               . "`nCreatedFilesE: " . Ret.CreatedFilesE.Length()
                                                                                               . "`nCount: " . Ret.Count
*/
DirUpdate(Source, Dest, Options := "", Skip := "")
{
    If (!DirExist(Source))
        Return -1
    If (!DirExist(Dest))
        Return -2

    Source := RTrim(Source, "\"), Dest := RTrim(Dest, "\")
    Local Att := "", File := "", SrcF := ""
        , Pos := StrLen(Dest) + 2, Pos2 := StrLen(Source) + 2, DestFiles := {}
        , Ret := {DeletedFiles: [], DeletedFilesE: [], CopiedFiles: [], CopiedFilesE: [], SkippedFiles: [], CreatedFiles: [], CreatedFilesE: [], Count: 0}
        ,   D := InStr(Options, "D")
        ,   R := InStr(Options, "R")
        ,   I := InStr(Options, "I")
        ,   T := InStr(Options, "T")

    Loop Files, Dest . "\*.*", R ? "FR" : "F"
    {
        File := SubStr(A_LoopFileFullPath, Pos)
        If (IsObject(Skip))
        {
            Loop (ObjLength(Skip))
                If (Skip[A_Index] = File)
                {
                    ++Ret.Count, ObjPush(Ret.SkippedFiles, A_LoopFileFullPath), ObjRawSet(DestFiles, File, 0)
                    Continue 2    ; Loop Files
                }
        }
        Att  := FileExist(SrcF := Source . "\" . File)
        If (D && (!Att || InStr(Att, "D")))
            ObjPush(Ret[FileDelete(A_LoopFileFullPath) ? "DeletedFiles" : "DeletedFilesE"], A_LoopFileFullPath)
        Else If ((T && !(FileRead(SrcF) == FileRead(A_LoopFileFullPath))) || (!T && ((I && FileGetTime(SrcF) > FileGetTime(A_LoopFileFullPath)) || (!I && FileGetTime(SrcF) != FileGetTime(A_LoopFileFullPath)))))
            ObjPush(Ret[FileCopy(SrcF, A_LoopFileFullPath, TRUE) ? "CopiedFiles" : "CopiedFilesE"], SrcF)
        Else
            ObjPush(Ret.SkippedFiles, A_LoopFileFullPath)
        ++Ret.Count, ObjRawSet(DestFiles, File, 0)
    }

    ; creamos los archivos que no existan en «Dest» pero si en «Source»
    Loop Files, Source . "\*.*", R ? "FR" : "F"
    {
        File := SubStr(A_LoopFileFullPath, Pos2)
        If (!ObjHasKey(DestFiles, File))
        {
            File := Dest . "\" . File, SplitPath(File,, D), DirCreate(D)    ; nos aseguramos de que el directorio exista o de otro modo FileCopy falla
            ++Ret.Count, ObjPush(Ret[FileCopy(A_LoopFileFullPath, File) ? "CreatedFiles" : "CreatedFilesE"], File)
        }
    }

    Return Ret
}
