class AHkInstance
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Instances := { }
    static _Client   := 0
    static AhkPath   := A_AhkPath

    static STATE_STOPPED       := 0x00
    static STATE_RUNNING       := 0x01
    static STATE_STOP_PENDING  := 0x02
    static STATE_START_PENDING := 0x03


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    ScriptCode          := ""
    State               := 0    ; Subprocess state.
    Subprocess          := ""   ; Subprocess class object.
    fWaitForTermination := ""   ; Subprocess.RegisterWaitForTermination(fWaitForTermination).
    Name                := ""


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Name)
    {
        global AHkInstance
        local

        if Type(Name) !== "String"
        || Name ~= "\s+"
        || StrLen(Name) < 1 || StrLen(Name) > 32
            throw Exception("AHkInstance class, constructor.", -1, "Invalid parameter #1.")
        this.Name := Name

        if AHkInstance.Instances.Count() == 0
        {
            AHkInstance._Client := new AHkInstance.Client()
        }

        for _Name in AHkInstance.Instances
            if _Name = Name
                throw Exception("AHkInstance class, constructor.", -1, "An object with the specified name already exists.")

        AHkInstance.Instances[this.Name] := 0
        this.fWaitForTermination         := (x,y) => this.WaitOrTimerCallback(x,y)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    WaitOrTimerCallback(lpParameter, TimerOrWaitFired)
    {
        this.State  := AHkInstance.STATE_STOP_PENDING
        this.hTimer := Func("Timer")
        SetTimer(this.hTimer, -50)  ; Leave time for Return.
                                    ; The RegisterWaitForTermination timer must be deleted once the callback function returns.
                                    ; In other words, UnregisterWait should not be called within the timer callback function.
        return 0
        
        Timer()
        {
            SetTimer(this.hTimer, "Delete")
            this._Terminate(0)
        }
    }

    _Terminate(ExitCode)
    {
        this.Subprocess.Terminate(ExitCode)
        this.Subprocess.UnregisterWait()
        this.Subprocess.Close()
        AHkInstance.Instances[this.Name] := 0
        this.State := AHkInstance.STATE_STOPPED
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Close()
    {
        this.Terminate()
        this.fWaitForTermination := ""

        AHkInstance.Instances.Delete(this.Name)
        if AHkInstance.Instances.Count() == 0
        {
            AHkInstance._Client.Close()
            AHkInstance._Client := ""
        }

        this.base := ObjSetCapacity(this, 0*ObjDelete(this,"",Chr(0x10FFFF)))  ; Invalidate this object.
    }
    
    SetAhkPath(AhkPath)
    {
        if DirExist(AhkPath) || !FileExist(AhkPath)
            throw Exception("AHkInstance class, SetAhkPath method.", -1, "The specified file doesn't exist.")
        this.AhkPath := AhkPath
    }

    AddCode(Code, Flags := 0)
    {
        this.ScriptCode := ( Flags & 0x01 && !(Flags & 0x02) ? this.ScriptCode : "" )
                         . ( Code )
                         . ( Flags & 0x01 || Flags & 0x02 ? "" : this.ScriptCode )
                         . ( Flags & 0x04 ? "`n" : "")
    }

    Exec(CommandLine := "", WorkingDir := "", Flags := 0)
    {
        global AHkInstance
        local

        while this.State == AHkInstance.STATE_STOP_PENDING
           || this.State == AHkInstance.STATE_START_PENDING
            Sleep(75)

        if this.State !== AHkInstance.STATE_STOPPED
            return this.Subprocess.ProcessId
        this.State := AHkInstance.STATE_START_PENDING

        try
        {
            #Include Server.ahk
            this.Subprocess := ExecScript(Code . "`n" . this.ScriptCode  ; Script.
                                        , CommandLine                    ; CommandLine.
                                        , WorkingDir                     ; WorkingDir.
                                        , this.AhkPath                   ; AhkPath.
                                        , Flags|0x4)                     ; CreationFlags. CREATE_SUSPENDED = 0x4.
        }
        catch Exception
        {
            this.State := AHkInstance.STATE_STOPPED
            throw Exception(Exception.Message, -1, Exception.Extra)
        }

        this.Subprocess.RegisterWaitForTermination(this.fWaitForTermination)
        if !(Flags & 0x00000004)  ; CREATE_SUSPENDED.
            this.Subprocess.ResumeThread()
        this.State := AHkInstance.STATE_RUNNING

        return this.Subprocess.ProcessId
    }

    Terminate(ExitCode := 0)
    {
        while this.State == AHkInstance.STATE_STOP_PENDING
            Sleep(75)

        if this.State == AHkInstance.STATE_STOPPED
            return

        if this.State == AHkInstance.STATE_START_PENDING
        {
            while this.State == AHkInstance.STATE_START_PENDING
                Sleep(75)
            Sleep(75)
        }

        this._Terminate(ExitCode)
    }

    /*
        Terminates the subprocess as if the script executes ExitApp.
    */
    ExitApp(ExitCode := 0)
    {
        while this.State == AHkInstance.STATE_STOP_PENDING
            Sleep(75)

        if this.State == AHkInstance.STATE_STOPPED
            return TRUE

        if this.State == AHkInstance.STATE_START_PENDING
        {
            while this.State == AHkInstance.STATE_START_PENDING
                Sleep(75)
            Sleep(75)
        }

        AHkInstance.GetActiveObject(this.Name).Call("SetTimer", "ExitApp", -75)
        return this.Subprocess.WaitClose(5)
    }

    Suspend()
    {
        while this.State == AHkInstance.STATE_STOP_PENDING
           || this.State == AHkInstance.STATE_START_PENDING
            Sleep(75)

        if this.State == AHkInstance.STATE_STOPPED
            return 0

        return DllCall("Ntdll.dll\NtSuspendProcess", "Ptr", this.Subprocess.hProcess)
    }

    Resume()
    {
        while this.State == AHkInstance.STATE_STOP_PENDING
           || this.State == AHkInstance.STATE_START_PENDING
            Sleep(75)

        if this.State == AHkInstance.STATE_STOPPED
            return 0

        return DllCall("Ntdll.dll\NtResumeProcess", "Ptr", this.Subprocess.hProcess)
    }

    GetActiveObject(Name := "")  ; Static.
    {
        if !AHkInstance.Instances.HasKey(Name)
            return 0

        local TickCount := A_TickCount
        while AHkInstance.Instances[Name] == 0
        {
            if (A_TickCount-TickCount) > 5000
                return 0
            Sleep(75)
        }

        return ComObjActive(AHkInstance.Instances[Name])
    }


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    #Include Client.ahk
}

