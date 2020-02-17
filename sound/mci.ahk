/*
    The Media Control Interface (MCI) provides standard commands for playing multimedia devices and recording multimedia resource files.
    These commands are a generic interface to nearly every kind of multimedia device.

    Reference:
        https://docs.microsoft.com/en-us/windows/win32/multimedia/mci

    Multimedia Command Strings:
        https://docs.microsoft.com/en-us/windows/win32/multimedia/multimedia-command-strings

    Multimedia Commands:
        https://docs.microsoft.com/en-us/windows/win32/multimedia/multimedia-commands

    MCIERR Return Values:
        https://docs.microsoft.com/en-us/windows/win32/multimedia/mcierr-return-values

    The Wait, Notify, and Test Flags:
        https://docs.microsoft.com/en-us/windows/win32/multimedia/the-wait-notify-and-test-flags
*/





/*
    Sends a command string to the specified MCI device (command-string interface).
    The device that the command is sent to is specified in the command string.
    Parameters:
        Command:
            A string that specifies an MCI command string.
            For a list, see Multimedia Command Strings.
            This parameter can be an array; See function MCI_FormatCommand.
        Callback:
            A handle to a callback window if the "notify" flag was specified in the command string.
    Return value:
        If the function succeeds, the return value is a string that receives return information.
        If the function fails, an exception is thrown describing the error.
    ErrorLevel:
        The low-order word contains the error return value.
        If the error is device-specific, the high-order word is the driver identifier; otherwise is zero.
        For a list of possible error values, see MCIERR Return Values.
        -------------------------------------------------------------------------------------------
        To retrieve a text description of return values, pass ErrorLevel to the MCI_GetErrorString function.
    Using MCI Command Strings:
        https://docs.microsoft.com/en-us/windows/win32/multimedia/using-mci-command-strings
*/
MCI_SendString(Command, Callback := 0)
{
    local ReturnString := BufferAlloc(2*128)  ; Each data or error description that MCI returns, can be a maximum of 128 characters.
    if ErrorLevel := DllCall("Winmm.dll\mciSendStringW", "WStr", MCI_FormatCommand(Command)  ; String that specifies an MCI command.
                                                       , "UPtr", ReturnString.Ptr            ; Buffer that receives return information.
                                                       , "UInt", ReturnString.Size//2        ; Size, in characters, of the return buffer.
                                                       , "UPtr", Callback                    ; Handle to a callback window.
                                                       , "UInt")                             ; Return value.
        throw Exception("MCI - " . (MCI_GetErrorString(ErrorLevel)||"Unknown error."), -1, "MCI_SendString error " . ErrorLevel . ".")
    return StrGet(ReturnString)  ; Ok.
} ; https://docs.microsoft.com/en-us/previous-versions//dd757161(v=vs.85)





/*
    Sends a command message to the specified MCI device (command-message interface).
    Parameters:
        DeviceID:
            MCI device identifier that is to receive the command message.
            This parameter can be the device name or the alias name by which the device is known.
            This parameter is not used with the MCI_OPEN command message.
        Message:
            The command message. For a list, see Multimedia Commands.
        Data:
            A structure that contains parameters for the command message.
            This parameter must be a pointer or a Buffer-like object.
        Flags:
            Flags for the command message.
            This parameter can be MCI_NOTIFY, MCI_WAIT, or, for digital-video and VCR devices, MCI_TEST.
            For more information about these flags, see The Wait, Notify, and Test Flags.
    Return value:
        If the function succeeds, the return value is «Data».
        If the function fails, see the MCI_SendString function.
    Using MCI Command Messages
        https://docs.microsoft.com/en-us/windows/win32/multimedia/using-mci-command-messages
*/
MCI_SendCommand(DeviceID, Message, Data, Flags := 0)
{
    if ErrorLevel := DllCall("Winmm.dll\mciSendCommandW", "UInt", MCI_GetDeviceID(DeviceID)  ; MCI device identifier.
                                                        , "UInt", Message                    ; Command message.
                                                        , "UPtr", Flags                      ; Flags for the command message.
                                                        ,  "Ptr", Data                       ; Structure containing command message's parameters.
                                                        , "UInt")                            ; Return value.
        throw Exception("MCI - " . (MCI_GetErrorString(ErrorLevel)||"Unknown error."), -1, "MCI_SendCommand error " . ErrorLevel . ".")
    return Data
} ; https://docs.microsoft.com/en-us/previous-versions//dd757160(v=vs.85)





