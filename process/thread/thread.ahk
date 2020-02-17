/*
    Suspends the specified thread.
    Parameters:
        hThread:
            A handle to the thread that is to be suspended.
            The handle must have the THREAD_SUSPEND_RESUME access right.
    Return value:
        If the function succeeds, the return value is the thread's previous suspend count.
        If the function fails, the return value is -1. A_LastError contains extended error information.
*/
ThreadSuspend(hThread)
{
    return DllCall("Kernel32.dll\SuspendThread", "Ptr", hThread)
} ; https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-suspendthread

Wow64ThreadSuspend(hThread)
{
    return DllCall("Kernel32.dll\Wow64SuspendThread", "Ptr", hThread)
} ; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-wow64suspendthread





/*
    Decrements a thread's suspend count. When the suspend count is decremented to zero, the execution of the thread is resumed.
    Parameters:
        hThread:
            A handle to the thread to be restarted.
            This handle must have the THREAD_SUSPEND_RESUME access right.
    Return value:
        If the function succeeds, the return value is the thread's previous suspend count.
        If the function fails, the return value is -1. A_LastError contains extended error information.
*/
ThreadResume(hThread)
{
    return DllCall("Kernel32.dll\ResumeThread", "Ptr", hThread)  ; 0xFFFFFFFF.
} ; https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-resumethread
