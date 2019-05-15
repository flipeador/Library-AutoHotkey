#Include ..\MCode.ahk


/*
    unsigned long long StrLen(unsigned char *p)
    {
        unsigned long long n = 0ULL;
        
        for(; *p; p++)
            if ((*p & 0xC0) != 0x80)
                ++n;

        return n;
    }
*/
StrLen2(ByRef Text)
{
    static pStrLen := 0
    local

    VarSetCapacity(Buffer, StrPut(Text,"UTF-8"))
   ,StrPut(Text, &Buffer, "UTF-8")

    if !pStrLen
        pStrLen := MCode("2,x86:g+wIi0wkDA9XwGYPEwQki1QkBIoBhMB0IlaLdCQEZpAkwDyAdAaDxgGD0gCKQQFBhMB17IvGXoPECMOLBCSDxAjD,x64:D7YRM8CE0nQjDx+AAAAAAIDiwEyNQAGA+oBIjUkBD7YRTA9EwEmLwITSdeTD")
    
    return DllCall(pStrLen, "Ptr", &Buffer, "UInt64")
}





StrLenRE(ByRef Text)
{
    local i := 0
    RegExReplace(Text, "s).", "", i)
    return i
} ; https://autohotkey.com/boards/viewtopic.php?t=22036#p106284




; MsgBox(Format("𠜎`n----------`nStrLen: {1}`nStrLen2: {2}`nStrLenRE: {3}",StrLen("𠜎"),StrLen2("𠜎"),StrLenRE("𠜎")))
; MsgBox(Format("å`n----------`nStrLen: {1}`nStrLen2: {2}`nStrLenRE: {3}",StrLen("å"),StrLen2("å"),StrLenRE("å")))