/*
    Retrieves the device identifier corresponding to the name of an open device or element identifier.
    Parameters:
        Device:
            A string that specifies the device name or the alias name by which the device is known.
            If this parameter is of type Integer, the function returns this value.
            This parameter can be an object with an Alias property.
            ---------------------------------------------------------------------------------------
            If parameter Type is specified, «Device» is the element identifier.
        Type:
            A string specifying the type name that corresponds to the element identifier.
    Return value:
        Returns the device identifier assigned to the device when it was opened if successful.
        If the device name is not known, not open, or if there was not enough memory to complete the operation, the return value is zero.
*/
MCI_GetDeviceID(Device, Type := 0)
{
    if (Type)  ; https://docs.microsoft.com/en-us/previous-versions//dd757157(v=vs.85)
        return DllCall("Winmm.dll\mciGetDeviceIDFromElementIDW", "UInt", Device, "Str", Type, "UInt")
    return (Type(Device) == "Integer")
         ? Device
         : DllCall("Winmm.dll\mciGetDeviceIDW", "Str", IsObject(Device)?Device.Alias:Device, "UInt")
} ; https://docs.microsoft.com/en-us/previous-versions//dd757156(v=vs.85)





/*
    Retrieves a handle to the creator task for the specified device.
    Parameters:
        DeviceID:
            MCI device identifier for which the creator task is returned.
            This parameter can be the device name or the alias name by which the device is known.
    Return value:
        If the function succeeds, the return value the handle of the creator task responsible for opening the device.
        If the device identifier is invalid, the return value is zero.
*/
MCI_GetCreatorTask(DeviceID)
{
    return DllCall("Winmm.dll\mciGetCreatorTask", "UInt", MCI_GetDeviceID(DeviceID), "UPtr")
} ; https://docs.microsoft.com/en-us/previous-versions//dd757155(v=vs.85)





/*
    Retrieves the address of the callback function associated with the MCI_WAIT flag.
    The callback function is called periodically while an MCI device waits for a command specified with the MCI_WAIT flag to finish.
    Parameters:
        DeviceID:
            MCI device identifier being monitored (the device performing an MCI command).
            This parameter can be the device name or the alias name by which the device is known.
        YieldData:
            A buffer containing yield data to be passed to the callback function.
            This parameter can be zero or omitted if there is no yield data.
    Return value:
        If the function succeeds, the return value the address of the current yield callback function.
        If the device identifier is invalid, the return value is zero.
*/
MCI_GetYieldProc(DeviceID, YieldData := 0)
{
    return DllCall("Winmm.dll\mciGetYieldProc", "UInt", MCI_GetDeviceID(DeviceID)  ; MCI device identifier being monitored.
                                              ,  "Ptr", YieldData                  ; Pointer to a buffer containing yield data.
                                              , "UPtr")                            ; Return value.
} ; https://docs.microsoft.com/en-us/previous-versions//dd757159(v=vs.85)





/*
    Sets the address of a procedure to be called periodically when an MCI device is waiting for a command to finish because the MCI_WAIT flag was specified.
    Parameters:
        DeviceID:
            MCI device identifier to assign a procedure to.
            This parameter can be the device name or the alias name by which the device is known.
        Callback:
            Pointer to the procedure to call when yielding for the specified device.
            If this parameter is zero, the function disables any existing yield procedure.
        YieldData:
            Data to be sent to the yield procedure when it is called for the specified device.
    Return value:
        Returns TRUE if successful or FALSE otherwise.
    Remarks:
        This function overrides any previous yield procedure for this device.
*/
MCI_SetYieldProc(DeviceID, Callback, YieldData := 0)
{
    return DllCall("Winmm.dll\mciSetYieldProc", "UInt", MCI_GetDeviceID(DeviceID)  ; MCI device identifier to assign a procedure to.
                                              , "UPtr", Callback                   ; Pointer to the procedure to call.
                                              , "UInt", YieldData)                 ; Data to be sent to the yield procedure.
} ; https://docs.microsoft.com/en-us/previous-versions//dd757163(v=vs.85)





/*
    Retrieves a string that describes the specified MCI error code.
    Parameters:
        ErrorCode:
            An error code returned by the MCI_SendCommand or MCI_SendString function.
    Return value:
        If the function succeeds, the return value is a string describing the specified error.
        If the error code is not known, the return value is zero.
*/
MCI_GetErrorString(ErrorCode)
{
    local Buffer := BufferAlloc(2*128)  ; 128 characters (max).
    return DllCall("Winmm.dll\mciGetErrorStringW", "UInt", ErrorCode
                                                 , "UPtr", Buffer.Ptr
                                                 , "UInt", Buffer.Size//2
                                                 , "UInt")
           ? StrGet(Buffer)  ; Ok.
           : 0               ; Error.
} ; https://docs.microsoft.com/en-us/previous-versions//dd757158%28v%3dvs.85%29





