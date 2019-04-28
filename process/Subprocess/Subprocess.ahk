/*
    https://github.com/flipeador/Library-AutoHotkey/tree/master/process/Subprocess
*/
class Subprocess
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static BufferSize := 4096  ; The suggested size of the pipe's buffer, in bytes (do not change!).


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    hProcess             := 0  ; A handle to the newly created process.
    hThread              := 0  ; A handle to the primary thread of the newly created process.
    ProcessId            := 0  ; A value that can be used to identify a process.
    ThreadId             := 0  ; A value that can be used to identify a thread.
    StdIn                := 0  ; Subprocess.StreamWriter object.
    StdOut               := 0  ; Subprocess.StreamReader object.
    StdErr               := 0  ; Subprocess.StreamReader object.
    hNewWaitObject       := 0  ; RegisterWaitForSingleObject.
    pWaitOrTimerCallback := 0  ; Pointer to the WaitOrTimerCallback callback function.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(CommandLine, WorkingDir := 0, CreationFlags := 0)
    {
        global Subprocess
        local

        ; Create a pipe for the child process's STDIN.
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa365152(v=vs.85).aspx.
        stdin_read  := 0, stdin_write := 0
        if !DllCall("Kernel32.dll\CreatePipe", "PtrP", stdin_read, "PtrP", stdin_write, "Ptr", 0, "UInt", Subprocess.BufferSize)
            throw Exception("Subprocess class: CreatePipe STDIN.", -1, "Error " . A_LastError)
        ; Make the read handle to the STDIN pipe to be inherited.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/handleapi/nf-handleapi-sethandleinformation.
        if !DllCall("Kernel32.dll\SetHandleInformation", "Ptr", stdin_read, "UInt", 1, "UInt", 1)  ; HANDLE_FLAG_INHERIT = 1.
        {
            Subprocess.CloseHandle(stdin_read, stdin_write)
            throw Exception("Subprocess class: SetHandleInformation STDIN.", -1, "Error " . A_LastError)
        }

        ; Create a pipe for the child process's STDOUT.
        stdout_read := 0, stdout_write := 0
        if !DllCall("Kernel32.dll\CreatePipe", "PtrP", stdout_read, "PtrP", stdout_write, "Ptr", 0, "UInt", Subprocess.BufferSize)
        {
            Subprocess.CloseHandle(stdin_read, stdin_write)
            throw Exception("Subprocess class: CreatePipe STDOUT.", -1, "Error " . A_LastError)
        }
        ; Make the write handle to the STDOUT pipe to be inherited.
        if !DllCall("Kernel32.dll\SetHandleInformation", "Ptr", stdout_write, "UInt", 1, "UInt", 1)  ; HANDLE_FLAG_INHERIT = 1.
        {
            Subprocess.CloseHandle(stdin_read, stdin_write, stdout_read, stdout_write)
            throw Exception("Subprocess class: SetHandleInformation STDOUT.", -1, "Error " . A_LastError)
        }

        ; Create a pipe for the child process's STDERR.
        stderr_read := 0, stderr_write := 0
        if !DllCall("Kernel32.dll\CreatePipe", "PtrP", stderr_read, "PtrP", stderr_write, "Ptr", 0, "UInt", Subprocess.BufferSize)
        {
            Subprocess.CloseHandle(stdin_read, stdin_write, stdout_read, stdout_write)
            throw Exception("Subprocess class: CreatePipe STDERR.", -1, "Error " . A_LastError)
        }
        ; Make the write handle to the STDERR pipe to be inherited.
        if !DllCall("Kernel32.dll\SetHandleInformation", "Ptr", stderr_write, "UInt", 1, "UInt", 1)  ; HANDLE_FLAG_INHERIT = 1.
        {
            Subprocess.CloseHandle(stdin_read, stdin_write, stdout_read, stdout_write, stderr_read, stderr_write)
            throw Exception("Subprocess class: SetHandleInformation STDERR.", -1, "Error " . A_LastError)
        }

        ; STARTUPINFO structure.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/ns-processthreadsapi-_startupinfoa.
        STARTUPINFO      := ""
        STARTUPINFO_Size := A_PtrSize == 4 ? 68 : 104
        VarSetCapacity(STARTUPINFO, STARTUPINFO_Size, 0)
        NumPut(STARTUPINFO_Size, &STARTUPINFO, "UInt")  ; cb.
        NumPut(0x100, &STARTUPINFO+(A_PtrSize==4?44:60), "UInt")  ; dwFlags. STARTF_USESTDHANDLES = 0x100.
        NumPut(stderr_write,NumPut(stdout_write,NumPut(stdin_read,&STARTUPINFO+(A_PtrSize==4?56:80),"Ptr"),"Ptr"),"Ptr")

        ; PROCESS_INFORMATION structure.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/ns-processthreadsapi-process_information.
        ; The PROCESS_INFORMATION structure receives identification information about the new process.
        PROCESS_INFORMATION := ""
        VarSetCapacity(PROCESS_INFORMATION, 2*A_PtrSize+8, 0)

        ; CreateProcessW function.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/processthreadsapi/nf-processthreadsapi-createprocessw.
        if !DllCall("Kernel32.dll\CreateProcessW", "UPtr", 0              ; lpApplicationName.
                                                 , "UPtr", Type(CommandLine) == "String" ? &CommandLine : CommandLine   ; lpCommandLine.
                                                 , "UPtr", 0     ; lpProcessAttributes.
                                                 , "UPtr", 0     ; lpThreadAttributes.
                                                 ,  "Int", TRUE  ; bInheritHandles.
                                                 , "UInt", CreationFlags | 0x00000400  ; dwCreationFlags. CREATE_UNICODE_ENVIRONMENT = 0x00000400.
                                                 , "UPtr", 0     ; lpEnvironment.
                                                 , "UPtr", Type(WorkingDir) == "String" ? &WorkingDir : WorkingDir      ; lpCurrentDirectory.
                                                 , "UPtr", &STARTUPINFO           ; lpStartupInfo.
                                                 , "UPtr", &PROCESS_INFORMATION)  ; lpProcessInformation.
        {
            Subprocess.CloseHandle(stdin_read, stdin_write, stdout_read, stdout_write, stderr_read, stderr_write)
            throw Exception("Subprocess class: CreateProcessW.", -1, "Error " . A_LastError)
        }

        this.hProcess  := NumGet(&PROCESS_INFORMATION                  , "UPtr")  ; PROCESS_INFORMATION.hProcess.
        this.hThread   := NumGet(&PROCESS_INFORMATION + A_PtrSize      , "UPtr")  ; PROCESS_INFORMATION.hThread.
        this.ProcessId := NumGet(&PROCESS_INFORMATION + 2*A_PtrSize    , "UInt")  ; PROCESS_INFORMATION.dwProcessId.
        this.ThreadId  := NumGet(&PROCESS_INFORMATION + 2*A_PtrSize + 4, "UInt")  ; PROCESS_INFORMATION.dwThreadId.

        this.StdIn  := new Subprocess.StreamWriter(stdin_write)
        this.StdOut := new Subprocess.StreamReader(stdout_read)
        this.StdErr := new Subprocess.StreamReader(stderr_read)

        ; Close unused Handles by the current process.
        Subprocess.CloseHandle(stdin_read, stdout_write, stderr_write)
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        this.Close()
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    CloseHandle(Handle*)  ; Static.
    {
        loop Handle.Length()
            if Handle[A_Index] && !DllCall("Kernel32.dll\CloseHandle", "Ptr", Handle[A_Index])
                throw Exception("Subprocess class: CloseHandle.", -1, "Error " . A_LastError)
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/handleapi/nf-handleapi-closehandle


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Close()
    {
        this.StdIn  := "", this.StdOut := "", this.StdErr := ""
        Subprocess.CloseHandle(this.hProcess, this.hThread)

        this.UnregisterWait()

        this.base := ObjSetCapacity(this, 0*ObjDelete(this,"",Chr(0x10FFFF)))  ; Invalidate this object.
    }

    Terminate(ExitCode := 0)
    {
        return DllCall("Kernel32.dll\TerminateProcess", "Ptr", this.hProcess, "UInt", ExitCode)
    }

    GetExitCode()
    {
        local ExitCode := 0
        return DllCall("Kernel32.dll\GetExitCodeProcess", "Ptr", this.hProcess, "UIntP", ExitCode)
             ? ExitCode  ; OK.
             : -1        ; ERROR.
    }

    WaitClose(Timeout := 0)
    {
        return Timeout
             ? ProcessWaitClose(this.ProcessId,Timeout) ? FALSE : TRUE
             : ProcessWaitClose(this.ProcessId)         ? FALSE : TRUE
    }

    SuspendThread()
    {
        return this.IsWow64Process()
             ? DllCall("Kernel32.dll\Wow64SuspendThread", "Ptr", this.hThread, "Int")
             : DllCall("Kernel32.dll\SuspendThread", "Ptr", this.hThread, "Int")
    }

    ResumeThread()
    {
        return DllCall("Kernel32.dll\ResumeThread", "Ptr", this.hThread, "Int")
    }

    IsWow64Process()
    {
        local Wow64Process := 0
        if A_Is64bitOS
            if !DllCall("Kernel32.dll\IsWow64Process", "Ptr", this.hProcess, "IntP", Wow64Process)
                throw Exception("Subprocess class, IsWow64Process method.", -1, "IsWow64Process Error " . A_LastError)
        return Wow64Process
    }

    RegisterWaitForTermination(FuncName, Context := 0, Timeout := 0xFFFFFFFF)
    {
        if this.pWaitOrTimerCallback
            throw Exception("Subprocess class, RegisterWaitForTermination method.", -1, "There is already a registered function.")
        this.pWaitOrTimerCallback := CallbackCreate(FuncName)

        local hNewWaitObject := 0
        R := DllCall("Kernel32.dll\RegisterWaitForSingleObject", "PtrP", hNewWaitObject               ; phNewWaitObject.
                                                               , "UPtr", this.hProcess                ; hObject.
                                                               , "UPtr", this.pWaitOrTimerCallback    ; Callback.
                                                               , "UPtr", Context                      ; Context.
                                                               , "UInt", Timeout                      ; dwMilliseconds. INFINITE = 0xFFFFFFFF.
                                                               , "UInt", 0x00000008)                  ; dwFlags. WT_EXECUTEONLYONCE = 0x00000008.
        this.hNewWaitObject := hNewWaitObject
        if !R
            CallbackFree(this.pWaitOrTimerCallback)

        return R
    }

    UnregisterWait()
    {
        local R := TRUE

        if this.pWaitOrTimerCallback
        {
            CallbackFree(this.pWaitOrTimerCallback)
            this.pWaitOrTimerCallback := 0
            R := DllCall("Kernel32.dll\UnregisterWait", "Ptr", this.hNewWaitObject)
        }
        
        return R
    }

    Debug(KillOnExit := FALSE)
    {
        local r := DllCall("Kernel32.dll\DebugActiveProcess", "UInt", this.ProcessId)
        DllCall("Kernel32.dll\DebugSetProcessKillOnExit", "Int", !!KillOnExit)
        return r
    }

    DebugStop()
    {
        return DllCall("Kernel32.dll\DebugActiveProcessStop", "UInt", this.ProcessId)
    }


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    #Include Pipe.ahk
    #Include StreamReader.ahk
    #Include StreamWriter.ahk
}
