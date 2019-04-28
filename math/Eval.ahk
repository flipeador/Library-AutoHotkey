/*
    Evalúa una expresión en una cadena.
    Parámetros:
        Expr:
            La cadena con la expresión a evaluar.
        Format:
            Si es verdadero, formatea valores en notación científica a coma flotante.
    Observaciones:
        Las constantes deben especificarse en mayúscula.
    Referencia:
        https://www.w3schools.com/jsref/jsref_obj_math.asp
    Ejemplo:
        MsgBox Eval("PI") . "`n" . Eval("2>3") . "`n" . Eval("3>2") . "`n" . Eval("abs(-100)*2+50") . "`n" . Eval("143**143")
*/
Eval(Expr, Format := FALSE)
{
    static obj := 0    ; por cuestiones de rendimiento
    if ( !obj )
        obj := ComObjCreate("HTMLfile")

    Expr := StrReplace( RegExReplace(Expr, "\s") , ",", ".")
  , Expr := RegExReplace(StrReplace(Expr, "**", "^"), "(\w+(\.*\d+)?)\^(\w+(\.*\d+)?)", "pow($1,$3)")    ; 2**3 -> 2^3 -> pow(2,3)
  , Expr := RegExReplace(Expr, "=+", "==")    ; = -> ==  |  === -> ==  |  ==== -> ==  |  ..
  , Expr := RegExReplace(Expr, "\b(E|LN2|LN10|LOG2E|LOG10E|PI|SQRT1_2|SQRT2)\b", "Math.$1")
  , Expr := RegExReplace(Expr, "\b(abs|acos|asin|atan|atan2|ceil|cos|exp|floor|log|max|min|pow|random|round|sin|sqrt|tan)\b\(", "Math.$1(")

  , obj.write("<body><script>document.body.innerText=eval('" . Expr . "');</script>")
  , Expr := obj.body.innerText

    return InStr(Expr, "d") ? "" : InStr(Expr, "false") ? FALSE    ; d = body | undefined
                                 : InStr(Expr, "true")  ? TRUE
                                 : ( Format && InStr(Expr, "e") ? Format("{:f}",Expr) : Expr )
} ; CREDITS (tidbit) - https://autohotkey.com/boards/viewtopic.php?f=6&t=15389
