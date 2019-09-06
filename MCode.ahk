MCode(x32, x64)
{
    local Code := A_PtrSize == 4 ? x32 : x64
    local Size := 0
    DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", Code, "UInt", 0, "UInt", 1, "Ptr", 0, "UIntP", Size, "Ptr", 0, "Ptr", 0)

    local Ptr := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0, "Ptr", Size, "Ptr")
    if (A_PtrSize == 8)
        DllCall("Kernel32.dll\VirtualProtect", "Ptr", Ptr, "Ptr", Size, "UInt", 0x40, "UIntP", 0)

    DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", Code, "UInt", 0, "UInt", 1, "Ptr", Ptr, "UIntP", Size, "Ptr", 0, "Ptr", 0)
    return Ptr
} ; https://autohotkey.com/boards/viewtopic.php?t=32





/*
MCode(Code)
{
    local
    R := 0, t := 0, ptr := 0
    if RegExMatch(Code,Format("^([0-9]+),({1}:|.*?,{1}:)([^,]+)",A_PtrSize=4?"x86":"x64"),R) {
    Flags := {1:4, 2:1}[R[1]], Size  := 0
    DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", R[3], "UInt", 0, "UInt", Flags, "Ptr", 0, "UIntP", Size, "Ptr", 0, "Ptr", 0)
    Ptr := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0, "Ptr", Size, "Ptr")
    if (A_PtrSize == 8)
        DllCall("Kernel32.dll\VirtualProtect", "Ptr", Ptr, "UPtr", Size, "UInt", 0x40, "UIntP", t)
    DllCall("Crypt32.dll\CryptStringToBinaryW", "Str", R[3], "UInt", 0, "UInt", Flags, "Ptr", Ptr, "UIntP", Size, "Ptr", 0, "Ptr", 0)
    } return Ptr
} ; https://autohotkey.com/boards/viewtopic.php?t=32
*/
