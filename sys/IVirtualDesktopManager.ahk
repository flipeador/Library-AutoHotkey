/*
    Expone métodos que permiten a una aplicación interactuar con grupos de ventanas que forman espacios de trabajo virtuales.
*/
Class IVirtualDesktopManager
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        ; IVirtualDesktopManager Interface
        this.IVirtualDesktopManager := ComObjCreate("{AA509086-5CA9-4C25-8F95-589D3C07B48A}", "{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}")
        For Each, Method in ["IsWindowOnCurrentVirtualDesktop","GetWindowDesktopId","MoveWindowToDesktop"]
            ObjRawSet(this, "p" . Method, NumGet(NumGet(this.IVirtualDesktopManager) + (2 + A_Index) * A_PtrSize))

        ; IServiceProvider Interface
        ; CLSID_ImmersiveShell = { 0xC2F03A33, 0x21F5, 0x47FA, 0xB4, 0xBB, 0x15, 0x63, 0x62, 0xA2, 0xF2, 0x39 };
        ; IID_IServiceProvider = { 0x6D5140C1, 0x7436, 0x11CE, 0x80, 0x34, 0x00, 0xAA, 0x00, 0x60, 0x09, 0xFA };
        this.IServiceProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")

        ; IVirtualDesktopManagerInternal Interface
        ; CLSID_VirtualDesktopAPI_Unknown = { 0xC5E0CDCA, 0x7B6E, 0x41B2, 0x9F, 0xC4, 0xD9, 0x39, 0x75, 0xCC, 0x46, 0x7B }
        ; IID_IVirtualDesktopManagerInternal = {0xF31574D6, 0xB682, 0x4CDC, 0xBD, 0x56, 0x18, 0x27, 0x86, 0x0A, 0xBE, 0xC6 };
        ; Note: this is an undocumented interface; Microsoft do not release public API (source http://www.cyberforum.ru/blogs/105416/blog3605.html)
        this.IVirtualDesktopManagerInternal := ComObjQuery(this.IServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{F31574D6-B682-4CDC-BD56-1827860ABEC6}")
        For Each, Method in ["GetCount","MoveViewDesktop","CanViewMoveDesktops","GetCurrentDesktop","GetDesktops","GetAdjacentDesktop","SwitchDesktop","CreateDesktopW","RemoveDesktop","FindDesktop"]
            ObjRawSet(this, "p" . Method, NumGet(NumGet(this.IVirtualDesktopManagerInternal) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/mt186440(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.IVirtualDesktopManager)

        ObjRelease(this.IServiceProvider)
        ObjRelease(this.IVirtualDesktopManagerInternal)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    StringFromGUID(ByRef GUID)
    {
        Local strGUID
        VarSetCapacity(strGUID, (38 + 1) * 2)    ; (StrLen("{00000000-0000-0000-0000-000000000000}") + 1) * 2 = 78
        Local R := DllCall("Ole32.dll\StringFromGUID2", "UPtr", GUID is "Integer" ? GUID : &GUID, "UPtr", &strGUID, "Int", 38 + 1)
        Return R ? StrGet(&strGUID, "UTF-16") : FALSE
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms683893(v=vs.85).aspx

    GUIDFromString(strGUID, ByRef GUID)
    {
        VarSetCapacity(GUID, 0), VarSetCapacity(GUID, 16)
        Return DllCall("Ole32.dll\CLSIDFromString", "UPtr", &strGUID, "UPtr", &GUID, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680589(v=vs.85).aspx

    GUID(ByRef GUID, ByRef a := "")
    {
        If (!IsByRef(a))    ; get guid
        {
            VarSetCapacity(GUID, 0), VarSetCapacity(GUID, 16)
            Return &GUID
        }

        If (GUID is "Integer")    ; pointer
            Return GUID
        If (SubStr(GUID, 1, 1) != "{")    ; reference
            Return &GUID
        this.GUIDFromString(GUID, a)    ; str guid
        Return &a
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Indica si la ventana proporcionada está en el escritorio virtual actualmente activo.
        Parámetros:
            TopLevelWindow  : El identificador de la ventana.
            OnCurrentDesktop: Se establece en TRUE si la ventana está en el escritorio virtual actualmente activo, de lo contrario es FALSE.
        Return:
            Si este método tiene éxito, devuelve S_OK. De lo contrario, devuelve un código de error HRESULT.
    */
    IsWindowOnCurrentVirtualDesktop(TopLevelWindow, ByRef OnCurrentDesktop)
    {
        Return DllCall(this.pIsWindowOnCurrentVirtualDesktop, "UPtr", this.IVirtualDesktopManager, "Ptr", TopLevelWindow, "IntP", OnCurrentDesktop, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/mt186442(v=vs.85).aspx

    /*
        Obtiene el identificador para el escritorio virtual que aloja la ventana de nivel superior proporcionada.
        Parámetros:
            TopLevelWindow: El identificador de la ventana.
            GUID          : Recibe el identificador GUID para el escritorio virtual que alberga el la ventana.
        Return:
            Si este método tiene éxito, devuelve S_OK. De lo contrario, devuelve un código de error HRESULT.
    */
    GetWindowDesktopId(TopLevelWindow, ByRef GUID)
    {
        Local R := DllCall(this.pGetWindowDesktopId, "UPtr", this.IVirtualDesktopManager, "Ptr", TopLevelWindow, "UPtr", this.GUID(GUID), "UInt")
        GUID := R == 0 ? this.StringFromGUID(GUID) : ""
        Return R
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/mt186440(v=vs.85).aspx

    /*
        Mueve una ventana al escritorio virtual especificado.
        Parámetros:
            TopLevelWindow : El identificador de la ventana.
            GUID           : El identificador GUID del escritorio virtual a donde mover la ventana. Este valor puede ser un puntero o una referencia.
        Return:
            Si este método tiene éxito, devuelve S_OK. De lo contrario, devuelve un código de error HRESULT.
    */
    MoveWindowToDesktop(TopLevelWindow, ByRef GUID)
    {
        Return DllCall(this.pMoveWindowToDesktop, "UPtr", this.IVirtualDesktopManager, "Ptr", TopLevelWindow, "UPtr", this.GUID(GUID, t), "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/mt186443(v=vs.85).aspx

    ; --------------------------------------------

    GetCount(ByRef Count)
    {
        Return DllCall(this.pGetCount, "UPtr", this.IVirtualDesktopManagerInternal, "UIntP", Count, "UInt")
    }
}
