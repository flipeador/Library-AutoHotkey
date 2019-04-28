# Subprocess::SuspendThread method

Suspends the primary thread of the child process.




### Syntax

```
int SuspendThread()
```




### Return value

If the method succeeds, the return value is the thread's previous suspend count.

If the method fails, the return value is `-1`. To get extended error information, check `A_LastError`.




### References

- [SuspendThread function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-suspendthread).
