/*
CoordMode "ToolTip", "Screen"

Timer    := []    ; crea un Array para almacenar los temporizadores

; crea el primer temporizador y pasa una cadena
Timer[1] := new QueueTimer( "TimerFnc1" , 1000,, "Hello World!" )

; crea el segundo temporizador y pasa un objeto
Obj := { Message: "F1 = Start`nF2 = Stop`nF3 = ChangeTimerQueue" }
Timer[2] := new QueueTimer( "TimerFnc2" , 0,, Obj )    ; 0 indica que solo se debe ejecutar una vez
Timer[2].Start()    ; inicia el segundo temporizador

Index := 0
Loop
    ToolTip(++Index, 10, 200, 3), Sleep(1)
Return

F1:: Timer[1].Start()   ; detiene el primer temporizador
F2:: Timer[1].Stop()    ; inicia el primer temporizador
F3:: Timer[1].ChangeTimerQueue( Timer[1].Period == 1000 ? 100 : 1000 )    ; alterna el período del primer temporizador entre 1000 y 100 milisegundos
Esc:: ExitApp    ; escape para terminar

TimerFnc1(Parameter)
{
    local Text := StrGet(Parameter, "UTF-16")
    ToolTip "TickCount: " . A_TickCount . "`nParameter: " . Parameter . " (" . Text . ")"
}

TimerFnc2(Parameter)
{
    local Obj := Object( Parameter )    ; recupera el objeto
    ToolTip Obj.Message, 10, 10, 2
}
*/


class QueueTimer
{
    /*
        Crea un temporizador. Este temporizador expira a la hora especificada, luego después de cada período especificado. Cuando el temporizador expira, se llama a la función de devolución de llamada.
        Parámetros:
            Callback:
                Función de devolución de llamada definida por la aplicación que se ejecutará cuando expire el temporizador.
                Puede especificar una dirección de memoria obtenida previamente por medio de la función incorporada CallbackCreate.
                Puede especificar el nombre u objeto de una función, en cuyo caso se llama a CallbackCreate y al eliminar el objeto de clase se libera automáticamente mediante CallbackFree.
                La función recibe los parámetros descritos a continuación.
                    lpParameter      = Los datos del Thread que se pasaron a la función. Esto es, el valor especificado en el parámetro «Parameter».
                    TimerOrWaitFired = Si es verdadero, pasó el tiempo de espera. Si es falso, el evento de espera ha sido señalizado.
            Period:
                El período del temporizador, en milisegundos. Si este parámetro es cero, el temporizador se señaliza una vez.
                Si este parámetro es mayor que cero, el temporizador es periódico. Un temporizador periódico se reactiva automáticamente cada vez que transcurre el período.
            DueTime:
                El tiempo después del cual el temporizador debe expirar, en milisegundos. Cantidad de tiempo antes de la primer llamada a la función especificada.
            Parameter:
                Un único valor de parámetro que se pasará a la función de devolución de llamada. Por defecto este valor es 0.
                Este parámetro puede ser cualquier tipo de datos, numérico, cadena u objeto. Para recuperar un objeto utilice la función incoporada Object(Address).
                Si el valor no es un valor de tipo entero, el parámetro de la función de devolución de llamada siempre recibe una dirección de memoria a los datos.
        Observaciones:
            Para determinar si el temporizador está activo o no, compruebe el valor de la variable «hQueue», si es distinto de cero, el temporizador está activo.
    */
    __New(Callback, Period := 0, DueTime := 0, Parameter := 0, Flags := 0)
    {
        this.Func      := Callback
        this.Callback  := Type(this.Func) == "Integer" ? this.Func : CallbackCreate(this.Func)
        this.Period    := Integer( Period )
        this.DueTime   := Integer( DueTime )
        this.Flags     := Integer( Flags )
        this.Parameter := Type( Parameter ) == "Float" ? String(Parameter) : Parameter
        this.pData     := Type(Parameter) == "Integer" ? Parameter : IsObject(Parameter) ? &Parameter : ObjGetAddress(this,"Parameter")
        this.hQueue    := this.hTimer := 0
    }

