/*
    Realiza una operación de copiar/cortar en los archivos especificados.
    Parámetros:
        Data      : Un único arcivo o un array con varios archivos.
        DropEffect: Una cadena o valor que identifica a la operación a realizar. Este parámetro puede ser Copy o Cut/Move; o un valor.
    Ejemplo:
        MsgBox(SetClipboardDropEffect([A_ComSpec, A_WinDir . "\explorer.exe"], "Copy"))
*/
SetClipboardDropEffect(Data, DropEffect := 0)
{
    If (!DllCall("User32.dll\OpenClipboard", "Ptr", A_ScriptHwnd))
        Return FALSE

    Data := IsObject(Data) ? Data : [Data], DropEffect := InStr(DropEffect, "m")||InStr(DropEffect, "cu") ? 2 : InStr(DropEffect, "co") ? 5 : DropEffect
    Local Size := 20 + 2    ; sizeof(DROPFILES structure) + '\0'
    Loop (ObjLength(Data))
        Size += (StrLen(Data[A_Index]) + 1) * 2    ; (len(data[index]) + '\0') * 2(UTF-16)

    Local hMem  := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x42, "UPtr", Size, "Ptr")    ; DROPFILES + file list
    Local pLock := DllCall("Kernel32.dll\GlobalLock", "Ptr", hMem, "UPtr")

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773269(v=vs.85).aspx
    ; DROPFILES structure
    NumPut(20, pLock, "UInt")    ; DROPFILES.pFiles (the offset of the file list from the beginning of this structure, in bytes)
    NumPut(TRUE, pLock+16, "Int")    ; DROPFILES.fWide (unicode)

    Local Offset := 20    ; begining of the file list
    Loop (ObjLength(Data))
        Offset += StrPut(Data[A_Index], pLock+Offset, StrLen(Data[A_Index]) + 1, "UTF-16") * 2

    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hMem, "UPtr")
    DllCall("User32.dll\EmptyClipboard")
    Local R := DllCall("User32.dll\SetClipboardData", "UInt", 0xF, "Ptr", hMem, "UPtr")    ; CF_HDROP = 0XF

    If (R && DropEffect)
    {
        hMem  := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0x42, "UPtr", 4, "Ptr")
        pLock := DllCall("Kernel32.dll\GlobalLock", "Ptr", hMem, "UPtr")
        NumPut(DropEffect, pLock, "UChar")
        DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hMem, "UPtr")

        R := DllCall("User32.dll\SetClipboardData", "UInt", DllCall("User32.dll\RegisterClipboardFormatW", "Str", "Preferred DropEffect", "UInt")
                                                  ,  "Ptr", hMem, "UPtr")
    }

    DllCall("User32.dll\CloseClipboard")
    Return !!R
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms693457(v=vs.85).aspx





GetClipboardDropEffect()
{
    Local PreferredDropEffect := DllCall("User32.dll\RegisterClipboardFormatW", "Str", "Preferred DropEffect", "UInt")
    If (!DllCall("User32.dll\IsClipboardFormatAvailable", "UInt", PreferredDropEffect))
        Return 0

    Local DropEffect := ""
    If (DllCall("User32.dll\OpenClipboard", "Ptr", A_ScriptHwnd))
    {
        Local hDropEffect := DllCall("User32.dll\GetClipboardData", "UInt", PreferredDropEffect, "UPtr")
        Local pDropEffect := DllCall("Kernel32.dll\GlobalLock", "UPtr", hDropEffect, "UPtr")
        DropEffect := NumGet(pDropEffect, "UChar")
        DllCall("Kernel32.dll\GlobalUnlock", "UPtr", hDropEffect, "UPtr")
        DllCall("User32.dll\CloseClipboard")
    }

    Return DropEffect
}





