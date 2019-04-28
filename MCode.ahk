/*
    Genera código máquina.
    Parámetros:
        Code: El código máquina. Debe tener el formato '2,x86:uCoAAADD,x64:uCoAAADD'.
    Return:
        Si tuvo éxito devuelve una dirección de memoria, caso contrario muestra un error y llama a ExitApp con el código de error.
    Referencias:
        MCode Tutorial (Compiled Code in AHK): https://autohotkey.com/boards/viewtopic.php?t=32
    Ejemplo:
        ;C++ C++ C++ C++ C++ C++ C++
        ;   int MyFunction()
        ;   {
        ;       return 42;
        ;   }
        MsgBox(DllCall(MCode('2,x86:uCoAAADD,x64:uCoAAADD'), 'Cdecl'))    ; 42
*/
MCode(Code)
{
    Static Bits := A_PtrSize == 4 ? 'x86' : 'x64'
    If (!RegExMatch(Code, '^([0-9]+),(' . Bits . ':|.*?,' . Bits . ':)([^,]+)', R))
        MCode_Error('Bad input string.', 87)

    Local Flags := {1:4, 2:1}[R[1]]
        , Size  := 0
    If (!DllCall('Crypt32.dll\CryptStringToBinaryW', 'Str', R[3], 'UInt', 0, 'UInt', Flags, 'Ptr', 0, 'UIntP', Size, 'Ptr', 0, 'Ptr', 0))
        MCode_Error('CryptStringToBinary Error.', A_LastError)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366574(v=vs.85).aspx
    Local Ptr := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0, 'UPtr', Size, 'UPtr')
    If (!Ptr)
        MCode_Error('The requested amount of memory could not be allocated.', A_LastError)

    If (Bits == 'x64' && !DllCall('Kernel32.dll\VirtualProtect', 'UPtr', Ptr, 'UPtr', Size, 'UInt', 0x40, 'UIntP', OldProtect))
        MCode_Error('VirtualProtect Error', A_LastError)

    If (DllCall('Crypt32.dll\CryptStringToBinaryW', 'Str', R[3], 'UInt', 0, 'UInt', Flags, 'UPtr', Ptr, 'UIntP', Size, 'Ptr', 0, 'Ptr', 0))
        Return Ptr

    MCode_Error('CryptStringToBinary Error', A_LastError)
} ;https://autohotkey.com/boards/viewtopic.php?t=32


MCode_Error(Message, ExitCode)
{
    MsgBox('An error has occurred and the application will now close.`n'
         . '---------------------------------------------------------`n'
         . 'What: MCode function.`n'
         . 'Message: ' . Message,, 0x2010)
    ExitApp ExitCode
}
