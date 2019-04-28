# Subprocess class




## Constructor
[Subprocess-Constructor.md](Subprocess-Constructor.md)




## Properties

| Type | Name | Description | Access type |
| -------- | -------- | -------- | -------- |
| Integer | hProcess | A handle to the newly created process. The handle is used to specify the process in all functions that perform operations on the process object. This Handle has all possible access rights. | Readonly |
| Integer | hThread | A handle to the primary thread of the newly created process. The handle is used to specify the thread in all functions that perform operations on the thread object. | Readonly |
| Integer | ProcessId | A value that can be used to identify the process. The value is valid from the time the process is created until all handles to the process are closed and the process object is freed; at this point, the identifier may be reused. | Readonly |
| Integer | ThreadId | A value that can be used to identify the main thread. The value is valid from the time the thread is created until all handles to the thread are closed and the thread object is freed; at this point, the identifier may be reused. | Readonly |
| [Subprocess::Pipe::StreamWriter](StreamWriter.md) | StdIn | Standard input stream. | Readonly |
| [Subprocess::Pipe::StreamReader](StreamReader.md) | StdOut | Standard output stream. | Readonly |
| [Subprocess::Pipe::StreamReader](StreamReader.md) | StdErr | Standard output error stream. | Readonly |




## Methods
| Name | Description |
| -------- | -------- |
| [Close](Subprocess-Close.md) | Closes all open Handles and releases the used resources. |
| [Terminate](Subprocess-Terminate.md) | Terminates the child process and all of its threads. |
| [GetExitCode](Subprocess-GetExitCode.md) | Retrieves the termination status of the specified process. |
| [WaitClose](Subprocess-WaitClose.md) | Waits for the child process to close. |
| [SuspendThread](Subprocess-SuspendThread.md) | Suspends the primary thread of the child process. |
| [ResumeThread](Subprocess-ResumeThread.md) | Decrements the primary thread suspend count of the child process. |
| [IsWow64Process](Subprocess-IsWow64Process.md) | Determines whether the child process is running under WOW64 or an Intel64 of x64 processor. |
| [RegisterWaitForTermination](Subprocess-RegisterWaitForTermination.md) | Registers a function callback to be called when the process terminates. |
| [UnregisterWait](Subprocess-UnregisterWait.md) | Cancels the registered wait operation issued by the RegisterWaitForTermination method. |
| [Debug](Subprocess-Debug.md) | Enables a debugger to attach to the child process and debug it. |
| [DebugStop](Subprocess-DebugStop.md) | Stops the debugger from debugging the child process. |
