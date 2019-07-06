BinRandom(Buffer, Size := -1)
{
    return !(Buffer:=IsObject(Buffer)?Buffer:{Ptr:Buffer,Size:0}).Ptr || !(Size:=Integer(Size<0?Buffer.Size:Size))
         ? 0 : DllCall("Advapi32.dll\SystemFunction036", "Ptr", Buffer, "UInt", Size)
         ? {Buffer:Buffer,Size:Size,Ptr:Integer(IsObject(Buffer)?Buffer.Ptr:Buffer)} : 0
} ; https://docs.microsoft.com/en-us/windows/desktop/api/ntsecapi/nf-ntsecapi-rtlgenrandom





BinRandomStr(Size)
{
    local Buffer, Str := ""
    loop (Buffer:=BinRandom(BufferAlloc(Size))) && Buffer.Size
        Str .= Format("{:02X}", NumGet(Buffer,A_Index-1,"UChar"))
    return Str
}
