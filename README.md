# AutoHotkey v2 Library

Some scripts are rewritten versions of someone else, credits are included in each file or in the documentation (README.md), if it is not the case, let me know.

Part of the library contains outdated and probably obsolete scripts, they will be updated over time. If you are interested in one in particular, let me know.

Everything that is properly documented (using `.md` files) could be considered updated.




## Remarks

The header file is the main `.ahk` file, it must be included along with the files required by the library specified in the documentation (README.md) to make it work.

The `.ahk` files specified in the `Requirements` section are files that must be included separately in the project, these are not automatically included by the main header file. You must download them separately.

The `Dependencies` consists of `.ahk` files that the header file requires to work and that are included automatically, these are usually placed in the same directory as the header file.

You should make sure to always include the `.ahk` files in the [Auto-execute Section](https://lexikos.github.io/v2/docs/Scripts.htm#auto), since some files may require to execute code before being used.

All updated files are written using good programming practices, to ensure that they do not interfere in any way with your global variables, messages, etc. Also, fully compatible with `#Warn All`.

All scripts are compatible when compiling and do not require any external `.ahk` file.


<br>

***

<br>


###### Everything listed here has been reviewed, documented and updated.


## Process

| Name | Description |
| -------- | -------- |
| [Subprocess](process/Subprocess) | Creates a Child Process with Redirected Input and Output. |
| [IPC](std/IPC) | Interprocess communications (IPC). |
| [ExecScript](std/ExecScript) | Execute an AHK script as a new process with Redirected Input and Output. |

## Window

| Name | Description |
| -------- | -------- |
| [Explorer](window/Explorer) | [Windows Explorer](https://docs.microsoft.com/en-us/windows/desktop/shell/developing-with-windows-explorer) |
