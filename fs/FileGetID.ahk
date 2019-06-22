/*
    Gets the File ID for a valid File/Folder path by uniting the VolumeSerialNumber and FileIndex members of the BY_HANDLE_FILE_INFORMATION structure in a string.
    Parameters:
        Target:
            The name of a existing file or directory, or a File handle/object with read access.
    Return value:
        If the function succeeds, the return value is a string.
        If the function fails, the return value is zero. To get extended error information, check A_LastError.
*/
FileGetID(Target)
{
    local

    Result      := 0
    CloseHandle := Type(Target) == "String"

    if (CloseHandle)
        ; CreateFileW function.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/fileapi/nf-fileapi-createfilew.
        hFile := DllCall("Kernel32.dll\CreateFileW", "UPtr", &Target                           ; lpFileName.
                                                 , "UInt", 0x80000000                        ; dwDesiredAccess: GENERIC_READ.
                                                 , "UInt", 1                                 ; dwShareMode: FILE_SHARE_READ.
                                                 , "UPtr", 0                                 ; lpSecurityAttributes.
                                                 , "UInt", 3                                 ; dwCreationDisposition: OPEN_EXISTING.
                                                 , "UInt", DirExist(Target) ? 0x2000000 : 0  ; dwFlagsAndAttributes: FILE_FLAG_BACKUP_SEMANTICS(0x2000000).
                                                 , "UPtr", 0                                 ; hTemplateFile.
                                                 , "UPtr")
    else
        hFile := IsObject(Target) ? Target.Handle : Target
    
    if (hFile)
    {
        ; BY_HANDLE_FILE_INFORMATION structure.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/fileapi/ns-fileapi-_by_handle_file_information.
        BY_HANDLE_FILE_INFORMATION := BufferAlloc(52)

        ; GetFileInformationByHandle function.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/fileapi/nf-fileapi-getfileinformationbyhandle.
        if DllCall("Kernel32.dll\GetFileInformationByHandle", "Ptr", hFile, "Ptr", BY_HANDLE_FILE_INFORMATION)
        {
            Result := Format("{:08X}-{:08X}{:08X}"  ; 09ABCDEF-09ABCDEF09ABCDEF.
                           , Numget(BY_HANDLE_FILE_INFORMATION, 28, "UInt")   ; dwVolumeSerialNumber.                              
                           , Numget(BY_HANDLE_FILE_INFORMATION, 44, "UInt")   ; nFileIndexHigh.
                           , Numget(BY_HANDLE_FILE_INFORMATION, 48, "UInt"))  ; nFileIndexLow.
        }

        if (CloseHandle)
            DllCall("Kernel32.dll\CloseHandle", "Ptr", hFile)
    }

    return Result
} ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=34607#p159884





; MsgBox(Format("CRC32: 0x{:X}",FileGetID_CRC32(FileSelect())))
FileGetID_CRC32(Target)
{
    ; StrLen("B4D7AD2A-000100000000555B") = 25. The string is always 25 characters long.
    return (Target:=FileGetID(Target)) ? DllCall("NtDll.dll\RtlComputeCrc32","UInt",0,"AStr",Target,"UInt",25,"UInt") : 0
} ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=34607#p242811
