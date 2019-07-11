/*
    Sets an event hook function for a range of window events.
    Parameters:
        Callback:
            A machine-code address (CallbackCreate), function name or function object that will receive the events.
            See the WINEVENTPROC callback function: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wineventproc.
        Range:
            This parameter must be a string with two hex values without '0x' separated by a hyphen (-).
            See Event Constants: https://docs.microsoft.com/en-us/windows/win32/winauto/event-constants.
            -----------------------------------------------------
            The first value specifies the event constant for the lowest event value in the range of events that are handled by the hook function.
            This value can be set to 0x00000001 (EVENT_MIN) to indicate the lowest possible event value.
            -----------------------------------------------------
            The second value specifies the event constant for the highest event value in the range of events that are handled by the hook function.
            This value can be set to 0x7FFFFFFF (EVENT_MAX) to indicate the highest possible event value.
    Return value:
        If the function succeeds, the return value is a IWinEventHook class object. Release this object to remove the hook.
        If the function fails, the return value is zero.
*/
WinSetEventHook(Callback, Range, hEventProc := 0, ProcessId := 0, ThreadId := 0, Flags := 0)
{
    Range := StrSplit(Range, "-")
    return new IWinEventHook("0x" . Range[1]
                           , "0x" . Range[2]
                           , hEventProc, Callback
                           , ProcessId, ThreadId, Flags)
}





class IWinEventHook
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static Instances := { }  ; {EventName:{Callbacks:{Callback:0}}}
    static Events    := {CREATE:0x8000,DESTROY:0x8001,SHOW:0x8002,HIDE:0x8003}


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Handle   := 0
    Callback := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Min, Max, hEventProc, EventProc, ProcessId, ThreadId, Flags)
    {
        this.Callback := EventProc is "Number" ? EventProc
                       : IsObject(EventProc)   ? CallbackCreate(EventProc)
                       : CallbackCreate(LTrim(EventProc,"&"), EventProc~="&"?"&":"", 7)

        if ! this.Handle := DllCall("User32.dll\SetWinEventHook", "UInt", Min
                                                                , "UInt", Max
                                                                , "UPtr", hEventProc
                                                                , "UPtr", this.Callback
                                                                , "UInt", ProcessId
                                                                , "UInt", ThreadId
                                                                , "UInt", Flags
                                                                , "UPtr")
            return 0
    } ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwineventhook


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Handle !== 0)
            if ! DllCall("User32.dll\UnhookWinEvent", "Ptr", this.Handle)
                throw Exception("IWinEventHook destructor - User32.dll\UnhookWinEvent", -1)

        if (this.Callback)
            CallbackFree(this.Callback)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-unhookwinevent
}





