#Include ..\IUIAutomation.ahk

/*
    Recupera el texto en las coordenadas especificadas en la pantalla.
    Parámetros:
        X: La coordenada X.
        Y: La coordenada Y.
    Parámetros:
        -1: No se ha podido inicializar el objeto UIA.
         0: No se ha encontrado ningún texto en las coordenadas especificadas.
    Ejemplo:
        CoordMode('Mouse', 'Screen')
        Loop
        {
            If (GetKeyState('ESC')) ;ESC = Exit
                ExitApp

            MouseGetPos(X, Y), R := ''
            For Each, String in GetScreenText(X, Y)
                R .= String . '`n'
            ToolTip(R, 0, 0)
            Sleep(500)
        }
*/
GetScreenText(X, Y)
{
    UIA     := IUIAutomation()
    Element := UIA.ElementFromPoint(X, Y)
    R       := []

    If ((Name := Element.CurrentName()) != '')
        R.Push(Name)

    For Each, Value in [30045, 30092, 30093]
    {
        If (Variant := Element.GetCurrentPropertyValue(Value))
            If ((String := Variant.String) != '')
                R.Push(String)
    }

    R2 := []
    For k, v in R
    {
        n := 0
        For k2, v2 in R2
            If (v2 == v)
                n := 1
        If (!n)
            R2.Push(v)
    }


    Return (R2)
}