/*
    Guarda y restaura la posición de todos los iconos en el escritorio.
    Parámetros:
        Data: Dejar en cero para guardar o especificar para restablecer.
    Return:
        Si va a guardar las posiciones, devuelve un objeto que servirá luego para restaurar las posiciones originales; o una cadena si hubo un error.
        Si va a restaurar las posiciones, devuelve 1 si tuvo éxito, caso contrario devuelve una cadena con el error.
    Ejemplo:
        MsgBox "A_IsAdmin: " . A_IsAdmin
        For ItemText, POINT in Data := DeskIcons()
            Icons .= ItemText . " (" . POINT.x . ";" . POINT.y . ")`n"
        MsgBox "DeskIcons()`n------------------------------`n" . Icons
        DeskIcons(Data)
*/
DeskIcons(Data := 0)    ; CREDITS : https://autohotkey.com/boards/viewtopic.php?f=6&t=3529
{
    static PROCESS_VM_READ     := 0x0010, PROCESS_VM_OPERATION  := 0x0008, PROCESS_VM_WRITE    := 0x0020
         , MEM_COMMIT          := 0x1000, PAGE_READWRITE        := 0x0004 ;, MEM_RELEASE         := 0x8000
         , LVM_GETITEMCOUNT    := 0x1004, LVM_GETITEMPOSITION   := 0x1010, LVM_SETITEMPOSITION := 0x100F, LVM_GETITEMTEXTW := 0x1073

    ; recuperamos el identificador del control SysListView que muestra los iconos en el escritorio
    Local WindowId := GetDeskListView()    ; ControlGetHwnd("SysListView321", "ahk_class Progman")
    If (!WindowId)
        Return "SysListView321?"

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761044(v=vs.85).aspx
    ; recuperamos la cantidad de iconos en el escritorio
    Local ItemCount := DllCall("User32.dll\SendMessageW", "Ptr", WindowId, "UInt", LVM_GETITEMCOUNT, "Ptr", 0, "Ptr", 0)
    If (!ItemCount)
        Return "ItemCount #0"

    Local ProcessId := WinGetPID("ahk_id" . WindowId)    ; recuperamos el identificador del proceso perteneciente al control SysListView
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx
        ; abrimos el proceso para realizar operaciones de lectura y escritura en su memoria
        , hProcess  := DllCall("Kernel32.dll\OpenProcess", "UInt", PROCESS_VM_READ|PROCESS_VM_OPERATION|PROCESS_VM_WRITE, "Int", FALSE, "UInt", ProcessId, "Ptr")
    If (!hProcess)
        Return "OpenProcess ERROR"

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366890(v=vs.85).aspx
    ; reservamos memoria para el proceso para almacenar datos en ella, conociendo su posición en memoria podemos escribir y leer datos de forma segura
    ; para leer y escribir datos en la memoria de otro proceso, debemos utilizar las funciones WriteProcessMemory y ReadProcessMemory, no podemos hacerlo directamente en una variable de nuestro script
    ; ya que la memoria no es compartida y no podemos acceder a la memoria de otro proceso con las funciones incorporadas NumGet/NumPut, solo haría que nuestro Script terminase abruptamente
    ; entonces, reservamos memoria para utilizar de forma segura en el espacio del proceso deseado, la idea no es escribir en cualquier parte de la memoria de otro proceso sino en una solo para nuestro propósito
    ; las funcion "VirtualAllocEx" es como si llamásemos a "VarSetCapacity(VarBuff, size)" en ese proceso y devolviese la dirección de memoria de "VarBuff".
    Local Address := DllCall("Kernel32.dll\VirtualAllocEx", "Ptr", hProcess, "UPtr", 0, "UPtr", A_PtrSize == 4 ? 72 : 88, "UInt", MEM_COMMIT, "UInt", PAGE_READWRITE, "UPtr")    ; espacio para la estructura LVITEM
    Local   pBuff := DllCall("Kernel32.dll\VirtualAllocEx", "Ptr", hProcess, "UPtr", 0, "UPtr", 520, "UInt", MEM_COMMIT, "UInt", PAGE_READWRITE, "UPtr")    ; espacio para almacenar el texto de un elemento (icono)
    If (!Address || !pBuff)
        Return Error("VirtualAllocEx ERROR")

    ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms681674(v=vs.85).aspx
    ; escribimos ciertos datos en la memoria reservada para la estructura LVITEM
    Local NumberOfBytesWritten, NumberOfBytesRead
    ; almacenamos la dirección de mememoria de pBuff en la estructura LVITEM, que debe estar en la posición "16 + A_PtrSize" a partir de "Address"
    ; utilizamos "UPtrP, pBuff" ya que en este parámetro de "WriteProcessMemory" se debe especificar un puntero (dirección de memoria) que contiene los datos a escribir; por lo tanto, sabiendo que pBuff contiene
    ; la dirección de memoria que queremos escribir en "LVITEM", debemos pasar la dirección de memoria que contiene la dirección de memoria almacenada en pBuff, esto es lo mismo que "UPtr, &pBuff"
    DllCall("Kernel32.dll\WriteProcessMemory", "Ptr", hProcess, "UPtr", Address + 16 + A_PtrSize, "UPtrP", pBuff, "UPtr", A_PtrSize, "UPtrP", NumberOfBytesWritten)
    ; luego almacenamos la cantidad de caracteres (UTF-16) máximos que serán escritos, si reservamos memoria para 520 bytes, en caracteres seria 520//2, lo que nos dá 260
    DllCall("Kernel32.dll\WriteProcessMemory", "Ptr", hProcess, "UPtr", Address + 16 + A_PtrSize*2, "IntP", 260, "UPtr", 4, "UPtrP", NumberOfBytesWritten)


    ; ==============================================================================================================
    ; Save
    ; ==============================================================================================================
    Local Buffer, POINT
    VarSetCapacity(Buffer, 520), VarSetCapacity(POINT, 8)
    If (!IsObject(Data))
    {
        Data := {}
        Loop (ItemCount)
        {
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761048(v=vs.85).aspx
            ; recuperamos la posición x,y del icono con el índice "A_Index - 1" y le decimos a "SendMessage" que escriba los datos en la dirección de memoria que contiene "Address"
            ; nota: en este caso, utilizamos "Address" para dos propósitos, almacenar la estructura "POINT" (8 bytes) para recuperar la posición del elemento, y a su vez almacenar a la estructura LVITEM,
            ; que utilizamos mas abajo para recuperar el texto (aprovechamos el espacio reservado, ya que la estructura "POINT" (8 bytes) entra en la estructura "LVITEM" (48+A_PtrSize*3 bytes))
            If (!DllCall("User32.dll\SendMessageW", "Ptr", WindowId, "UInt", LVM_GETITEMPOSITION, "Int", A_Index-1, "UPtr", Address))
                Return Error("LVM_GETITEMPOSITION Index #" . A_Index . " ERROR")

            ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms680553(v=vs.85).aspx
            ; la posición son dos valores (x,y) de 4 bytes c/u (int, estructura POINT), por lo tanto le especificamos a la función "ReadProcessMemory" que lea 8 bytes y almacene los datos leídos en "POINT"
            ; que es una variable que declaramos anteriormente en nuestro script y que puede almacenar hasta 8 bytes, exactamente lo que necesitamos; como aclaramos anteriormente, no podemos leer los datos
            ; directamente de la dirección de memoria almacenada en "Address" ya que esa parte de la memoria no pertenece a nuestro Script y no tenemos privilegios para acceder a ella, "ReadProcessMemory" si los tiene
            If (!DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "UPtr", Address, "UPtr", &POINT, "UPtr", 8, "UPtrP", NumberOfBytesRead))
                Return Error("ReadProcessMemory #1 Index #" . A_Index . " ERROR")

            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761055(v=vs.85).aspx
            ; recuperamos el texto del elemento (icono) en el control SysListView, "LVM_GETITEMTEXTW" escribe el texto en la dirección de memoria que contiene "pBuff", que almacenamos en la estructura "LVITEM"
            ; la estructura "LVITEM", en este caso, estaría representada por "Address", que contiene la dirección de memoria que apunta al comienzo de esta estructura
            If (!DllCall("User32.dll\SendMessageW", "Ptr", WindowId, "UInt", LVM_GETITEMTEXTW, "Int", A_Index-1, "UPtr", Address))
                Return Error("LVM_GETITEMTEXTW Index #" . A_Index . " ERROR")

            ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms680553(v=vs.85).aspx
            ; leemos el texto que se ha escrito en la dirección de memoria que contiene "pBuff" y la escribimos en la dirección de memoria de "Buffer", nuestra variable a la cual si tenemos acceso
            If (!DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "UPtr", pBuff, "UPtr", &Buffer, "UPtr", 520, "UPtrP", NumberOfBytesRead))
                Return Error("ReadProcessMemory #2 Index #" . A_Index . " ERROR")
            
            ; luego, leemos el texto y posición del elemento para guardarlas en el objeto "Data"
            ObjRawSet(Data, StrGet(&Buffer, "UTF-16"), {x: NumGet(&POINT, "Int"), y: Numget(&POINT + 4, "Int")})
        }

        Return Error(Data)    ; OK! devolvemos el objeto "Data", cuyas claves contienen el texto de cada elemento (icono) y su valor la posición de este
    }


    ; ==============================================================================================================
    ; Restore
    ; ==============================================================================================================
    ; aquí restauramos los iconos a la posición almacenada en "Data", se aplica la misma lógica que arriba
    Local ItemText
    Loop (ItemCount)
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761055(v=vs.85).aspx
        If (!DllCall("User32.dll\SendMessageW", "Ptr", WindowId, "UInt", LVM_GETITEMTEXTW, "Int", A_Index-1, "UPtr", Address))
            Return Error("LVM_GETITEMTEXTW Index #" . A_Index . " ERROR")

        ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms680553(v=vs.85).aspx
        If (!DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "UPtr", pBuff, "UPtr", &Buffer, "UPtr", 520, "UPtrP", NumberOfBytesRead))
            Return Error("ReadProcessMemory Index #" . A_Index . " ERROR")

        If (ObjHasKey(Data, ItemText := StrGet(&Buffer, "UTF-16")))    ; determinamos si el texto del elemento actual se encuentra en el objeto "Data"
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761192(v=vs.85).aspx
            ; establecemos la posición del elemento encontrado
            ; The LOWORD specifies the new x-position of the item's upper-left corner, in view coordinates.
            ; The HIWORD specifies the new y-position of the item's upper-left corner, in view coordinates.
            DllCall("User32.dll\SendMessageW", "Ptr", WindowId, "UInt", LVM_SETITEMPOSITION, "Int", A_Index-1, "UPtr", Data[ItemText].x & 0xFFFF | (Data[ItemText].y & 0xFFFF) << 16)
    }
    Return Error(TRUE)    ; OK!


    ; ==============================================================================================================
    ; Nested Functions
    ; ==============================================================================================================
    Error(Msg)
    {
        static MEM_RELEASE := 0x8000
        If (Address)    ; liberamos la memoria reservada Address para la aplicación
            If (!DllCall("Kernel32.dll\VirtualFreeEx", "Ptr", hProcess, "UPtr", Address, "Ptr", 0, "UInt", MEM_RELEASE))
                MsgBox("VirtualFreeEx #1 ERROR!",, 0x2010), ExitApp()
        If (pBuff)    ; liberamos la memoria reservada pBuff para la aplicación
            If (!DllCall("Kernel32.dll\VirtualFreeEx", "Ptr", hProcess, "UPtr", pBuff, "Ptr", 0, "UInt", MEM_RELEASE))
                MsgBox("VirtualFreeEx #2 ERROR!",, 0x2010), ExitApp()
        If (hProcess)    ; cerramos el Handle del proceso
            If (!DllCall("Kernel32.dll\CloseHandle", "Ptr", hProcess))
                MsgBox("CloseHandle ERROR!",, 0x2010), ExitApp()
        Return Msg
    }
}





