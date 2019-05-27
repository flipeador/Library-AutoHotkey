/*
    Determines whether a file is an executable (.exe) file, and if so, which subsystem runs the executable file.
    Parameters:
        AppName:
            The full path of the file whose executable type is to be determined.
    Return value:
        Returns information about the executable type of the file specified by «ApplicationName».
        -1                       File is not executable or function failed.
         0  SCS_32BIT_BINARY     A 32-bit Windows-based application.
         1  SCS_DOS_BINARY       An MS-DOS – based application.
         2  SCS_WOW_BINARY       A 16-bit Windows-based application. 
         3  SCS_PIF_BINARY       A PIF file that executes an MS-DOS – based application. 
         4  SCS_POSIX_BINARY     A POSIX – based application. 
         5  SCS_OS216_BINARY     A 16-bit OS/2-based application. 
         6  SCS_64BIT_BINARY     A 64-bit Windows-based application.
        To get extended error information, check A_LastError. If the file is a DLL, the last error code is ERROR_BAD_EXE_FORMAT.
*/
GetBinaryType(AppName)
{
    local BinaryType := 0
    return DllCall("Kernel32.dll\GetBinaryTypeW", "Ptr", &AppName, "UIntP", BinaryType)
         ? BinaryType : -1
} ; https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-getbinarytypea
