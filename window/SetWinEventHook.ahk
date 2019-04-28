/*
    Establece una función de enlace de evento para un rango de eventos.
*/
SetWinEventHook(EventMin := 0x00000001, EventMax := 0x7FFFFFFF, hWinEventProc := 0, WinEventProc := "WinEventProc", ProcessId := 0, ThreadId := 0, Flags := 0)
{
    If (!(WinEventProc is "Integer"))
        WinEventProc := CallbackCreate("WinEventProc", "&", 7)
    Return DllCall("User32.dll\SetWinEventHook", "UInt", EventMin, "UInt", EventMax, "Ptr", hWinEventProc, "Ptr", WinEventProc, "UInt", ProcessId, "UInt", ThreadId, "UInt", Flags, "Ptr")
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd373640(v=vs.85).aspx




UnhookWinEvent(hWinEventHook)
{
    Return DllCall("User32.dll\UnhookWinEvent", "Ptr", hWinEventHook)
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd373671(v=vs.85).aspx





/*
SetWinEventHook(0x8000, 0x8001)
Return

WinEventProc(p)
{
    hWinEventHook := NumGet(p, "Ptr")
    Event := NumGet(p + A_PtrSize, "UInt")
    Hwnd := NumGet(p + A_PtrSize * 2, "Ptr")
    ObjectId := NumGet(p + A_PtrSize * 3, "Int")
    ChildId := NumGet(p + A_PtrSize * 4, "Int")
    EventThread := NumGet(p + A_PtrSize * 5, "UInt")
    EventTime := NumGet(p + A_PtrSize * 6, "UInt")

    ToolTip "hWinEventHook: " . hWinEventHook . "`n"
          . "Event: "         . Event         . "`n"
          . "Hwnd: "          . Hwnd          . "`n"
          . "ObjectId: "      . ObjectId      . "`n"
          . "ChildId: "       . ChildId       . "`n"
          . "EventThread: "   . EventThread   . "`n"
          . "EventTime: "     . EventTime     . "`n"
}
*/





/*
#define EVENT_OBJECT_CREATE                   0x8000  // hwnd + ID + idChild is created item
#define EVENT_OBJECT_DESTROY                  0x8001  // hwnd + ID + idChild is destroyed item
#define EVENT_OBJECT_SHOW                     0x8002  // hwnd + ID + idChild is shown item
#define EVENT_OBJECT_HIDE                     0x8003  // hwnd + ID + idChild is hidden item
#define EVENT_OBJECT_REORDER                  0x8004  // hwnd + ID + idChild is parent of zordering children
#define EVENT_OBJECT_FOCUS                    0x8005  // hwnd + ID + idChild is focused item
#define EVENT_OBJECT_SELECTION                0x8006  // hwnd + ID + idChild is selected item (if only one), or idChild is OBJID_WINDOW if complex
#define EVENT_OBJECT_SELECTIONADD             0x8007  // hwnd + ID + idChild is item added
#define EVENT_OBJECT_SELECTIONREMOVE          0x8008  // hwnd + ID + idChild is item removed
#define EVENT_OBJECT_SELECTIONWITHIN          0x8009  // hwnd + ID + idChild is parent of changed selected items
#define EVENT_OBJECT_STATECHANGE              0x800A  // hwnd + ID + idChild is item w/ state change
#define EVENT_OBJECT_LOCATIONCHANGE           0x800B  // hwnd + ID + idChild is moved/sized item
#define EVENT_OBJECT_NAMECHANGE               0x800C  // hwnd + ID + idChild is item w/ name change
#define EVENT_OBJECT_DESCRIPTIONCHANGE        0x800D  // hwnd + ID + idChild is item w/ desc change
#define EVENT_OBJECT_VALUECHANGE              0x800E  // hwnd + ID + idChild is item w/ value change
#define EVENT_OBJECT_PARENTCHANGE             0x800F  // hwnd + ID + idChild is item w/ new parent
#define EVENT_OBJECT_HELPCHANGE               0x8010  // hwnd + ID + idChild is item w/ help change
#define EVENT_OBJECT_DEFACTIONCHANGE          0x8011  // hwnd + ID + idChild is item w/ def action change
#define EVENT_OBJECT_ACCELERATORCHANGE        0x8012  // hwnd + ID + idChild is item w/ keybd accel change
#define EVENT_OBJECT_INVOKED                  0x8013  // hwnd + ID + idChild is item invoked
#define EVENT_OBJECT_TEXTSELECTIONCHANGED     0x8014  // hwnd + ID + idChild is item w? test selection change
#define EVENT_OBJECT_CONTENTSCROLLED          0x8015
#define EVENT_SYSTEM_ARRANGMENTPREVIEW        0x8016
#define EVENT_OBJECT_CLOAKED                  0x8017
#define EVENT_OBJECT_UNCLOAKED                0x8018
#define EVENT_OBJECT_LIVEREGIONCHANGED        0x8019
#define EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED 0x8020
#define EVENT_OBJECT_DRAGSTART                0x8021
#define EVENT_OBJECT_DRAGCANCEL               0x8022
#define EVENT_OBJECT_DRAGCOMPLETE             0x8023
#define EVENT_OBJECT_DRAGENTER                0x8024
#define EVENT_OBJECT_DRAGLEAVE                0x8025
#define EVENT_OBJECT_DRAGDROPPED              0x8026
#define EVENT_OBJECT_IME_SHOW                 0x8027
#define EVENT_OBJECT_IME_HIDE                 0x8028
#define EVENT_OBJECT_IME_CHANGE               0x8029
#define EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED 0x8030
#define EVENT_OBJECT_END                      0x80FF
#define EVENT_AIA_START                       0xA000
#define EVENT_AIA_END                         0xAFFF
*/
