# Subprocess::DebugStop method

Stops the debugger from debugging the child process.




### Syntax

```
int DebugStop()
```




### Return value

If the method succeeds, the return value is nonzero.

If the method fails, the return value is zero. To get extended error information, check `A_LastError`.




### Remarks

This method can be used to resume the child process previously suspended with the [Debug](Subprocess-Debug.md) method.




### References

- [DebugActiveProcessStop function | Microsoft](https://msdn.microsoft.com/en-us/library/windows/desktop/ms679296.aspx).
