# Subprocess::RegisterWaitForTermination method

Registers a function callback to be called when the process terminates.




### Syntax

```
int RegisterWaitForTermination(
  IN Func/String FuncName,
  IN UPtr Context = 0,
  IN Integer Timeout = INFINITE
)
```




### Parameters

###### FuncName

A function name or function object. This function is called when the process terminates. For more information, see the [WaitOrTimerCallback callback function](https://msdn.microsoft.com/es-ar/a47354e2-c665-41f8-8661-ab16ac966243).

###### Context

A single value that is passed to the callback function.

###### Timeout

The time-out interval, in milliseconds.

The function returns if the interval elapses, even if the object's state is nonsignaled.

If `Timeout` is zero, the function tests the object's state and returns immediately.

If `Timeout` is `INFINITE` (0xFFFFFFFF), the function's time-out interval never elapses.




### Return value

If the method succeeds, the return value is nonzero.

If the method fails, the return value is zero. To get extended error information, check `A_LastError`.




### Remarks

The callback function will only be called once. Once the callback function returns, you must call the [UnregisterWait](Subprocess-UnregisterWait.md) method to release used resources.

You can not register more than one callback function using this method. Trying to register a new callback function will throw an exception.




### References

- [RegisterWaitForSingleObject function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-registerwaitforsingleobject).
- [How to detect win32 process creation/termination in c++](https://stackoverflow.com/questions/3556048/how-to-detect-win32-process-creation-termination-in-c).
