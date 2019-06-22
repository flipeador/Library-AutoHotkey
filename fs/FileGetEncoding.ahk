/*
    Determines the character encoding used in the specified text file.
    Parameters:
        FileName:
            The name of a file or a file object with read access.
    Return value:
        Returns zero if «FileName» is not a file or if an error occurred when opening the file for reading.
        Returns an empty string if the encoding couldn't be determined. This may be because the file is encoded as ANSI.
        If the function succeeds, it returns a string with the detected encoding. The following encodings are supported:
            BOCU-1, SCSU, UTF-EBCDIC, UTF-1, UTF-7, UTF-8, UTF-16LE, UTF-16BE, UTF-32LE and UTF-32BE.
*/
FileGetEncoding(FileName)
{
    Local

    if (Type(FileName) == "String")
    {
        File := FileOpen(FileName, "r-wd")
        if (!IsObject(File))
            return 0
    }

    else if (Type(FileName) == "Integer")
    {
        File := FileOpen(FileName, "h")
        if (!IsObject(File))
            return 0
    }

    else
    {
        File := FileName
        if (Type(File) !== "File")
            throw Exception("FileGetEncoding function, invalid parameter #1.", -1)
        Pos := File.Pos  ; Saves the current position of the file pointer.
    }

    Size := File.Length  ; File size, in bytes.
    
    ; ANSI?.
    if (Size < 2)
        return ""

    File.Seek(0)  ; Moves the file pointer to the beginning of the file.

    Byte := [0x00, 0x00, 0x00, 0x00]
    while (A_Index < 5 && !File.AtEOF)  ; Reads the first 4 bytes.
        Byte[A_Index] := File.ReadUChar()

    if (Type(FileName) == "String")
        File.Close()  ; Closes the file, flushes any data in the cache to disk and releases the share locks.
    else
        File.Seek(Pos)  ; Restores the position of the file pointer.

    ; UTF-16LE | UTF-16BE.
    if (Size < 3)
    {
        if (Byte[1] == 0xFE && Byte[2] == 0xFF)
            return "UTF-16BE"
        else if (Byte[1] == 0xFF && Byte[2] == 0xFE)
            return "UTF-16LE"
    }

    ; UTF-8 | UTF-1 | SCSU | BOCU-1.
    else if (Size < 4)
    {
        if (Byte[1] == 0xEF && Byte[2] == 0xBB && Byte[3] == 0xBF)
            return "UTF-8"
        else if (Byte[1] == 0xF7 && Byte[2] == 0x64 && Byte[3] == 0x4C)
            return "UTF-1"
        else if (Byte[1] == 0x0E && Byte[2] == 0xFE && Byte[3] == 0xFF)
            return "SCSU"
        else if (Byte[1] == 0xFB && Byte[2] == 0xEE && Byte[3] == 0x28)
            return "BOCU-1"
    }

    ; UTF-32BE | UTF-32LE | UTF-EBCDIC | UTF-7 | BOCU-1 | UTF-8 | UTF-1 | SCSU | BOCU-1 | UTF-16BE | UTF-16LE.
    else
    {
        if (Byte[1] == 0x00 && Byte[2] == 0x00 && Byte[3] == 0xFE && Byte[4] == 0xFF)
            return "UTF-32BE"
        else if (Byte[1] == 0xFF && Byte[2] == 0xFE && Byte[3] == 0x00 && Byte[4] == 0x00)
            return "UTF-32LE"
        else if (Byte[1] == 0xDD && Byte[2] == 0x73 && Byte[3] == 0x66 && Byte[4] == 0x73)
            return "UTF-EBCDIC"
        else if (Byte[1] == 0x2B && Byte[2] == 0x2F && Byte[3] == 0x76 && (Byte[4] == 0x38 || Byte[4] == 0x39 || Byte[4] == 0x2B || Byte[4] == 0x2F))
            return "UTF-7"
        else if (Byte[1] == 0xFB && Byte[2] == 0xEE && Byte[3] == 0x28 && Byte[4] == 0xFF)
            return "BOCU-1"
        else if (Byte[1] == 0xEF && Byte[2] == 0xBB && Byte[3] == 0xBF)
            return "UTF-8"
        else if (Byte[1] == 0xF7 && Byte[2] == 0x64 && Byte[3] == 0x4C)
            return "UTF-1"
        else if (Byte[1] == 0x0E && Byte[2] == 0xFE && Byte[3] == 0xFF)
            return "SCSU"
        else if (Byte[1] == 0xFB && Byte[2] == 0xEE && Byte[3] == 0x28)
            return "BOCU-1"
        else if (Byte[1] == 0xFE && Byte[2] == 0xFF)
            return "UTF-16BE"
        else if (Byte[1] == 0xFF && Byte[2] == 0xFE)
            return "UTF-16LE"
    }

    ; ANSI?.
    return ""
}





;MsgBox(FileGetEncoding(FileSelect()))
