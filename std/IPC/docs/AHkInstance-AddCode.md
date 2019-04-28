# AHkInstance::AddCode method

Adds AHK code that will be executed when calling the [Exec](AHkInstance-Exec.md) method.




### Syntax

```
void AddCode(
  IN String Code,
  IN Integer Flags = 0
)
```




### Parameters

###### Code

The text to add as code.

###### Flags

You can specify one or more of the following values.

| Value | Description |
| -------- | -------- |
| 0x00 | Add the code to the current one on the right. |
| 0x01 | Add the code to the current one on the left. |
| 0x02 | Replace the current code. |
| 0x04 | Insert a new line at the end. |




### Return value

This method does not return a value.




### Remarks

When the [Exec](AHkInstance-Exec.md) method is called, [ExitApp](https://lexikos.github.io/v2/docs/commands/ExitApp.htm) will be added at the end of the code, so you must add a [Return](https://lexikos.github.io/v2/docs/commands/Return.htm) to prevent the script from terminate. [#Persistent](https://lexikos.github.io/v2/docs/commands/_Persistent.htm) is also added. See the [ExecScript](..\..\ExecScript\docs\ExecScript.md) function.

You must call this method at least once before creating the process, otherwise there is no code to execute and the process terminates immediately.
