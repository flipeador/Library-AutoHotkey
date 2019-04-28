# Subprocess::ResumeThread method

Decrements the primary thread suspend count of the child process.




### Syntax

```
int ResumeThread()
```




### Return value

If the method succeeds, the return value is the thread's previous suspend count.

If the method fails, the return value is `-1`. To get extended error information, check `A_LastError`.




### Remarks

This method can be useful if the process was created with the `CREATE_SUSPENDED` creation flag.




### References

- [ResumeThread function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-resumethread).
