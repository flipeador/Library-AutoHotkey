/*
    Enumera todas las ventanas o solo las ventanas hijas que pertenecen a la ventana padre especificada.
    Parámetros:
        ParentID: El identificador de la ventana padre. Si este valor es 0, se enumeran todas las ventanas.
        Visible : Si este valor es TRUE, solo se enumeran las ventanas visibles.
    Return:
        Si tuvo éxito devuelve un array con los identificadores de las ventanas. El array puede estar vacío si no se encontraron ventanas.
        Si hubo un error devuelve cero.
    Ejemplo:
        For Each, WindowId in EnumWindows(0, TRUE)
            List .= "[" . WindowId . "] " . WinGetClass("ahk_id" . WindowId) . "`n"
        MsgBox List
*/
EnumWindows(ParentID := 0, Visible := FALSE)
{
    ; thanks to Helgef (https://autohotkey.com/boards/viewtopic.php?f=37&t=46150#p208757)
    Static EnumChildProc := (List,Visible,p) => !Visible || DllCall("User32.dll\IsWindowVisible", "Ptr", p:=NumGet(p, "Ptr")) ? List.Push(p) : 1

    Local           List := []    ; este objeto almacenará la lista de identificadores de cada ventana
        , pEnumChildProc := CallbackCreate(EnumChildProc.Bind(List, Visible), "F&", 2)

    Local R := DllCall("User32.dll\EnumChildWindows", "Ptr", ParentID, "UPtr", pEnumChildProc, "UPtr", 0)

    CallbackFree(pEnumChildProc)    ; liberamos la memoria reservada para la función EnumChildProc

    Return R ? List : FALSE
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633494(v=vs.85).aspx





; WIN_8+
WinHwndList(Desktop := 0, Parent := 0, EnumChildren := FALSE, RemoveImmersive := FALSE, Thread := 0)
{
    local Buffer, Count, NtStatus := DllCall("win32u\NtUserBuildHwndList"
        , "Ptr"  , Desktop                                 ; hDesktop
        , "Ptr"  , Parent                                  ; hWndParent
        , "Int"  , !!EnumChildren                          ; bEnumChildren
        , "Int"  , !!RemoveImmersive                       ; bRemoveImmersive
        , "UInt" , Thread                                  ; dwThreadId
        , "UInt" , 32767                                   ; uMax
        , "Ptr"  , Buffer := BufferAlloc(32767*A_PtrSize)  ; pHwndList
        , "UIntP", Count  := 0                             ; pCount (out)
        , "UInt")  ; NTSTATUS value (return) | NOERROR(0x00000000) |⠀STATUS_BUFFER_TOO_SMALL(0xC0000023)
    local HwndList := []
    loop Count := (NtStatus == 0x00000000) && Count
        HwndList.Push(NumGet(Buffer,(A_Index-1)*A_PtrSize,"UPtr"))
    return Count && HwndList  ; 0(FAILURE) |⠀[](SUCCESS)
}
