FreeLibrary(hModule)
{
    ; https://docs.microsoft.com/es-es/windows/desktop/api/libloaderapi/nf-libloaderapi-freelibrary
    return hModule ? DllCall("Kernel32.dll\FreeLibrary","UPtr",hModule) : 0
}





LoadLibrary(DllName, Flags := 0)
{
    ; https://docs.microsoft.com/en-us/windows/desktop/api/libloaderapi/nf-libloaderapi-loadlibraryexa
    return DllCall("Kernel32.dll\LoadLibraryEx", "UPtr", &DllName, "UInt", 0, "UInt", Flags, "UPtr")
}





GetProcAddress(hModule, ProcName)
{
    ; https://docs.microsoft.com/es-es/windows/desktop/api/libloaderapi/nf-libloaderapi-getprocaddress
    return DllCall("Kernel32.dll\GetProcAddress", "UPtr", hModule, type(ProcName)="integer"?"UPtr":"AStr", ProcName, "UPtr")
}
