/*
    Sets information for the specified thread.
    Parameters:
        hThread:
            A handle to the thread.
            The handle must have THREAD_QUERY_INFORMATION access right.
        InformationClass:
            The class of information to set. One of the system-defined values in the THREADINFOCLASS enumeration.
        Information:
            A structure that contains the type of information specified by the «InformationClass» parameter.
        InformationSize:
            The size in bytes of the structure specified by the «Information» parameter.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ThreadSetInformation(Thread, InformationClass, Information, InformationSize := "")
{
    local NtType := "Ptr"
    if (IsObject(InformationSize))
    {
        NtType          := InformationSize[1]
        InformationSize := InformationSize[2]
    }

    local NtStatus := DllCall("Ntdll.dll\NtSetInformationThread", "UPtr", IsObject(Thread) ? Thread.Handle : Thread
                                                                ,  "Int", InformationClass
                                                                , NtType, Information
                                                                , "UInt", InformationSize == "" ? Information.Size : InformationSize 
                                                                , "UInt")

    if (NtStatus !== 0)
    {
        A_LastError := NtStatus
        return 0
    }

    return Thread
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/nf-ntifs-ntsetinformationthread





ThreadSetImpersonationToken(Thread, Token)
{
    ; ThreadImpersonationToken = 5.
    return ThreadSetInformation(Thread, 5, IsObject(Token)?Token.Handle:Token, ["PtrP",A_PtrSize])
}





/*
typedef enum _THREADINFOCLASS {
    ThreadBasicInformation,
    ThreadTimes,
    ThreadPriority,
    ThreadBasePriority,
    ThreadAffinityMask,
    ThreadImpersonationToken,
    ThreadDescriptorTableEntry,
    ThreadEnableAlignmentFaultFixup,
    ThreadEventPair,
    ThreadQuerySetWin32StartAddress,
    ThreadZeroTlsCell,
    ThreadPerformanceCount,
    ThreadAmILastThread,
    ThreadIdealProcessor,
    ThreadPriorityBoost,
    ThreadSetTlsArrayAddress,
    ThreadIsIoPending,
    ThreadHideFromDebugger,
    ThreadBreakOnTermination,
    ThreadSwitchLegacyState,
    ThreadIsTerminated,
    ThreadLastSystemCall,
    ThreadIoPriority,
    ThreadCycleTime,
    ThreadPagePriority,
    ThreadActualBasePriority,
    ThreadTebInformation,
    ThreadCSwitchMon,
    ThreadCSwitchPmu,
    ThreadWow64Context,
    ThreadGroupInformation,
    ThreadUmsInformation,
    ThreadCounterProfiling,
    ThreadIdealProcessorEx,
    ThreadCpuAccountingInformation,
    ThreadSuspendCount,
    ThreadHeterogeneousCpuPolicy,
    ThreadContainerId,
    ThreadNameInformation,
    ThreadSelectedCpuSets,
    ThreadSystemThreadInformation,
    ThreadActualGroupAffinity,
    ThreadDynamicCodePolicyInfo,
    ThreadExplicitCaseSensitivity,
    ThreadWorkOnBehalfTicket,
    ThreadSubsystemInformation,
    ThreadDbgkWerReportActive,
    ThreadAttachContainer,
    ThreadManageWritesToExecutableMemory,
    ThreadPowerThrottlingState,
    ThreadWorkloadClass,
    MaxThreadInfoClass
} THREADINFOCLASS;
*/
