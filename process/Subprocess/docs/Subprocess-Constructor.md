# Subprocess::Subprocess

Creates the child process and its primary thread.




### Syntax

```
Subprocess __New(
  IN String/Integer CommandLine,
  IN String/Integer WorkingDir,
  IN Integer CreationFlags
)
```




### Parameters

###### CommandLine

The name of the module and the command line to be executed.
<br>
This parameter can be a string or a pointer to a null-terminated string.
<br><br>
The first white space–delimited token of the command line specifies the module name.
<br>
If you are using a long file name that contains a space, use quoted strings to indicate where the file name ends and the arguments begin.
<br>
If the file name does not contain an extension, .exe is appended. If the file name ends in a period (.) with no extension, or if the file name contains a path, .exe is not appended.
<br><br>
The maximum length of this string is 32767 characters.<br>The module name portion is limited to 259 (MAX_PATH-1) characters.

###### WorkingDir

The full path to the current directory for the process. The string can also specify a UNC path.<br>
This parameter can be a string or a pointer to a null-terminated string.
<br><br>
If this parameter is zero, the new process will have the same current drive and directory as the calling process.

###### CreationFlags

The flags that control the priority class and the creation of the process. For a list of values, see [Process Creation Flags](https://msdn.microsoft.com/fd3384ad-8635-4ea1-9054-0572ef86b86d) or [Creation Flags](#creation-flags).




### Return value

If successful, returns the [Subprocess](Subprocess.md) class object.

if unsuccessful, throws an exception.

<br>

***

<br>




### Creation Flags

| Value | Constant | Description |
| -------- | -------- | -------- |
| 0x08000000 | CREATE_NO_WINDOW | The process is a console application that is being run without a console window. |
| 0x00000010 | CREATE_NEW_CONSOLE | The new process has a new console, instead of inheriting its parent's console (the default). |
| 0x00000004 | CREATE_SUSPENDED | The primary thread of the new process is created in a suspended state, and does not run until the ResumeThread function is called. |
| | | |
| 0x00000040 | IDLE_PRIORITY_CLASS | Process whose threads run only when the system is idle and are preempted by the threads of any process running in a higher priority class. |
| 0x00004000 | BELOW_NORMAL_PRIORITY_CLASS | Process that has priority above IDLE_PRIORITY_CLASS but below NORMAL_PRIORITY_CLASS. |
| 0x00000020 | NORMAL_PRIORITY_CLASS | Process with no special scheduling needs. |
| 0x00008000 | ABOVE_NORMAL_PRIORITY_CLASS | Process that has priority above NORMAL_PRIORITY_CLASS but below HIGH_PRIORITY_CLASS. |
| 0x00000080 | HIGH_PRIORITY_CLASS | Process that performs time-critical tasks that must be executed immediately for it to run correctly. |
| 0x00000100 | REALTIME_PRIORITY_CLASS | Process that has the highest possible priority. |
