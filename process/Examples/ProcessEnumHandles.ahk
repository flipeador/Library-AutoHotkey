#Include ..\AdjustPrivilege.ahk
#Include ..\ProcessOpen.ahk
#Include ..\ProcessEnumHandles.ahk
#Include ..\ProcessGetImageName.ahk
#Include ..\Object.ahk


AdjustPrivilege(20)  ; SeDebugPrivilege.

HandleList := ProcessEnumHandles()
Buffer     := BufferAlloc(1000000)

Gui := GuiCreate()
LV  := Gui.AddListView("w1250 h675 -LV0x10 LV0x10000 Count" . HandleList.Length()
                     , "Process name|Process ID|Object handle|GrantedAccess|Flags|Attributes|HandleCount|PointerCount|Object type|Object name|File type|File name")

LV.Opt("-Redraw")
FileTypes := {0: "Unknown", 1:"Disk", 2:"Char", 3:"Pipe", 0x8000:"Remote"}
for Each, Item in ProcessEnumHandles()  ; https://social.technet.microsoft.com/Forums/en-US/5b78bf61-4a06-4367-bc28-a9cba3c688b5/howto-enumerate-handles?forum=windowsdevelopment
{
    if Process := ProcessOpen(Item.ProcessId, 0x40|0x1000)  ; PROCESS_DUP_HANDLE|PROCESS_QUERY_LIMITED_INFORMATION.
    {
        Attributes := HandleCount := PointerCount := ObjType := ObjName := FileName := "-"

        ; Duplicate the handle so we can query it.
        if hObject := ObjectDuplicate(-1, Process, Item)
        {
            ; Query the object basic information.
            if ObjectQuery(hObject, 0, {Ptr:Buffer.Ptr,Size:56})  ; OBJECT_BASIC_INFORMATION structure.
            {
                Attributes   := NumGet(Buffer,  0, "UInt")      ; ULONG Attributes.
               ,HandleCount  := NumGet(Buffer,  8, "UInt") - 1  ; ULONG HandleCount.
               ,PointerCount := NumGet(Buffer, 12, "UInt") - 2  ; ULONG PointerCount.
            }

            ; Query the object type.
            if ObjectQuery(hObject, 2, Buffer)  ; OBJECT_TYPE_INFORMATION structure.
                ObjType := StrGet(NumGet(Buffer,A_PtrSize), NumGet(Buffer,"UShort")//2)  ; UNICODE_STRING structure.

            ; Query the object name.
            A_LastError := 0
            FileType    := DllCall("Kernel32.dll\GetFileType", "Ptr", hObject, "UInt")  ; Retrieves the file type of the specified file.
            LastErr     := A_LastError  ; If the function worked properly and FILE_TYPE_UNKNOWN was returned, a call to GetLastError will return NO_ERROR.
            if (FileType !== 0x0003)  ; NtQueryObject may hang on file handles pointing to named pipes.
            {
                if ObjectQuery(hObject, 1, Buffer)  ; UNICODE_STRING structure.
                    ObjName  := StrGet(NumGet(Buffer,A_PtrSize), NumGet(Buffer,"UShort")//2)
                Length   := DllCall("Kernel32.dll\GetFinalPathNameByHandleW", "Ptr", hObject, "Ptr", Buffer, "UInt", Buffer.Size, "UInt", 0)
               ,FileName := StrGet(Buffer, Length, "UTF-16")
            }
            else if (ObjType == "File")
                FileName := "NtQueryObject may hang on file handles pointing to named pipes"

            HandleClose(hObject)
        }
        LV.Add(, ProcessGetImageName(Process), Item.ProcessId, Item.Handle, Format("0x{:08X}",Item.GrantedAccess)
             , Item.Attributes, Attributes, HandleCount, PointerCount, ObjType, ObjName, LastErr?"Error":FileTypes[FileType], LTrim(FileName,"\\?\"))
    }
}
LV.Opt("+Redraw")

Gui.OnEvent("Close", "ExitApp")
Gui.Show()

Gui.Title := Format("ProcessEnumHandles`s({}`sde`s{}) — ({}-Bit)", LV.GetCount(), HandleList.Length(), 8*A_PtrSize)
loop LV.GetCount("Col") - 1
    LV.ModifyCol(A_Index+1, "AutoHdr")
LV.ModifyCol(1, 400)
return
