# Interprocess communications (IPC)

Provides mechanisms for facilitating communications and data sharing between scripts using [OLE](https://docs.microsoft.com/en-us/cpp/mfc/ole-background).

This library mainly uses the [RegisterActiveObject](https://docs.microsoft.com/en-us/windows/desktop/api/oleauto/nf-oleauto-registeractiveobject) function to achieve effective communication between scripts. The Windows registry is not touched, since it is not necessary to define the [ProgIDs](https://docs.microsoft.com/en-us/windows/desktop/com/-progid--key), we work directly with the [GUIDs](https://docs.microsoft.com/en-us/previous-versions/aa373931(v%3Dvs.80)).

You can find examples in the [examples folder](examples).




## Requirements

| Name | Documentation | Location | Description |
| -------- | -------- | -------- | -------- |
| [AHkInstance.ahk](AHkInstance.ahk) | [docs\AhkInstance.md](docs/AhkInstance.md) | This library | **Header**. |
| [ExecScript.ahk](..\ExecScript\ExecScript.ahk) | [ExecScript\README.md](../ExecScript/README.md) | Extern | Used to start a new process with the **AutoHotkey interpreter**. |
| [Subprocess.ahk](../../process/Subprocess/Subprocess.ahk) | [Subprocess\README.md](../../process/Subprocess/README.md) | Extern | Used by **ExecScript** to create a new process. |




## Dependences

| Name | Documentation | Header | Description |
| -------- | -------- | -------- | -------- |
| [Client.ahk](Client.ahk) | [docs\Client.md](docs/Client.md) | [AHkInstance.ahk](AHkInstance.ahk) | Client related stuff (main script). |
| [Server.ahk](Server.ahk) | [docs\Server.md](docs/Server.md) | [AHkInstance.ahk](AHkInstance.ahk) | Server related stuff (subprocesses) |




## References

- [Interprocess Communications | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/ipc/interprocess-communications)
- [OLE Automation | Microsoft](https://docs.microsoft.com/en-us/cpp/mfc/automation).
- [Component Object Model (COM) | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/com/component-object-model--com--portal).
- [ObjRegisterActive | AutoHotkey Community](https://www.autohotkey.com/boards/viewtopic.php?t=6148)
- [GUID & UUID | AutoHotkey Community](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4732)
- [GetActiveObjects - Get multiple active COM objects | AutoHotkey Community](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=6494)
- [LoadFile - Load script file as a separate process | AutoHotkey Community](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=6194)
