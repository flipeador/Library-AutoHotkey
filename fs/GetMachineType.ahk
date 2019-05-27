/*
    Retrieves the CPU type on which the specified file has been designed to be executed.
    Parameters:
        FileName:
            The name of a file, file handle or file object whose CPU type is to be determined.
    Return value:
        Returns -1 if the specified file does not exist or could not be opened for reading.
        Returns -2 if The specified file is invalid.
        If the function is succeeds, it returns the machine architecture. These are some possible values.
        0x0000  IMAGE_FILE_MACHINE_UNKNOWN           Unknown.
        0x01D3  IMAGE_FILE_MACHINE_AM33              TAM33BD.
        0x8664  IMAGE_FILE_MACHINE_AMD64             (64-Bits) AMD64 (K8) or EM64T. A 64-bit Windows-based application.
        0x01C0  IMAGE_FILE_MACHINE_ARM               ARM Little-Endian.
        0xAA64  IMAGE_FILE_MACHINE_ARM64             ARM64 Little-Endian.
        0x01C4  IMAGE_FILE_MACHINE_ARMNT             ARM Thumb-2 Little-Endian.
        0x0EBC  IMAGE_FILE_MACHINE_EBC               EFI Byte Code.
        0x014C  IMAGE_FILE_MACHINE_I386              (32-Bits) Intel 386 or later processors and compatible processors.
        0x0200  IMAGE_FILE_MACHINE_IA64              (64-Bits) Intel (64) Itanium processor family.
        0x9041  IMAGE_FILE_MACHINE_M32R              Mitsubishi M32R little-endian.
        0x0266  IMAGE_FILE_MACHINE_MIPS16            MIPS16.
        0x0366  IMAGE_FILE_MACHINE_MIPSFPU           MIPS with FPU.
        0x0466  IMAGE_FILE_MACHINE_MIPSFPU16         MIPS16 with FPU.
        0x01F0  IMAGE_FILE_MACHINE_POWERPC           IBM PowerPC Little-Endian.
        0x01F1  IMAGE_FILE_MACHINE_POWERPCFP         Power PC with floating point support.
        0x0166  IMAGE_FILE_MACHINE_R4000             MIPS little-endian.
        0x5032  IMAGE_FILE_MACHINE_RISCV32           RISC-V 32-bit address space.
        0x5064  IMAGE_FILE_MACHINE_RISCV64           RISC-V 64-bit address space.
        0x5128  IMAGE_FILE_MACHINE_RISCV128          RISC-V 128-bit address space.
        0x01A2  IMAGE_FILE_MACHINE_SH3               Hitachi SH3 little-endian.
        0x01A3  IMAGE_FILE_MACHINE_SH3DSP            Hitachi SH3 DSP.
        0x01A6  IMAGE_FILE_MACHINE_SH4               Hitachi SH4 little-endian.
        0x01A8  IMAGE_FILE_MACHINE_SH5               Hitachi SH5.
        0x01C2  IMAGE_FILE_MACHINE_THUMB             ARM Thumb/Thumb-2 Little-Endian.
        0x0169  IMAGE_FILE_MACHINE_WCEMIPSV2         MIPS little-endian WCE v2.
    References:
        Compound File Header               https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-cfb/05060311-bfce-4b12-874d-71fd4ce63aea
        PE Format                          https://docs.microsoft.com/en-us/windows/desktop/Debug/pe-format#file-headers
        ImageHlp Structures                https://docs.microsoft.com/en-us/windows/desktop/Debug/imagehlp-structures
        EXE Format                         http://www.delorie.com/djgpp/doc/exe/
        Image File Machine Constants       https://docs.microsoft.com/en-us/windows/desktop/sysinfo/image-file-machine-constants
        Class CoffMachineType              https://ghidra.re/ghidra_docs/api/ghidra/app/util/bin/format/coff/CoffMachineType.html
*/
GetMachineType(FileName)
{
    local

    ; ----------------------------------------------------------------------------------------------------------------
    ; OPEN FILE                                                                                                      -
    ; ----------------------------------------------------------------------------------------------------------------
    if (Type(FileName) == "String")
    {
        File := FileOpen(FileName, "r-wd")
        if (!IsObject(File))
            return -2
    }

    else if (Type(FileName) == "Integer")
    {
        File := FileOpen(FileName, "h")
        if (!IsObject(File))
            return -2
    }

    else
    {
        File := FileName
        if (Type(File) !== "File")
            throw Exception("GetMachineType function, invalid parameter #1.", -1)
    }

    File.Seek(0)

    ; ----------------------------------------------------------------------------------------------------------------
    ; HEADER SIGNATURE --> MS-DOS STUB                                                                               -
    ; https://docs.microsoft.com/en-us/windows/desktop/Debug/pe-format#file-headers                                  -
    ; https://en.wikipedia.org/wiki/DOS_MZ_executable                                                                -
    ; ----------------------------------------------------------------------------------------------------------------
    if (File.ReadUShort() !== 0x5A4D)  ; 0x5A4D = 'MZ' (IMAGE_DOS_SIGNATURE).
        return -1

    ; ----------------------------------------------------------------------------------------------------------------
    ; IMAGE_NT_HEADERS --> PE SIGNATURE                                                                              -
    ; https://docs.microsoft.com/en-us/windows/desktop/api/winnt/ns-winnt-_image_nt_headers                          -
    ; https://en.wikipedia.org/wiki/Portable_Executable                                                              -
    ; ----------------------------------------------------------------------------------------------------------------
    File.Seek(0x3C)
    File.Seek(File.ReadUInt())       ; IMAGE_NT_HEADERS.
    if (File.ReadUInt() !== 0x4550)  ; IMAGE_NT_HEADERS.Signature. 0x4550 = 'PE\0\0'.
        Return -1

    ; ----------------------------------------------------------------------------------------------------------------
    ; IMAGE_FILE_HEADER                                                                                              -
    ; https://docs.microsoft.com/en-us/windows/desktop/api/winnt/ns-winnt-_image_file_header                         -
    ; ----------------------------------------------------------------------------------------------------------------
    return File.ReadUShort()  ; IMAGE_NT_HEADERS.IMAGE_FILE_HEADER.Machine.
}





/*
File := FileSelect()
if (ErrorLevel)
    ExitApp
MType := GetMachineType(File)
MsgBox(MType=0x014C?"32":MType=0x0200||MType=0x8664?"64":"??")
*/