/*
    Retrieves the device type of a file.
    Parameters:
        FileName:
            A file name or extension.
    Return value:
        If the function succeeds, the return value is a string describing the device type.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
MCI_GetDeviceType(FileName)
{
    local r, DeviceType := RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI Extensions"
        , (RegExMatch(FileName,"\.(\w+)$",r)&&r[1])||FileName)
    return ErrorLevel ? 0 : DeviceType
}





/*
    Function used internally by function MCI_SendString.
    [1,2,3]        => '1 2 3'
    ["a b",2,"c"]  => '"a b" 2 c'
    ["*x y","z n"] => 'x y "z n"'
    ["  *  x y"]   => 'x y'
*/
MCI_FormatCommand(Command)  ; Private.
{
    local param, cmd := ""
    for param in (IsObject(Command) ? Command : Map())
        param := Trim(param), cmd .= (param~="^\s*$")||(param=="*")
        ? "":(((param~="\s+")&&(!(param~="^\*")))
        ? "`"" . Trim(param) . "`"":Trim(LTrim(param,"*"))) . A_Space
    return IsObject(Command) ? Trim(cmd) : Trim(Command)
}





/*
    Initializes a device.
    Parameters:
        Device:
            Identifier of an MCI device or device driver.
            This can be either a device name as given in the registry or the filename of the device driver.
        OpenFlags:
            Flag that identifies what to initialize.
            If «Device» specifies a filename, this parameter can be omitted.
        Flags:
            Can be "wait", "notify", or both. For digital-video and VCR devices, "test" can also be specified.
            Wait:
                MCI commands usually return to the user immediately, even if it takes several minutes to complete the action initiated by the command.
                Wait can be used to direct the device to wait until the requested action is completed before returning control to the application.
                -----------------------------------------------------------------------------------
                The user can cancel a wait operation by pressing a break key. By default, this key is CTRL+BREAK.
                Applications can redefine this key by using the break (MCI_BREAK) command.
                When a wait operation is canceled, MCI attempts to return control to the application without interrupting the command associated with the "wait" flag.
            ---------------------------------------------------------------------------------------
            For more information about these flags, see The Wait, Notify, and Test Flags.
    Return value:
        If the function succeeds, the return value is a new instance of an IMediaControl class object.
        If the function fails, see the MCI_SendString function.
    Remarks:
        By default, an alias is assigned to the open device.
        This alias consists of the memory address of the new instance of an IMediaControl class object.
        You can directly pass the returned object in functions that expect a DeviceID parameter.
*/
MCI_Open(Device, OpenFlags := "", Flags := "")
{
    local obj := IMediaControl.New()
    return ((OpenFlags == "")
         ? MCI_SendString(["open",Device,"type",MCI_GetDeviceType(Device)||"MPEGVideo","alias",&obj,"*" . Flags])
         : MCI_SendString(["open",Device,"*" . OpenFlags,"alias",&obj,"*" . Flags])) && obj
} ; https://docs.microsoft.com/en-us/windows/win32/multimedia/open





/*
    Use the MCI_Open function to initialize an instance of this class object.
    Remarks:
        For information about the Flags parameter see the MCI_Open function.
        For the other parameters not described, see the link included in each method.
*/
class IMediaControl
{
    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        try this.Close()
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    /*
        Sends a command string to this MCI device (command-string interface).
        See the MCI_SendString function.
    */
    SendString(Command, Flags := "", Params := "")
    {
        return MCI_SendString([Command,this.Alias,Format("*{}`s{}",Params,Flags)])
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Closes the device or file and any associated resources.
    */
    Close(Flags := "")
    {
        return this.SendString("close", Flags)
    } ; https://docs.microsoft.com/en-us/windows/win32/multimedia/close

    /*
        Starts playing a device.
    */
    Play(PlayFlags := "", Flags := "")
    {
        return this.SendString("play", Flags, PlayFlags)
    } ; https://docs.microsoft.com/en-us/windows/win32/multimedia/play

    /*
        Pauses playing or recording.
        Most drivers retain the current position and eventually resume playback or recording at this position.
    */
    Pause(Flags := "")
    {
        return this.SendString("pause", Flags)
    } ; https://docs.microsoft.com/en-us/windows/win32/multimedia/pause

    /*
        Continues playing or recording on a device that has been paused.
    */
    Resume(Flags := "")
    {
        return this.SendString("resume", Flags)
    } ; https://docs.microsoft.com/en-us/windows/win32/multimedia/resume

    /*
        Requests status information from a device.
        Remarks:
            Before issuing any commands that use position values, you should set the desired time format by using the Set method.
    */
    GetStatus(Request, Flags := "")
    {
        return this.SendString("status", Flags, Request)
    } ; https://docs.microsoft.com/en-us/windows/win32/multimedia/status

    /*
        Establishes control settings for the device.
    */
    Set(Setting, Flags := "")
    {
        return this.SendString("set", Flags, Setting)
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Retrieves the alias assigned when the device was opened.
    */
    Alias[] => String(&this)
}