EnumClipboardFormats()
{
    If (!DllCall("User32.dll\OpenClipboard", "Ptr", A_ScriptHwnd))
        Return FALSE

    Local Formats := [], Format := 0
    While (Format := DllCall("User32.dll\EnumClipboardFormats", "UInt", Format, "UInt"))
        Formats.Push(Format)
    Local LastError := A_LastError

    DllCall("User32.dll\CloseClipboard")
    Return LastError == 0 ? Formats : FALSE    ; ERROR_SUCCESS = 0
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms649038(v=vs.85).aspx





/*
    Recupera el texto seleccionado mediante el uso del portapapeles.
    Parámetros:
        KeepInClip: Si es TRUE el contenido copiado se mantiene en el portapapeles. Si es FALSE el portapapeles se restaura a su contenido original; este es el valor por defecto.
                    Si se especifica 2, devuelve el objeto Clipboard en lugar del texto seleccionado; el cual podrá utilizar para restaurar mas tarde el contenido del portapapeles.
    Return:
        Si «KeepInClip» es 2 devuelve una copia del portapapeles, caso contrario devuelve el texto seleccionado.
    Observaciones:
        Tenga en cuenta que si el portapapeles está ocupado siendo utilizado por otra aplicación el comportamiento de esta función puede no ser el esperado.
*/
GetSelectedText(KeepInClip := FALSE, Timeout := 2)
{
    Local R := 0    ; almacena el valor de retorno de la función ClipWait
        , Content := ""    ; almacena el texto seleccionado
        , ClipSaved := ClipboardAll()    ; almacena una copia con todos los datos actualmente en el portapapeles

    Clipboard := ""    ; vacía el portapapeles
    SendInput("^c")    ; CTRL+C para copiar el texto seleccionado

    If (R := ClipWait(Timeout))    ; espera «Timeout» segundos a que el portapapeles contenga datos, más específicamente texto
        Content := Clipboard    ; almacena el texto del portapapeles en «Content»

    If (!R || !KeepInClip)    ; si ClipWait falló, O si tuvo éxito y «KeepInClip» es FALSE
        Clipboard := ClipSaved    ; restauramos el portapapeles a su contenido original

    Return KeepInClip == 2 ? ClipSaved : Content    ; si «KeepInClip» es 2 devuelve la copia del portapapeles, caso contrario el texto seleccionado
}





/*
    Envia texto utilizando el portapapeles. Este método es mucho más rápido para enviar gran cantidad de texto que SendInput pero tiene sus limitaciones.
    Parámetros:
        String      : La cadena a enviar. Si especifica una cadena vacía, no se realiza ninguna acción.
        RestoreDelay: El retraso, en milisegundos, para restaurar el portapapeles a su contenido original. Por defecto es 500 milisegundos. Si especifica una cadena vacía el portapapeles no será restaurado.
    Observaciones:
        Tenga en cuenta que si el portapapeles está ocupado siendo utilizado por otra aplicación el comportamiento de esta función puede no ser el esperado.
        Si va a enviar una pequeña linea de texto es mas fiable utilizar SendInput. Esta función es para enviar una gran cantidad de texto de forma casi instantánea.
        Si va a enviar una excesiva cantidad de texto, considere aumentar el valor de RestoreDelay para aumentar la fiabilidad.
*/
SendText2(String, RestoreDelay := 500)
{
    Static ClipSaved := 0    ; almacena una copia con todos los datos en el portapapeles; cero si no hay datos

    If (String == "")    ; si «String» es una cadena vacía, devolvemos sin hacer nada
        Return

    If (ClipSaved == 0 && RestoreDelay != "")    ; si no hay ninguna operación pendiende para restaurar el portapapeles y se especificó un tiempo en «RestoreDelay»
        ClipSaved := ClipboardAll()    ; guarda los datos actuales del portapapeles
    Clipboard := String    ; establece el texto deseado en el portapapeles
    SendInput("^v")    ; CTRL+V para pegar el texto

    If (RestoreDelay != "")    ; si se especificó un tiempo en «RestoreDelay»
        SetTimer("RestoreClipboard", -RestoreDelay)    ; creamos un temporizador para la función anidada RestoreClipboard

    RestoreClipboard()    ; esta función anidada será llamada para restaurar el portapapeles cuando pase el tiempo especificado en «RestoreDelay»
    {
        Clipboard := ClipSaved    ; restauramos el portapapeles a sus datos originales
        ClipSaved := 0    ; establecemos «ClipSaved» en cero para indicar que no hay datos para restaurar
    }
}
