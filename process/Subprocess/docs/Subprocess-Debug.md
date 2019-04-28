# Subprocess::Debug method

Enables a debugger to attach to the child process and debug it.




### Syntax

```
int Debug(
  IN Integer KillOnExit = FALSE
)
```




### Parameters

###### KillOnExit

Sets the action to be performed when the calling thread exits.

| Value | Description |
| -------- | -------- |
| FALSE | The thread detaches from all processes being debugged on exit. |
| TRUE | The thread terminates all attached processes on exit. |




### Return value

If the method succeeds, the return value is nonzero.

If the method fails, the return value is zero. To get extended error information, check `A_LastError`.




### Remarks

This method can be used to suspend the child process. Use the [DebugStop](Subprocess-DebugStop.md) method to resume the process.




### References

- [DebugActiveProcess function | Microsoft](https://msdn.microsoft.com/en-us/library/windows/desktop/ms679295%28v=vs.85%29.aspx).
- [DebugSetProcessKillOnExit function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-debugsetprocesskillonexit).
