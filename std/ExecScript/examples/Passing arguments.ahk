#Include ..\..\..\process\Subprocess\Subprocess.ahk
#Include ..\ExecScript.ahk


Script      := "MsgBox(A_Args[1] . A_Args[2] . A_Args[3],'Child process',0x1000)"
CommandLine := Format("{} `"{}`" {}"
                    , "Hello", " World", "!")  ; CommandLine.

ahk := ExecScript(Script, CommandLine)

AssignProcessToJobObject(ahk.hProcess)

ahk.WaitClose(5)

ExitApp





/*
    Assigns a job to the specified process to make it terminates when the parent process is closed.
*/
AssignProcessToJobObject(hProcess)
{
    local

    ; https://docs.microsoft.com/en-us/windows/desktop/api/jobapi2/nf-jobapi2-createjobobjectw
    hJob := DllCall("Kernel32.dll\CreateJobObjectW", "Ptr", 0, "Ptr", 0, "Ptr")
    if !hJob
        throw Exception("CreateJobObjectW", -1, "Error " . A_LastError)

    ; JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/winnt/ns-winnt-_jobobject_extended_limit_information
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION := ""
    VarSetCapacity(JOBOBJECT_EXTENDED_LIMIT_INFORMATION, Size:=A_PtrSize==4?112:144, 0)
    NumPut(0x00002000, &JOBOBJECT_EXTENDED_LIMIT_INFORMATION+16, "UInt")  ; JOBOBJECT_BASIC_LIMIT_INFORMATION.LimitFlags.

    ; JobObjectExtendedLimitInformation = 9.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/jobapi2/nf-jobapi2-setinformationjobobject
    if !DllCall("Kernel32.dll\SetInformationJobObject", "Ptr", hJob, "Int", 9, "Ptr", &JOBOBJECT_EXTENDED_LIMIT_INFORMATION, "UInt", Size)
        throw Exception("SetInformationJobObject", -1, "Error " . A_LastError)

    ; https://docs.microsoft.com/en-us/windows/desktop/api/jobapi2/nf-jobapi2-assignprocesstojobobject
    if !DllCall("Kernel32.dll\AssignProcessToJobObject", "Ptr", hJob, "Ptr", hProcess)
        throw Exception("AssignProcessToJobObject", -1, "Error " . A_LastError)
} ; https://stackoverflow.com/questions/24012773/c-winapi-how-to-kill-child-processes-when-the-calling-parent-process-is-for
