StrRepeat(ByRef String, Count)
{
    return StrReplace(Format("{:" . Count . "}", ""), A_Space, String)
}





/*
    Expands %variables% in the specified string.
    Parameters:
        String:
            A string in which to perform the operation.
        VarList:
            A Map object containing variables to be expanded.
            Variables that are not included in the object will not be replaced.
    Return value:
        The return value is a string.
*/
StrExpandVar(String, VarList)
{
    local

    Needle := "%(\w*)%", Pos := 1
    while Pos := RegExMatch(String, Needle, Output, Pos)
    {
        if (HasKey := VarList.HasKey(VarName:=Trim(Output[0],"%")))
            String := RegExReplace(String, Needle, VarList[VarName],, 1, Pos)
        Pos += StrLen(HasKey ? VarList[VarName] : Output[0])
    }

    return String
}





/*
    Loads a string resource from the executable file associated with a specified module.
    Parameters:
        Instance:
            A handle to an instance of the module whose executable file contains the string resource.
            To get the handle to the application itself, call the GetModuleHandle function with zero.
        Identifier:
            The identifier of the string to be loaded.
        Buffer:
            The buffer to receive the string. This parameter must be an integer or a Buffer object.
            If this parameter is non-zero, the function returns the number of characters copied into the buffer, not including the terminating null character.
        Length:
            The size of the buffer, in characters, including the null-terminated character.
            The string is truncated and null-terminated if it is longer than the number of characters specified.
            This parameter is ignored if «Buffer» is set to zero. If «Buffer» is a Buffer object, this parameter can be omitted.
    Return value:
        Returns an object with properties Instance, ID, Ptr, Str, Length and Size.
        If the string resource does not exist, 'Length' is zero.
    Remarks:
        Resource tables can contain null characters. String resources are stored in blocks of 16 strings, and any empty slots within a block are indicated by null characters.
*/
StrLoad(Instance, Identifier, Buffer := 0, Length := -1)
{
    local

    if (Buffer)
        return DllCall("User32.dll\LoadStringW", "Ptr", Instance, "UInt", Abs(Identifier), "Ptr", Buffer, "Int", Length<0?Buffer.Size//2:Length)
    Length := DllCall("User32.dll\LoadStringW", "Ptr", Instance, "UInt", Abs(Identifier), "PtrP", Ptr:=0, "Int", 0)

    return { Instance: Instance , ID  : Identifier
           , Ptr     : Ptr      , Str : Ptr ? StrGet(Ptr,Length) : ""
           , Length  : Length   , Size: 2 * Length                    }

} ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-loadstringw





/*
    Reads a localized string. A Localized String has the following format: '@[Path\]DllName,-Identifier'.
*/
StrLoadLocalized(DllName, Identifier := "")
{
    if (Identifier == "")
    {
        Identifier := SubStr(DllName, InStr(DllName,",",,-1)+1)
        DllName    := LTrim(SubStr(DllName,1,InStr(DllName,",",,-1)-1), "@")
        DllName    := InStr(DllName,":") ? DllName : StrReplace(DllName,"%SystemRoot%",A_WinDir,,1)
    }

    local Result := StrLoad(DllCall("Kernel32.dll\LoadLibraryW","Ptr",&DllName,"Ptr"), Identifier)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", Result.Instance)
    return Result.Str
}
