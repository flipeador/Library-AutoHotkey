/*
    Creates or opens a file or I/O device.
    The most commonly used I/O devices are as follows: file, file stream, directory, physical disk, volume, console buffer, tape drive, communications resource, mailslot, and pipe.
    The function returns a handle that can be used to access the file or device for various types of I/O depending on the file or device and the flags and attributes specified.
    Parameters:
        FileName:
            The name of the file or device to be created or opened. You may use either forward slashes (/) or backslashes (\) in this name.
            To create a file stream, specify the name of the file, a colon (:), and then the name of the stream.
        DesiredAccess:
            The requested access to the file or device, which can be summarized as read, write, both or neither zero).
            If this parameter is zero, the application can query certain metadata such as file, directory, or device attributes without accessing that file or device.
            You cannot request an access mode that conflicts with the sharing mode that is specified by the «ShareMode» parameter in an open request that already has an open handle.
            0x10000000  GENERIC_ALL        All possible access rights.
            0x20000000  GENERIC_EXECUTE    Execute access.
            0x40000000  GENERIC_WRITE      Read access.
            0x80000000  GENERIC_READ       Write access.
        ShareMode:
            The requested sharing mode of the file or device, which can be read, write, both, delete, all of these, or none.
            You cannot request a sharing mode that conflicts with the access mode that is specified in an existing request that has an open handle.
            0x00000000  FILE_SHARE_NONE      Prevents other processes from opening a file or device if they request delete, read, or write access.
            0x00000001  FILE_SHARE_READ      Enables subsequent open operations on a file or device to request read access.
            0x00000002  FILE_SHARE_WRITE     Enables subsequent open operations on a file or device to request write access.
            0x00000004  FILE_SHARE_DELETE    Enables subsequent open operations on a file or device to request delete access.
        CreationDisposition:
            An action to take on a file or device that exists or does not exist.
            This parameter must be one of the following values, which cannot be combined:
            1  CREATE_NEW           Creates a new file, only if it does not already exist.
                                    If the specified file exists, the function fails and the last-error code is set to ERROR_FILE_EXISTS (80).
                                    If the specified file does not exist and is a valid path to a writable location, a new file is created.
            2  CREATE_ALWAYS        Creates a new file, always.
                                    If the specified file exists and is writable, the function overwrites the file, the function succeeds, and last-error code is set to ERROR_ALREADY_EXISTS (183).
                                    If the specified file does not exist and is a valid path, a new file is created, the function succeeds, and the last-error code is set to zero.
            3  OPEN_EXISTING        Opens a file or device, only if it exists.
                                    If the specified file or device does not exist, the function fails and the last-error code is set to ERROR_FILE_NOT_FOUND (2).
            4  OPEN_ALWAYS          Opens a file, always.
                                    If the specified file exists, the function succeeds and the last-error code is set to ERROR_ALREADY_EXISTS (183).
                                    If the specified file does not exist and is a valid path to a writable location, the function creates a file and the last-error code is set to zero.
            5  TRUNCATE_EXISTING    Opens a file and truncates it so that its size is zero bytes, only if it exists.
                                    If the specified file does not exist, the function fails and the last-error code is set to ERROR_FILE_NOT_FOUND (2).
                                    The calling process must open the file with the GENERIC_WRITE bit set as part of the «DesiredAccess» parameter.
    Return value:
        If the function succeeds, the return value is an open handle to the specified file, device, named pipe, or mail slot.
        If the function fails, the return value is zero. A_LastError contains a system error code.
    Remarks:
        When an application is finished using the object handle returned by OpenFile, use the Kernel32\CloseHandle function to close the handle.
    Why are HANDLE return values so inconsistent?:
        https://devblogs.microsoft.com/oldnewthing/?p=40443
*/
OpenFile(FileName, DesiredAccess := 0, ShareMode := 0, CreationDisposition := 3, SecurityAttributes := 0, FlagsAndAttributes := 0, hTemplateFile := 0)
{
    local Handle := DllCall("Kernel32.dll\CreateFileW", "WStr", FileName             ; lpFileName.
                                                      , "UInt", DesiredAccess        ; dwDesiredAccess.
                                                      , "UInt", ShareMode            ; dwShareMode.
                                                      , "UPtr", SecurityAttributes   ; lpSecurityAttributes.
                                                      , "UInt", CreationDisposition  ; dwCreationDisposition. OPEN_EXISTING.
                                                      , "UInt", FlagsAndAttributes   ; dwFlagsAndAttributes.
                                                      , "UPtr", hTemplateFile        ; hTemplateFile.
                                                      , "Ptr")                       ; Return type.
    return Handle == -1 ? 0 : Handle  ; INVALID_HANDLE_VALUE = -1.
} ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilew


/*
class IOpenFile
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    Handle := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(FileName, DesiredAccess, ShareMode, CreationDisposition, SecurityAttributes, FlagsAndAttributes, hTemplateFile)
    {
        this.Handle := DllCall("Kernel32.dll\CreateFileW", "WStr", FileName             ; lpFileName.
                                                         , "UInt", DesiredAccess        ; dwDesiredAccess.
                                                         , "UInt", ShareMode            ; dwShareMode.
                                                         , "UPtr", SecurityAttributes   ; lpSecurityAttributes.
                                                         , "UInt", CreationDisposition  ; dwCreationDisposition. OPEN_EXISTING.
                                                         , "UInt", FlagsAndAttributes   ; dwFlagsAndAttributes.
                                                         , "UPtr", hTemplateFile        ; hTemplateFile.
                                                         , "Ptr")                       ; Return type.
        this.Ptr := this.Handle
        if (this.Handle == -1)  ; INVALID_HANDLE_VALUE.
            return 0
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        DllCall("Kernel32.dll\CloseHandle", "Ptr", this)
    }
}
*/