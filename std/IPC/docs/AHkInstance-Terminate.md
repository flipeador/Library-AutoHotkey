# AHkInstance::Terminate method

Terminates the process and all of its threads.




### Syntax

```
void Terminate(
  IN Integer ExitCode = 0
)
```




### Parameters

###### ExitCode

The exit code to be used by the process and threads terminated as a result of this call.




### Return value

This method does not return a value.




### Remarks

Instead, consider using the [ExitApp](AHkInstance-ExitApp.md) method to properly terminate the process.

This method waits until the process terminates.


If the process is in the `STATE_START_PENDING` state, the method waits for the process to be created and then terminates it.
