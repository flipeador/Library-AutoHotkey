QPC(R := 0)
{
    static Frequency := 0, P := 0
         ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644905(v=vs.85).aspx
         , PC := DllCall("Kernel32.dll\QueryPerformanceFrequency", "Int64P", Frequency)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644904(v=vs.85).aspx
    return !DllCall("Kernel32.dll\QueryPerformanceCounter", "Int64P", PC) + (R ? (P := PC) / Frequency : (PC - P) / Frequency) 
}
