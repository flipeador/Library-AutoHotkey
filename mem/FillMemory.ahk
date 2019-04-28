/*
    Rellena un bloque de memoria con el valor especificado.
    Parámetros:
        Destination: Un puntero al bloque de memoria a llenar.
        Length     : El número de bytes en el bloque de memoria a llenar.
        Fill       : El valor para llenar el bloque de memoria de destino. Este valor se copia a cada byte en el bloque de memoria definido por «Destination» y «Length».
    Ejemplo:
        VarSetCapacity(dest, 4), FillMemory(&dest+1, 2, 5)
        MsgBox(NumGet(&dest, "UChar") . NumGet(&dest+1, "UChar") . NumGet(&dest+2, "UChar") . NumGet(&dest+3, "UChar"))    ; 0550
*/
FillMemory(Destination, Length, Fill := 0)
{
    DllCall("NtDll.dll\RtlFillMemory", "UPtr", Destination, "UPtr", Length, "UChar", Fill)
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/wdm/nf-wdm-rtlfillmemory
