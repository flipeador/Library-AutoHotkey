#Include ..\obj\handle.ahk





/*
    Creates an anonymous pipe.
    Parameters:
        Size:
            The size of the buffer for the pipe, in bytes.
            The size is only a suggestion; the system uses the value to calculate an appropriate buffering mechanism.
            If this parameter is zero, the system uses the default buffer size (4096?).
        InheritHandle:
            Specifies whether the returned handle is inherited when a new process is created
            This parameter can be one or a combination of the following bit flags.
            ┌───────┬──────────────────────────────────────────────────────────────────────┐
            │ Value │ Meaning                                                              │
            ├───────┼──────────────────────────────────────────────────────────────────────┤
            │ 0x00  │ The processes created by this process will not inherit any handles.  │
            │ 0x01  │ The processes created by this process will inherit the read handle.  │
            │ 0x02  │ The processes created by this process will inherit the write handle. │
            └───────┴──────────────────────────────────────────────────────────────────────┘
        PipeAttributes:
            A SECURITY_ATTRIBUTES structure.
    Return value:
        If the function succeeds, the return value is an object with properties hReadPipe and hWritePipe.
        If the function fails, the return value is zero. A_LastError contains extended error information.
    Remarks:
        Anonymous pipes are implemented using a named pipe with a unique name.
        Read more: (https://docs.microsoft.com/en-us/windows/win32/ipc/anonymous-pipes).
*/
PipeCreate(Size := 0, InheritHandle := 0, PipeAttributes := 0)
{
    local hReadPipe := 0, hWritePipe := 0
    if !DllCall("Kernel32.dll\CreatePipe", "UPtrP", hReadPipe       ; PHANDLE               hReadPipe.
                                         , "UPtrP", hWritePipe      ; PHANDLE               hWritePipe.
                                         ,   "Ptr", PipeAttributes  ; LPSECURITY_ATTRIBUTES lpPipeAttributes.
                                         ,  "UInt", Size)           ; DWORD                 nSize,
        return 0

    if (InheritHandle&0x1)
        HandleSetInformation(hReadPipe, 1, 1)
    if (InheritHandle&0x2)
        HandleSetInformation(hWritePipe, 1, 1)

    return {hReadPipe:hReadPipe, hWritePipe:hWritePipe}
} ; https://docs.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-createpipe





/*
    Creates an instance of a named pipe and returns a handle for subsequent pipe operations.
    Return value:
        If the function succeeds, the return value is a handle to the server end of a named pipe instance.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
PipeCreate2(Name, OpenMode := 0, PipeMode := 0, MaxInstances := 255, OutBufferSize := 0, InBufferSize := 0, DefaultTimeOut := 0, SecurityAttributes := 0)
{
    return HandleIsValid(DllCall("Kernel32.dll\CreateNamedPipeW"
        , "WStr", InStr(Name,"\") ? Name : "\\.\pipe\" . Name  ; LPCSTR                lpName.
        , "UInt", OpenMode                                     ; DWORD                 dwOpenMode.
        , "UInt", PipeMode                                     ; DWORD                 dwPipeMode.
        , "UInt", MaxInstances                                 ; DWORD                 nMaxInstances.
        , "UInt", OutBufferSize                                ; DWORD                 nOutBufferSize.
        , "UInt", InBufferSize                                 ; DWORD                 nInBufferSize.
        , "UInt", DefaultTimeOut                               ; DWORD                 nDefaultTimeOut.
        , "UPtr", SecurityAttributes                           ; LPSECURITY_ATTRIBUTES lpSecurityAttributes.
        , "UPtr"))                                             ; HANDLE                ReturnValue.
} ; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea





PipeClose(Pipe)
{
    local
    if (Type(Pipe) == "Array")
        for ThisPipe in Pipe
            PipeClose(ThisPipe)
    else if IsObject(Pipe)
        PipeClose([Pipe.hReadPipe,Pipe.hWritePipe])
    else return HandleClose(Pipe)
}





/*
    Copies data from a named or anonymous pipe into a buffer without removing it from the pipe. It also returns information about data in the pipe.
    Parameters:
        hPipe:
            A handle to a named pipe instance, or it can be a handle to the read end of an anonymous pipe.
            The handle must have GENERIC_READ access to the pipe.
        Buffer:
            A buffer that receives data read from the pipe.
            This parameter can be zero if no data is to be read.
        Bytes:
            The size of the buffer specified by the Buffer parameter, in bytes.
            This parameter is optional when Buffer is a Buffer-like object.
    Return value:
        If the function succeeds, the return value is an object with the following properties.
        ┌──────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        │ Property             │ Meaning                                                                                                │
        ├──────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────┤
        │ BytesRead            │ The number of bytes read from the pipe.                                                                │
        │ TotalBytesAvail      │ The total number of bytes available to be read from the pipe.                                          │
        │ BytesLeftThisMessage │ The number of bytes remaining in this message, zero for byte-type named pipes or for anonymous pipes.  │
        └──────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        If the function fails, the return value is zero. A_LastError contains extended error information.
    Remarks:
        The data is read in the mode specified with Kernel32\CreateNamedPipe.
        The data read from the pipe is not removed from the pipe's buffer.
*/
PeekNamedPipe(hPipe, Buffer := 0, Bytes := "")
{
    Bytes := (Bytes == "") ? (Buffer?Buffer.Size:0) : Bytes
    local BytesRead := 0, TotalBytesAvail := 0, BytesLeftThisMessage := 0
    return DllCall("Kernel32.dll\PeekNamedPipe",   "Ptr", hPipe                  ; HANDLE  hNamedPipe.
                                               ,   "Ptr", Buffer                 ; LPVOID  lpBuffer.
                                               ,  "UInt", Bytes                  ; DWORD   nBufferSize.
                                               , "UIntP", BytesRead              ; LPDWORD lpBytesRead.
                                               , "UIntP", TotalBytesAvail        ; LPDWORD lpTotalBytesAvail.
                                               , "UIntP", BytesLeftThisMessage)  ; LPDWORD lpBytesLeftThisMessage.
         ? {BytesRead:BytesRead,TotalBytesAvail:TotalBytesAvail,BytesLeftThisMessage:BytesLeftThisMessage}  ; Ok.
         : 0                                                                                                ; Error.
} ; https://docs.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-peeknamedpipe?redirectedfrom=MSDN
