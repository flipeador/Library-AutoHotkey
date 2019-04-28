# Subprocess::Terminate method

Terminates the child process and all of its threads.




### Syntax

```
int Terminate(
  IN Integer ExitCode = 0
)
```




### Parameters

###### ExitCode

The exit code to be used by the process and threads terminated as a result of this call.




### Return value

If the method succeeds, the return value is nonzero.

If the method fails, the return value is zero. To get extended error information, check `A_LastError`.




### References

- [TerminateProcess function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-terminateprocess).
