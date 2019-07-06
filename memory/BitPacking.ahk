/*
    #define MAKEWORD(a, b)      ((WORD)(((BYTE)(((DWORD_PTR)(a)) & 0xff)) | ((WORD)((BYTE)(((DWORD_PTR)(b)) & 0xff))) << 8))
    n := MAKEWORD(0, 255), MsgBox("WORD " . n . "; LOBYTE " . LOBYTE(n) . "; HIBYTE " . HIBYTE(n))
*/
MAKEWORD(byte_low, byte_high := 0)
{
    return (byte_low & 0xFF) | ((byte_high & 0xFF) << 8)
} ; https://msdn.microsoft.com/es-es/library/windows/desktop/ms632663(v=vs.85).aspx





/*
    #define MAKELONG(a, b)      ((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) | ((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
    n := MAKELONG(0, 65535), MsgBox("LONG " . n . "; LOWORD " . LOWORD(n) . "; HIWORD " . HIWORD(n))
*/
MAKELONG(short_low, short_high := 0)
{
    return (short_low & 0xFFFF) | ((short_high & 0xFFFF) << 16)
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632660(v=vs.85).aspx





/*
    #define MAKELONG64(hi, lo)    ((LONGLONG(DWORD(hi) & 0xffffffff) << 32 ) | LONGLONG(DWORD(lo) & 0xffffffff))
    n := MAKELONG64(0, 4294967295), MsgBox("LONG64 " . n . "; LOLONG " . LOLONG(n) . "; HILONG " . HILONG(n))
*/
MAKELONG64(long_low, long_high := 0)
{
    return (long_low & 0xFFFFFFFF) | ((long_high & 0xFFFFFFFF) << 32)  
}





LOWORD(l)
{
    return l & 0xFFFF
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632659(v=vs.85).aspx





HIWORD(l)
{
    return (l >> 16) & 0xFFFF
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632657(v=vs.85).aspx





LOBYTE(w)
{
    return w & 0xFF
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632658(v=vs.85).aspx





HIBYTE(w)
{
    return (w >> 8) & 0xFF
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632656(v=vs.85).aspx





LOLONG(ll)
{
    return ll & 0xFFFFFFFF
}





HILONG(ll)
{
    return (ll >> 32) & 0xFFFFFFFF
}
