MemIsValidAddr(Address)
{
    ; On Win32, the first 64KB of address space is always invalid.
    return (Address is "Integer")
        && ((Address:=Integer(Address)) >> 16)  ; 0x10000.
        && Address
}





/*
    Retrieves a module handle for the specified module. The module must have been loaded by the calling process.
    Parameters:
        ModuleName:
            The name of the loaded module (either a .dll or .exe file).
        Flags:
            This parameter can be zero or one or more of the following values.
            If the module's reference count is incremented, use the FreeLibrary function to decrement the reference count.
            ┌───────┬──────────────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value │ Constant                                     │ Meaning                                                                                                  │
            ├───────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x1   │ GET_MODULE_HANDLE_EX_FLAG_PIN                │ The module stays loaded until the process is terminated.                                                 │
            │ 0x2   │ GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT │ The reference count for the module is not incremented.                                                   │
            │ 0x4   │ GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS       │ The ModuleName parameter is an address in the module. Cannot be used with GET_MODULE_HANDLE_EX_FLAG_PIN. │
            └───────┴──────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is a handle to the specified module.
        If the function fails, the return value is zero. A_LastError contains extended error information.
    Remarks:
        This function does not retrieve handles for modules that were loaded using the LOAD_LIBRARY_AS_DATAFILE flag (Kernel32\LoadLibraryEx).
*/
GetModuleHandle(ModuleName, Flags := 0x2)
{
    local hModule := 0
    DllCall("Kernel32.dll\GetModuleHandleExW"
        ,  "UInt", Flags                                              ; DWORD   dwFlags.
        ,  "UPtr", ModuleName is "Number" ? ModuleName : &ModuleName  ; LPCWSTR lpModuleName.
        , "UPtrP", hModule)                                           ; HMODULE *phModule.
    return hModule
} ; https://docs.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexw





/*
    Retrieves the address of an exported function or variable from the specified dynamic-link library (DLL).
    Parameters:
        hModule:
            A handle or name to the DLL module that contains the function or variable.
            This function does not retrieve addresses from modules that were loaded using the LOAD_LIBRARY_AS_DATAFILE flag.
        ProcName:
            The function name or the function's ordinal value.
    Return value:
        If the function succeeds, the return value is the address of the exported function or variable.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
GetProcAddress(hModule, ProcName)
{
    return DllCall("Kernel32.dll\GetProcAddress"
        , "UPtr", Type(hModule)=="String"?GetModuleHandle(hModule):hModule  ; HMODULE hModule.
        , Type(ProcName)=="String"?"AStr":"UPtr", ProcName                  ; LPCSTR  lpProcName.
        , "UPtr")                                                           ; FARPROC ReturnValue.
} ; https://docs.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getprocaddress
