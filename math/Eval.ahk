/*
    Evaluates a math operation in the specified string.
    Parameters:
        Expr:
            The string with the expression to be evaluated.
        Default:
            The default value to return if the function fails. Default is an empty string.
    Return value:
        The return value is a string with the result.
        The result of a boolean expression is TRUE or FALSE (integer).
    Remarks:
        Constants must be specified in upper case.
    Reference:
        https://www.w3schools.com/jsref/jsref_obj_math.asp
*/
Eval(Expr, Default := "")
{
    static doc := ComObjCreate("HTMLFile")

    doc.write("<body><script>document.body.innerText=eval('" . RegExReplace(RegExReplace(RegExReplace(RegExReplace(StrReplace(StrReplace(RegExReplace(Expr
    ,"\s"),",","."),"**","^"),"(\w+(\.*\d+)?)\^(\w+(\.*\d+)?)","pow($1,$3)"),"=+","=="),"\b(E|LN2|LN10|LOG2E|LOG10E|PI|SQRT1_2|SQRT2)\b","Math.$1")
    ,"\b(abs|acos|asin|atan|atan2|ceil|cos|exp|floor|log|max|min|pow|random|round|sin|sqrt|tan)\b\(","Math.$1(") . "');</script>"), Expr:=doc.body.innerText

    return Expr == "false"                       ? FALSE  ; (Integer)  0 (FALSE).
         : Expr == "true"                        ? TRUE   ; (Integer)  1 (TRUE).
         : RegExReplace(Expr,"[\d\.e\+]") == ""  ? Expr   ; (String)  "" (OK).
         : Default                                        ; (String)  "" (ERROR).
} ; CREDITS (tidbit) - https://autohotkey.com/boards/viewtopic.php?f=6&t=15389





/*
MsgBox  Eval("PI")          ; (String)  3.141592653589793 = ACos(-1).
MsgBox  Eval("2>3")         ; (Integer) 0 (FALSE).
MsgBox  Eval("3>2")         ; (Integer) 1 (TRUE).
MsgBox  Eval("abs(-100)")   ; (String)  100.
MsgBox  Eval("143**143")    ; (String)  1.6332525972973913e+308.
MsgBox  Eval("", "Error!")  ; (String)  Error.
*/
