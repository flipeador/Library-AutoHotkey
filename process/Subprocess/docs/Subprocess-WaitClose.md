# Subprocess::WaitClose method

Waits for the child process to close.




### Syntax

```
int WaitClose(
  IN Integer Timeout
)
```




### Parameters

###### Timeout

If zero or omitted, this method will wait indefinitely.

Otherwise, specify the number of seconds (can contain a decimal point) to wait before timing out.




### Return value

If the child process was closed, the return value is nonzero.

If this method times out, the return value is zero.




### Remarks

This method uses the built-in [ProcessWaitClose](https://lexikos.github.io/v2/docs/commands/ProcessWaitClose.htm) function.
