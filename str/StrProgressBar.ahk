StrProgressBar(Current, Max := 100, Length := 100, Char := "|")
{
    local Percent := (Current / Max) * 100, Progress := ""
    Percent := Percent > 100 ? 100 : Percent < 0 ? 0 : percent
    loop (Round(((Percent / 100) * Length)))
        Progress .= Char
    loop (Length - Round(((Percent / 100) * Length)))
        Progress .= A_Space
    return { Progress:Progress , Percent:Percent }
} ; https://autohotkey.com/boards/viewtopic.php?f=6&t=100





/*
Loop 20
{
    PB1 := StrProgressBar(A_Index, 20)
    Loop 100
    {
        PB2 := StrProgressBar(A_Index)
        ToolTip "[" . PB2.Progress . "] " . Round(PB2.Percent,2) . " %.`n"
              . "[" . PB1.Progress . "] " . Round(PB1.Percent,2) . " %."
        Sleep Random(0, Random(0,10)==5?(Mod(PB1.Percent,10)?125:255):0)
    }
}
*/
