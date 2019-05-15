/*
    MCode Tutorial (Compiled Code in AHK) - https://autohotkey.com/boards/viewtopic.php?t=32.
*/
MCode(Code)
{
    local

    R := 0, t := 0
    if !RegExMatch(Code,Format("^([0-9]+),({1}:|.*?,{1}:)([^,]+)",A_PtrSize=4?"x86":"x64"),R)
        throw Exception("MCode function.", -1)

    Flags := {1:4, 2:1}[R[1]], Size  := 0
    If !DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", R[3], "UInt", 0, "UInt", Flags, "Ptr", 0, "UIntP", Size, "Ptr", 0, "Ptr", 0)
        throw Exception("MCode function.", -1, "CryptStringToBinaryW.")

    if !(Ptr := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0, "Ptr", Size, "Ptr"))
        throw Exception("MCode function.", -1, "GlobalAlloc.")

    If (A_PtrSize > 4 && !DllCall("Kernel32.dll\VirtualProtect", "UPtr", Ptr, "UPtr", Size, "UInt", 0x40, "UIntP", t))
        throw Exception("MCode function.", -1, "VirtualProtect.")

    If DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", R[3], "UInt", 0, "UInt", Flags, "UPtr", Ptr, "UIntP", Size, "Ptr", 0, "Ptr", 0)
        Return Ptr

    throw Exception("MCode function.", -1, "CryptStringToBinaryW.")
} ; https://autohotkey.com/boards/viewtopic.php?t=32





; int _stdcall f() { return 42; }
; MsgBox(DllCall(MCode("2,x86:uCoAAADD,x64:uCoAAADD")))
