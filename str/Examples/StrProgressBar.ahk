#Include ..\format.ahk





loop 20
{
    PB1 := StrProgressBar(A_Index, 20)
    loop 100
    {
        PB2 := StrProgressBar(A_Index)
        ToolTip "[" . PB2.Progress . "] " . Round(PB2.Percent,2) . " %.`n"
              . "[" . PB1.Progress . "] " . Round(PB1.Percent,2) . " %."
        sleep Random(0, Random(0,10)==5?(Mod(PB1.Percent,10)?125:255):0)
    }
}