/*
    Recupera el identificador del control ListView donde se visualizan los iconos en el escritorio.
*/
GetDeskListView()
{
    Local hListView := ControlGetHwnd("SysListView321", "ahk_class Progman")
    If (hListView)
        Return hListView
    If (hListView := DllCall("User32.dll\FindWindowEx", "Ptr", DllCall("User32.dll\FindWindowEx", "Ptr", DllCall("User32.dll\GetShellWindow", "Ptr"), "Ptr", 0, "Str", "SHELLDLL_DefView", "Ptr", 0, "Ptr"), "Ptr", 0, "Str", "SysListView32", "Ptr", 0, "Ptr"))
        Return hListView
    For Each, WindowId in WinGetList("ahk_class WorkerW")    ; WIN_8 && WIN_10
        If (WindowId := DllCall("User32.dll\FindWindowEx", "Ptr", WindowId, "Ptr", 0, "Str", "SHELLDLL_DefView", "Ptr", 0, "Ptr"))
            Return DllCall("User32.dll\FindWindowEx", "Ptr", WindowId, "Ptr", 0, "Str", "SysListView32", "Ptr", 0, "Ptr")
    Return FALSE
}





SetDeskIconPos(ItemName, X, Y)
{
    Local DeskIcons := DeskIcons()
    If (!IsObject(DeskIcons))
        Return DeskIcons

    If (!ObjHasKey(DeskIcons, ItemName))
        Return "ItemName doesn't exist"

    ObjRawSet(DeskIcons, ItemName, {x: x, y: y})
    Return DeskIcons(DeskIcons)
}





GetDeskIconPos(ItemName)
{
    Local DeskIcons := DeskIcons()
    If (!IsObject(DeskIcons))
        Return DeskIcons

    If (!ObjHasKey(DeskIcons, ItemName))
        Return "ItemName doesn't exist"

    Return {X: DeskIcons[ItemName].X, Y: DeskIcons[ItemName].Y}
}
