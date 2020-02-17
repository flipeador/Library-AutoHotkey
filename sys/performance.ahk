/*
    Provides high-resolution interval measurements.
    Parameters:
        Value:
            FALSE    Returns the number of seconds elapsed since last reset.
            TRUE     Resets the counter and returns the number of seconds since the computer was rebooted.
    Return value:
        The return value depends on the value specified in parameter «Value».
*/
QPC(Value)
{
    static PC := 0, P := 0
    static Freq := QueryPerformanceFrequency()
    ; If the function succeeds, the return value is nonzero.
    ; On systems that run Windows XP or later, the function will always succeed and will thus never return zero.
    return DllCall("Kernel32.dll\QueryPerformanceCounter", "UInt64P", PC)
         ? (Value ? (P := PC) / Freq : (PC - P) / Freq)  ; Ok.
         : 0                                             ; Error.
    ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4437&p=24963
} ; https://docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter





/*
    Retrieves the frequency of the performance counter.
    The frequency of the performance counter is fixed at system boot and is consistent across all processors.
    Therefore, the frequency need only be queried upon application initialization, and the result can be cached.
    Return value:
        Returns the current performance-counter frequency, in counts per second.
*/
QueryPerformanceFrequency()
{
    local Frequency := 0
    ; If the installed hardware supports a high-resolution performance counter, the return value is nonzero.
    ; On systems that run Windows XP or later, the function will always succeed and will thus never return zero.
    DllCall("Kernel32.dll\QueryPerformanceFrequency", "UInt64P", Frequency)
    return Frequency
} ; https://docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancefrequency
