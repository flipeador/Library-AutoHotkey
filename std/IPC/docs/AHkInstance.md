# AHkInstance class




## Constructor
[AHkInstance-Constructor.md](AHkInstance-Constructor.md)




## Properties

| Type | Name | Description | Access type |
| -------- | -------- | -------- | -------- |
| Static String | AhkPath | The path of the AutoHotkey interpreter file (AutoHotkey.exe) used to execute scripts as a new process. Use the [SetAhkPath](AHkInstance-SetAhkPath.md) method to change this value. The default value is `A_AhkPath` | Readonly. |
| Integer | State | The current state of the sub-process. See [States](#states) for more information. | Readonly. |
| String | ScriptCode | Contains the AHK code that will be executed when calling the [Exec](AHkInstance-Exec.md) method. See the [AddCode](AHkInstance-AddCode.md) method. | Readonly. |
| [Subprocess](../../../process/Subprocess/docs/Subprocess.md) | Subprocess | The [Subprocess](../../../process/Subprocess/docs/Subprocess.md) class object. Calling some methods directly using this object can give unexpected results. | Readonly. |




## Methods
| Name | Description |
| -------- | -------- |
| [Close](AHkInstance-Close.md) | Terminates the process and releases all the used resources. |
| [SetAhkPath](AHkInstance-SetAhkPath.md) | Sets the path of the AutoHotkey interpreter file (AutoHotkey.exe) used to execute scripts as a new process. |
| [AddCode](AHkInstance-AddCode.md) | Adds AHK code that will be executed when calling the [Exec](AHkInstance-Exec.md) method. |
| [Exec](AHkInstance-Exec.md) | Creates the process and executes the current code. |
| [Terminate](AHkInstance-Terminate.md) | Terminates the process and all of its threads. |
| [ExitApp](AHkInstance-ExitApp.md) | Terminates the process as if the script executes [ExitApp](https://lexikos.github.io/v2/docs/commands/ExitApp.htm). |
| [Suspend](AHkInstance-Suspend.md) | Suspends the process. |
| [Resume](AHkInstance-Resume.md) | Resumes the process. |
| Static [GetActiveObject](AHkInstance-GetActiveObject.md) | Gets the registered active object of the specified subprocess. |




## States

| Value | Constant | Description | Defined |
| -------- | -------- | -------- | -------- |
| 0x00 | STATE_STOPPED | The process is not running. | AHkInstance.STATE_STOPPED |
| 0x01 | STATE_RUNNING | The process is running. | AHkInstance.STATE_RUNNING |
| 0x02 | STATE_STOP_PENDING | The process is being stopped. | AHkInstance.STATE_STOP_PENDING |
| 0x03 | STATE_START_PENDING | The process is about to be created. | AHkInstance.STATE_START_PENDING |
