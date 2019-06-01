/*
    Retrieves the size of the Recycle Bin and the number of items in it, for a specified drive.
    Parameters:
        RootPath:
            The path of the root drive on which the Recycle Bin is located.
            This parameter can contain a string formatted with the drive, folder, and subfolder names (C:\Windows\System...).
    Return:
        If this function succeeds, the return value is an object with the keys: 'Size' and 'Items'.
        If the function fails, the return value is zero.
*/
QueryRecycleBin(RootPath := 0)
{
    local

    ; SHQUERYRBINFO structure.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/ns-shellapi-_shqueryrbinfo.
    SHQUERYRBINFO := BufferAlloc(16+A_PtrSize)
    NumPut("UInt", SHQUERYRBINFO.Size, SHQUERYRBINFO)
 
    return DllCall("Shell32.dll\SHQueryRecycleBinW",  "Ptr", Type(RootPath) == "String" ? &RootPath : RootPath
                                                   , "UPtr", SHQUERYRBINFO.Ptr
                                                   , "UInt")
         ? 0                                                   ; ERROR.
         : { Size :NumGet(SHQUERYRBINFO,A_PtrSize)             ; SHQUERYRBINFO.i64Size.
           , Items:NumGet(SHQUERYRBINFO,A_PtrSize==4?12:16) }  ; SHQUERYRBINFO.i64NumItems.
} ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shqueryrecyclebina





; MsgBox(Format("{2} Items, {3} Bytes ({4} MB).",R:=QueryRecycleBin(),R.Items,R.Size,R.Size//1024**2))