    /*
        Al eliminar el objeto de clase QueueTimer, detiene y elimina el temporizador automáticamente.
    */
    __Delete()
    {
        this.Stop()
        if ( Type( this.Func ) != "Integer" )
            CallbackFree(this.Callback)
    }

    /*
        Inicia el temporizador con los valores definidos al crear el objeto de clase QueueTimer.
        Si el temporizador ya se encuentra activo, primero lo detiene y luego lo vuelve a iniciar.
        La función no devuelve ningún valor. Si ocurre un error se lanza una excepción.
    */
    Start()
    {
        this.Stop()

        ; CreateTimerQueue function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682483(v=vs.85).aspx
        if !( this.hQueue := DllCall("Kernel32.dll\CreateTimerQueue", "Ptr") )
            throw Exception("QueueTimer::Start ERROR", -1, "CreateTimerQueue fails with error " . A_LastError)

        ; CreateTimerQueueTimer function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682485(v=vs.85).aspx
        local hTimer := 0
        DllCall("kernel32.dll\CreateTimerQueueTimer", "PtrP", hTimer, "Ptr", this.hQueue, "UPtr", this.Callback, "Ptr", this.pData, "UInt", this.DueTime, "UInt", this.Period, "UInt", this.Flags)
        if !( this.hTimer := hTimer )
            throw Exception("QueueTimer::Start ERROR", -1, "CreateTimerQueueTimer fails with error " . A_LastError)
    }

    /*
        Cancela y elimina el temporizador. La función no devuelve ningún valor.
        Parámetros:
            CompletionEvent:
                Un identificador para el objeto de evento a ser señalado cuando el sistema ha cancelado el temporizador y todas las funciones de devolución de llamada se han completado.
                Si este parámetro es -1 (INVALID_HANDLE_VALUE), la función espera que las funciones de devolución de llamada del temporizador se completen antes de volver.
                Si este parámetro es 0, la función marca el temporizador para eliminación y regresa inmediatamente.
    */
    Stop(CompletionEvent := 0)
    {
        if ( this.hQueue )
        {
            ; DeleteTimerQueueTimer function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682569(v=vs.85).aspx
            DllCall("Kernel32.dll\DeleteTimerQueueTimer", "Ptr", this.hQueue, "Ptr", this.hTimer, "Ptr", CompletionEvent)

            ; DeleteTimerQueueEx function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682568(v=vs.85).aspx
            DllCall("Kernel32.dll\DeleteTimerQueueEx", "Ptr", this.hQueue, "Ptr", CompletionEvent + (this.hQueue := 0))
        }
    }

    /*
        Actualiza un temporizador con los valores especificados. El temporizador se reiniciará con estos valores.
        Parámetros:
            Period:
                El período del temporizador, en milisegundos. Si este parámetro es cero, el temporizador se señaliza una vez.
                Si este parámetro es mayor que cero, el temporizador es periódico. Un temporizador periódico se reactiva automáticamente cada vez que transcurre el período.
            DueTime:
                El tiempo después del cual el temporizador debe expirar, en milisegundos. Cantidad de tiempo antes de la primer llamada a la función especificada.
        Return:
            Si tiene éxito o el temporizador no esta activo, devuelve el objeto de clase. En caso contrario devuelve cero.
    */
    ChangeTimerQueue(Period := "", DueTime := "")
    {
        ; ChangeTimerQueueTimer function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682004(v=vs.85).aspx
        this.Period  := Period  == "" ? this.Period  : Integer( Period )
        this.DueTime := DueTime == "" ? this.DueTime : Integer( DueTime )
        return this.hQueue ? (DllCall("Kernel32.dll\ChangeTimerQueueTimer", "Ptr", this.hQueue, "Ptr", this.hTimer, "UInt", this.DueTime, "UInt", this.Period) ? this : 0) : this
    }
}
