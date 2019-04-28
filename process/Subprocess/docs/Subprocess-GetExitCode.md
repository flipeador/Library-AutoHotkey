# Subprocess::GetExitCode method

Retrieves the termination status of the child process.




### Syntax

```
int GetExitCode()
```




### Return value

If the method succeeds, the return value is the process termination status. For more information, see Remarks.

If the method fails, the return value is `-1`. To get extended error information, check `A_LastError`.




### Remarks

This function returns immediately. If the process has not terminated and the function succeeds, the status returned is `STILL_ACTIVE`. If the process has terminated and the function succeeds, the status returned is one of the following values:

- The exit value specified in the [ExitProcess](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-exitprocess) or [TerminateProcess](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-terminateprocess) function.
- The return value from the [main](https://docs.microsoft.com/en-us/cpp/cpp/main-program-startup?view=vs-2019) or [WinMain](https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-winmain) function of the process.
- The exception value for an unhandled exception that caused the process to terminate.

**Important**: The [GetExitCodeProcess](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-getexitcodeprocess) function returns a valid error code defined by the application only after the thread terminates. Therefore, an application should not use `STILL_ACTIVE` (259) as an error code. If a thread returns `STILL_ACTIVE` as an error code, applications that test for this value could interpret it to mean that the thread is still running and continue to test for the completion of the thread after the thread has terminated, which could put the application into an infinite loop.




### References

- [GetExitCode function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-getexitcodeprocess).
