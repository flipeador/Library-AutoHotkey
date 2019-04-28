# ExecScript function

Executes an AHK script as a new process with Redirected Input and Output.




### Syntax

```
Subprocess ExecScript(
  IN String Script,
  IN String CommandLine = "",
  IN String WorkingDir = A_WorkingDir,
  IN String AhkPath = A_AhkPath,
  IN Integer CreationFlags = 0
)
```




### Parameters

###### Script

The script code to be executed as a new process.

###### CommandLine

Optional arguments to pass to the command line.

You can use [A_Args](https://lexikos.github.io/v2/docs/Variables.htm#Args) in the Child Process to retrieve this data.

###### WorkingDir

The initial working directory of the new child process ([A_InitialWorkingDir](https://lexikos.github.io/v2/docs/Variables.htm#InitialWorkingDir)).

If the specified directory does not exist, The current working directory of the calling process will be used.

###### AhkPath

The path to the AutoHotkey interpreter file (AutoHotkey.exe).

###### CreationFlags

The flags that control the priority class and the creation of the sub-process.

See the `CreationFlags` parameter in the [constructor](..\..\..\process\Subprocess\docs\Subprocess-Constructor.md) of the [Subprocess](..\..\..\process\Subprocess\docs\Subprocess.md) class.




### Return value

If the function succeeds, the return value is the [Subprocess](..\..\..\process\Subprocess\docs\Subprocess.md) class object.

If the function fails, throws an exception. See the [constructor](..\..\..\process\Subprocess\docs\Subprocess-Constructor.md) of the [Subprocess](..\..\..\process\Subprocess\docs\Subprocess.md) class.




### Remarks

The encoding used for `StdIn`, `StdOut` and `StdErr` is `UTF-8` (Unicode).

Write text to `StdOut` and `StdErr` (from the Child Process) using:

```AutoHotkey
StdOut := FileOpen("*", "w", "UTF-8-RAW")
StdErr := FileOpen("**", "w", "UTF-8-RAW")
StdOut.Write("StdOut Text")
StdOut.Read(0)  ; Flush the write buffer.
```

Note that `StdIn` is automatically closed after writing the [script code](#parameters), so that the AutoHotkey interpreter starts executing the code.

[**ExitApp**](https://lexikos.github.io/v2/docs/commands/ExitApp.htm) is added to the end of the specified [script code](#parameters). [**#Persistent**](https://lexikos.github.io/v2/docs/commands/_Persistent.htm) is also used.
