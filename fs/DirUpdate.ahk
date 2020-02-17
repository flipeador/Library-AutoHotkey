/*
    Updates files in one directory by comparing the modification date or the content with files in another directory.
    Parameters:
        Source:
            The directory containing the updated files.
        Dest:
            The directory containing the files to be updated.
        Flags:
            Determines the behavior of the function. You can specify a string containing any reasonable combination of the following letters.
            D   All files that doesn't exist in «Source» will be deleted from «Dest». Omitted files will not be deleted. By default no file is deleted in "Dest".
            R   Update also the files located in subdirectories of «Dest». By default only the top directory is updated.
            I   If the File modification date in «Dest» is more recent than that of the file in «Source», ignores the file in «Dest» and does not overwrite it.
                By default any file is overwritten in "Dest" if the modification date is not the same as in "Source".
            T   Text mode (case sensitive). Files are only updated if they differ in content. If specified, the "I" option is ignored.
        Skip:
            Specifies an array with the name of the files to omit, with relative path to "Dest".
            If the file does not exist in «Dest» but in «Source», the file will not be created.
    Return:
        -1   The directory specified in «Source» does not exist.
        -2   The directory specified in «Dest» does not exist.
        {}   Returns an object with the update information. This object will contain the following keys.
            DeletedFiles    An array with the files that have been deleted in «Dest»
            DeletedFilesE   An array with the files that couldn't be deleted in "Dest".
            CopiedFiles     An array with the copied and/or replaced files from «Source» to «Dest».
            CopiedFilesE    An array with files that could not be copied and/or replaced.
            CreatedFiles    An array with the files created in «Dest», that is, they exist in «Source» but not in «Dest».
            CreatedFilesE   An array with the files that couldn't be created in «Dest».
            SkippedFiles    An array with the omitted files (already updated) in "Dest".
            Count           The number of scanned files. It includes both «Source» files (which were created in «Dest») and «Dest» files.
*/
DirUpdate(Source, Dest, Flags := "", Skip := "")
{
    local

    if (!DirExist(Source))
        return -1

    if (!DirExist(Dest))
        return -2

    Source := RTrim(Source, "\")
    Dest   := RTrim(Dest  , "\")

    Pos1 := StrLen(Dest)   + 2
    Pos2 := StrLen(Source) + 2

    DestFiles := {}
    Result    := { DeletedFiles : []
                 , DeletedFilesE: []
                 , CopiedFiles  : []
                 , CopiedFilesE : []
                 , SkippedFiles : []
                 , CreatedFiles : []
                 , CreatedFilesE: []
                 , Count        : 0 }

    D := InStr(Flags, "D")
    R := InStr(Flags, "R")
    I := InStr(Flags, "I")
    T := InStr(Flags, "T")

    Loop Files, Dest . "\*.*", R ? "FR" : "F"
    {
        File := SubStr(A_LoopFileFullPath, Pos1)
        If (IsObject(Skip))
        {
            Loop (ObjLength(Skip))
                If (Skip[A_Index] = File)
                {
                    ++Result.Count, ObjPush(Result.SkippedFiles, A_LoopFileFullPath), ObjRawSet(DestFiles, File, 0)
                    Continue 2    ; Loop Files
                }
        }
        Att  := FileExist(SrcF := Source . "\" . File)
        If (D && (!Att || InStr(Att, "D")))
            ObjPush(Result[FileDelete(A_LoopFileFullPath) ? "DeletedFiles" : "DeletedFilesE"], A_LoopFileFullPath)
        Else If ((T && !(FileRead(SrcF) == FileRead(A_LoopFileFullPath))) || (!T && ((I && FileGetTime(SrcF) > FileGetTime(A_LoopFileFullPath)) || (!I && FileGetTime(SrcF) != FileGetTime(A_LoopFileFullPath)))))
            ObjPush(Result[FileCopy(SrcF, A_LoopFileFullPath, TRUE) ? "CopiedFiles" : "CopiedFilesE"], SrcF)
        Else
            ObjPush(Result.SkippedFiles, A_LoopFileFullPath)
        ++Result.Count, ObjRawSet(DestFiles, File, 0)
    }

    Loop Files, Source . "\*.*", R ? "FR" : "F"
    {
        File := SubStr(A_LoopFileFullPath, Pos2)
        If (!ObjHasKey(DestFiles, File))
        {
            File := Dest . "\" . File, SplitPath(File,, D), DirCreate(D)
            ++Result.Count, ObjPush(Result[FileCopy(A_LoopFileFullPath, File) ? "CreatedFiles" : "CreatedFilesE"], File)
        }
    }

    Return Result
}





/*
MsgBox(!(Ret := DirUpdate(A_Desktop . "\a", A_Desktop . "\b", "DR")) ? "ERROR #" . Ret : "CopiedFiles: "     . Ret.CopiedFiles.Length()
                                                                                       . "`nCopiedFilesE: "  . Ret.CopiedFilesE.Length()
                                                                                       . "`nDeletedFiles: "  . Ret.DeletedFiles.Length()
                                                                                       . "`nDeletedFilesE: " . Ret.DeletedFilesE.Length()
                                                                                       . "`nSkippedFiles: "  . Ret.SkippedFiles.Length()
                                                                                       . "`nCreatedFiles: "  . Ret.CreatedFiles.Length()
                                                                                       . "`nCreatedFilesE: " . Ret.CreatedFilesE.Length()
                                                                                       . "`nCount: "         . Ret.Count)
*/
