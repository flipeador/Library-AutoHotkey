# Subprocess::UnregisterWait method

Cancels the registered wait operation issued by the [RegisterWaitForTermination](Subprocess-RegisterWaitForTermination.md) method.




### Syntax

```
int UnregisterWait()
```




### Return value

If the method succeeds, the return value is nonzero.

If the method fails, the return value is zero. To get extended error information, check `A_LastError`.




### Remarks

If any callback functions associated with the timer have not completed when `UnregisterWait` is called, `UnregisterWait` unregisters the wait on the callback functions and fails with the `ERROR_IO_PENDING` (997) error code.

The error code does not indicate that the function has failed, and the function does not need to be called again.

`UnregisterWait` should not be called within the timer callback function.




### References

- [UnregisterWait function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-unregisterwait).