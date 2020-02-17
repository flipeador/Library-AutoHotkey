#Include ..\misc.ahk





hInstance := DllCall("Kernel32.dll\LoadLibraryW", "Str", "mswsock.dll", "Ptr")
Result    := StrLoad(hInstance, 60100)
MsgBox(Format("Instance:`s{}`nIdentifier:`s{}`nPtr:`s{}`nStr:`s{}`nLength:`s{}`nSize:`s{}"
            , Result.Instance, Result.ID, Result.Ptr, Result.Str, Result.Length, Result.Size))

MsgBox(StrGet(Buffer:=BufferAlloc(Result.Size+2),StrLoad(hInstance,60100,Buffer),"UTF-16"))  ; The other way.


DllCall("Kernel32.dll\FreeLibrary", "Ptr", hInstance)
