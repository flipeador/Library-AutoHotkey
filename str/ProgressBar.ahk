/*
Loop 20
{
    PB1 := ProgressBar(A_Index, 20)
    Loop 100
    {
        PB2 := ProgressBar(A_Index)
        ToolTip "[" . PB2.Progress . "] " . PB2.Percent . " %.`n"
              . "[" . PB1.Progress . "] " . PB1.Percent . " %."
        Sleep Random(0, Random(0, 10) == 5 ? (Mod(PB1.Percent, 10) ? 125 : 255) : 0)
    }
}
*/
ProgressBar(Current, Max := 100, Length := 100, Char := "|")
{
    Local Percent := (Current / Max) * 100, Progress := ""
    Percent := Percent > 100 ? 100 : Percent < 0 ? 0 : percent
    Loop (Round(((Percent / 100) * Length)))
        Progress .= "|"
    Loop (Length - Round(((Percent / 100) * Length)))
        Progress .= A_Space
    Return {Progress: Progress, Percent: Round(Percent, 2)}
} ; https://autohotkey.com/boards/viewtopic.php?f=6&t=100
