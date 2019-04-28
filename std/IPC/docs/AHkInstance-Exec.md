# AHkInstance::Exec method

Creates the subprocess and executes the current code stored in the `ScriptCode` property.




### Syntax

```
Integer Exec(
  IN String CommandLine = "",
  IN String WorkingDir = "",
  IN Integer CreationFlags = 0
)
```




### Parameters

###### CommandLine

Optional arguments to pass to the command line.

###### WorkingDir

The initial working directory of the process ([A_InitialWorkingDir](https://lexikos.github.io/v2/docs/Variables.htm#InitialWorkingDir)).

If the specified directory does not exist, it uses the current working directory of the calling process.

###### CreationFlags

The flags that control the priority class and the creation of the process.

See the `CreationFlags` parameter in the [constructor](..\..\..\process\Subprocess\docs\Subprocess-Constructor.md) of the [Subprocess](..\..\..\process\Subprocess\docs\Subprocess.md) class.




### Return value

Returns the process ID (PID) if successful; Otherwise an exception is thrown.




### Remarks

Before calling this method you must have added code using the [AddCode](AHkInstance-AddCode.md) method

If the process is already running, the PID is returned without doing anything.

If the process is in the `STATE_STOP_PENDING` state, the method waits for the process to terminate and then creates a new one.

If the process is in the `STATE_START_PENDING` state, the method waits for the process to be created and then returns the PID.

When the subprocess is created successfully, it is monitored to perform the required procedures automatically when it terminates.




### Important!

When the new process is created, the script receives the name of Server, and certain global variables and functions are automatically added to the code to be able to make the communication between processes possible. For more information, see [Server](Server.md).
