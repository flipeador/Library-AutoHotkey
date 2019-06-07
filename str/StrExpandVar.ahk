/*
    Expands %variables% in the specified string.
    Parameters:
        String:
            A string in which to perform the operation.
        VarList:
            A Map object (associative array) with the variables to be expanded.
            Variables that are not included in the object will not be replaced.
    Return value:
        Return the formatted string.
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
VarList := {var2:"VAR2" , "":"EMPTY" , var3:"VAR3"}
String  := "%var1% 111 %var2% 222 %% 333 %var3% 444 %var4%"
MsgBox(Format("Original:`n{1}`n`nNew:`n{2}",String,StrExpandVar(String,VarList)))
*/