/*
#define  EVENT_OBJECT_CREATE                             0x8000  // hwnd + ID + idChild is created item
#define  EVENT_OBJECT_DESTROY                            0x8001  // hwnd + ID + idChild is destroyed item
#define  EVENT_OBJECT_SHOW                               0x8002  // hwnd + ID + idChild is shown item
#define  EVENT_OBJECT_HIDE                               0x8003  // hwnd + ID + idChild is hidden item
#define  EVENT_OBJECT_REORDER                            0x8004  // hwnd + ID + idChild is parent of zordering children
#define  EVENT_OBJECT_FOCUS                              0x8005  // hwnd + ID + idChild is focused item
#define  EVENT_OBJECT_SELECTION                          0x8006  // hwnd + ID + idChild is selected item (if only one), or idChild is OBJID_WINDOW if complex
#define  EVENT_OBJECT_SELECTIONADD                       0x8007  // hwnd + ID + idChild is item added
#define  EVENT_OBJECT_SELECTIONREMOVE                    0x8008  // hwnd + ID + idChild is item removed
#define  EVENT_OBJECT_SELECTIONWITHIN                    0x8009  // hwnd + ID + idChild is parent of changed selected items
#define  EVENT_OBJECT_STATECHANGE                        0x800A  // hwnd + ID + idChild is item w/ state change
#define  EVENT_OBJECT_LOCATIONCHANGE                     0x800B  // hwnd + ID + idChild is moved/sized item
#define  EVENT_OBJECT_NAMECHANGE                         0x800C  // hwnd + ID + idChild is item w/ name change
#define  EVENT_OBJECT_DESCRIPTIONCHANGE                  0x800D  // hwnd + ID + idChild is item w/ desc change
#define  EVENT_OBJECT_VALUECHANGE                        0x800E  // hwnd + ID + idChild is item w/ value change
#define  EVENT_OBJECT_PARENTCHANGE                       0x800F  // hwnd + ID + idChild is item w/ new parent
#define  EVENT_OBJECT_HELPCHANGE                         0x8010  // hwnd + ID + idChild is item w/ help change
#define  EVENT_OBJECT_DEFACTIONCHANGE                    0x8011  // hwnd + ID + idChild is item w/ def action change
#define  EVENT_OBJECT_ACCELERATORCHANGE                  0x8012  // hwnd + ID + idChild is item w/ keybd accel change
#define  EVENT_OBJECT_INVOKED                            0x8013  // hwnd + ID + idChild is item invoked
#define  EVENT_OBJECT_TEXTSELECTIONCHANGED               0x8014  // hwnd + ID + idChild is item w? test selection change
#define  EVENT_OBJECT_CONTENTSCROLLED                    0x8015
#define  EVENT_SYSTEM_ARRANGMENTPREVIEW                  0x8016
#define  EVENT_OBJECT_CLOAKED                            0x8017
#define  EVENT_OBJECT_UNCLOAKED                          0x8018
#define  EVENT_OBJECT_LIVEREGIONCHANGED                  0x8019
#define  EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED           0x8020
#define  EVENT_OBJECT_DRAGSTART                          0x8021
#define  EVENT_OBJECT_DRAGCANCEL                         0x8022
#define  EVENT_OBJECT_DRAGCOMPLETE                       0x8023
#define  EVENT_OBJECT_DRAGENTER                          0x8024
#define  EVENT_OBJECT_DRAGLEAVE                          0x8025
#define  EVENT_OBJECT_DRAGDROPPED                        0x8026
#define  EVENT_OBJECT_IME_SHOW                           0x8027
#define  EVENT_OBJECT_IME_HIDE                           0x8028
#define  EVENT_OBJECT_IME_CHANGE                         0x8029
#define  EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED   0x8030
#define  EVENT_OBJECT_END                                0x80FF
#define  EVENT_AIA_START                                 0xA000
#define  EVENT_AIA_END                                   0xAFFF
*/





/*
    An application-defined callback (or hook) function that the system calls in response to events generated by an accessible object. 
    Parameters:
        hWinEventHook:
            Handle to an event hook function.
            This value is returned by SetWinEventHook when the hook function is installed and is specific to each instance of the hook function.
        Event:
            Specifies the event that occurred.
            This value is one of the event constants: https://docs.microsoft.com/en-us/windows/win32/winauto/event-constants.
        hWnd:
            Handle to the window that generates the event, or zero if no window is associated with the event.
            For example, the mouse pointer is not associated with a window.
        ObjectId:
            Identifies the object associated with the event.
            This is one of the object identifiers (https://docs.microsoft.com/windows/desktop/WinAuto/object-identifiers) or a custom object ID.
        ChildId:
            Identifies whether the event was triggered by an object or a child element of the object.
            If this value is 0 (CHILDID_SELF), the event was triggered by the object; otherwise, this value is the child ID of the element that triggered the event.
        EventTime:
            Specifies the time, in milliseconds, that the event was generated.
    WinEventProc(hWinEventHook, Event, hWnd, ObjectId, ChildId, EventThread, EventTime)
*/
