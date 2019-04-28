# AHkInstance::ExitApp method

Terminates the process as if the script executes [ExitApp](https://lexikos.github.io/v2/docs/commands/ExitApp.htm).




### Syntax

```
void ExitApp(
  IN Integer ExitCode = 0
)
```




### Parameters

###### ExitCode

The exit code to be used by the process and threads terminated as a result of this call.




### Return value

This method does not return a value.




### Remarks

This method waits until the process terminates.


If the process is in the `STATE_START_PENDING` state, the method waits for the process to be created and then terminates it.
