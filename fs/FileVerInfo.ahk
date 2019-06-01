/*
    Retrieves version information for the specified file.
    Parameters:
        FileName:
            The name of the file of interest.
        PropName:
            The version information strings to be recovered, separated by '|'.
            If only one string is specified (there's no '|'), the function returns a string.
    Return value:
        If the function succeeds, the return value is an object with the properties requested; only those that exist are included.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
FileGetVerInfo(FileName, PropName)
{
    local

    if Arr := VerQueryValue(GetFileVersionInfo(FileName), "\VarFileInfo\Translation")  ; A little cryptic ...
        Loop Parse, (Arr.LangCP:=VerEnumTranslation(Arr,-4))&&PropName, (VerInfo:={})&&"|"
            if String := VerQueryValue(Arr.Buffer, Format("\StringFileInfo\{}\{}",Arr.LangCP,A_LoopField))
                VerInfo[A_LoopField] := StrGet(String.Ptr, String.Size, "UTF-16")  ; ...

    return Arr ? (InStr(PropName,"|")||!VerInfo.HasKey(PropName)?VerInfo:VerInfo[PropName]) : 0
}





/*
    Retrieves version information for the specified file.
    Parameters:
        FileName:
            The name of the file of interest.
    Return value:
        If the function succeeds, the return value is a Buffer object that contains the file-version information.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
GetFileVersionInfo(FileName, Flags := 0x00000001)
{
    local

    ; GetFileVersionInfoSizeExW function.
    ; https://docs.microsoft.com/es-es/windows/desktop/api/winver/nf-winver-getfileversioninfosizeexw.
    if Size := DllCall("Version.dll\GetFileVersionInfoSizeExW",  "UInt", Flags      ; dwFlags.
                                                              ,  "UPtr", &FileName  ; lpwstrFilename.
                                                              , "UIntP", 0)         ; lpdwHandle (not used).

        ; GetFileVersionInfoExW function.
        ; https://docs.microsoft.com/es-es/windows/desktop/api/winver/nf-winver-getfileversioninfoexw.
        if DllCall("Version.dll\GetFileVersionInfoExW", "UInt", Flags                       ; dwFlags.
                                                      , "UPtr", &FileName                   ; lpwstrFilename.
                                                      , "UInt", 0                           ; dwHandle (ignored).
                                                      , "UInt", Size                        ; dwLen.
                                                      ,  "Ptr", Buffer:=BufferAlloc(Size))  ; lpData.
            return Buffer

    return 0
}





/*
    Retrieves specified version information from the specified version-information resource.
    Parameters:
        Buffer:
            The version-information resource returned by the GetFileVersionInfo function.
            This parameter can be an address or a Buffer object.
        BlockName:
            The version-information value to be retrieved.
            The string must consist of names separated by backslashes and it must have one of the following forms.
            \                                                VS_FIXEDFILEINFO structure.
            \VarFileInfo\Translation                         Array of one or more values (4B) that are language and code page identifier pairs.
            \StringFileInfo\lang-codepage\string-name        String specific to the language and code page indicated.
    Return value:
        If the function succeeds, the return value is an object with the keys: 'Ptr', 'Size' and 'Buffer'. 'Buffer' is the value passed in «Buffer».
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
    Remarks:
        For version information values (\StringFileInfo), the Size is in characters. Use: StrGet(Obj.Ptr,Obj.Size,"UTF-16").
        Because the VerQueryValueW function releases the returned buffer when «Buffer» is released, «Buffer» is stored in the 'Buffer' key of the returned object (only valid if «Buffer» is a Buffer object).
*/
VerQueryValue(Buffer, BlockName)
{
    local

    if (Buffer && (!IsObject(Buffer) || Buffer.Ptr))  ; Ensure that the address (pBlock) is not zero, otherwise VerQueryValueW can throw an exception.
        ; VerQueryValueW function.
        ; https://docs.microsoft.com/es-es/windows/desktop/api/winver/nf-winver-verqueryvaluew.
        if DllCall("Version.dll\VerQueryValueW",   "Ptr", Buffer         ; pBlock.
                                               ,  "UPtr", &BlockName     ; lpSubBlock.
                                               , "UPtrP", pBuffer := 0   ; *lplpBuffer.
                                               , "UIntP", Size    := 0)  ; puLen.
            return { Ptr:pBuffer , Size:Size , Buffer:Buffer }
        ; The memory pointed to by lplpBuffer is freed when the associated pBlock memory is freed.
    return 0
}





VerEnumTranslation(Array, Size := 0)  ; Boring to explain xD.
{
    local Result := [], S := !Size && IsObject(Array) ? Array.Size : Abs(Size)
    if (Mod(S,4))
        throw Exception("VerEnumTranslation function, invalid parameter #2.", -1)
    if (!Array || (IsObject(Array) && !Array.Ptr) || !S)
        return 0
    loop (S // 4)
        Result.Push(Format("{:04X}{:04X}",NumGet(Array,4*(A_Index-1),"UShort"),NumGet(Array,4*(A_Index-1)+2,"UShort")))
    return Size < 0 ? Result[Abs(Size)//4] : Result
}





/*
FileVersion := FileGetVerInfo(A_ComSpec, "FileVersion")
VerInfo     := FileGetVerInfo(A_ComSpec, "FileDescription|CompanyName")
MsgBox(Format("FileName: {}`nFileVersion: {}`nFileDescription: {}`nCompanyName: {}",A_ComSpec,FileVersion,VerInfo.FileDescription,VerInfo.CompanyName))
*/
