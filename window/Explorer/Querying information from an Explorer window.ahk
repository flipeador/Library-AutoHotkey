; Querying information from an Explorer window.
; https://blogs.msdn.microsoft.com/oldnewthing/20040720-00/?p=38393/.


; VARIANT structure.
; https://docs.microsoft.com/en-us/windows/desktop/api/oaidl/ns-oaidl-tagvariant.
VarSetCapacity(VARIANT, A_PtrSize==4?16:24, 0)

; GUID & IID.
VarSetCapacity(GUID, 16)
VarSetCapacity(IID, 16)

; ITEMIDLIST structure.
; https://docs.microsoft.com/en-us/windows/desktop/api/shtypes/ns-shtypes-_itemidlist.
VarSetCapacity(ITEMIDLIST, 3)


; IShellWindows interface.
; https://docs.microsoft.com/en-us/windows/desktop/api/exdisp/nn-exdisp-ishellwindows#methods.
IShellWindows := ComObjCreate("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}", "{85CB6900-4D95-11CF-960C-0080C7F4EE85}")

; IShellWindows::IShellWindows::get_Count method.
; https://docs.microsoft.com/en-us/windows/desktop/api/exdisp/nf-exdisp-ishellwindows-get_count.
Count := 0
DllCall(NumGet(NumGet(IShellWindows)+7*A_PtrSize), "Ptr", IShellWindows, "IntP", Count, "UInt")

loop Count
{
    NumPut(3, &VARIANT, "UShort")         ; VARIANT.vt. VT_I4 = 3 (Int).
    NumPut(A_Index-1, &VARIANT+8, "Int")  ; VARIANT.intVal.

    ; IShellWindows::Item method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/exdisp/nf-exdisp-ishellwindows-item.
    IDispatch := 0
    DllCall(NumGet(NumGet(IShellWindows)+8*A_PtrSize), "Ptr", IShellWindows, "Ptr", &VARIANT, "UPtrP", IDispatch, "UInt")  ; An exception is thrown if it is executed from x32.

    ; IWebBrowserApp Interface.
    ; https://docs.microsoft.com/en-us/dotnet/api/shdocvw.iwebbrowserapp?view=dynamics-usd-3.
    IWebBrowserApp := ComObjQuery(IDispatch, "{0002DF05-0000-0000-C000-000000000046}")
    ObjRelease(IDispatch)

    ; IWebBrowserApp::Get_HWnd method.
    ; http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/delphivclwin32/SHDocVw_IWebBrowserApp_Get_HWnd.html.
    hWnd := 0
    DllCall(NumGet(NumGet(IWebBrowserApp)+37*A_PtrSize), "Ptr", IWebBrowserApp, "UPtrP", hWnd, "UInt")
    
    ; IServiceProvider Interface.
    ; https://docs.microsoft.com/en-us/dotnet/api/system.iserviceprovider?view=netframework-4.8.
    IServiceProvider := ComObjQuery(IWebBrowserApp, "{6D5140C1-7436-11CE-8034-00AA006009FA}")
    ObjRelease(IWebBrowserApp)

    SID_STopLevelBrowser := "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; https://github.com/tpn/winsdk-7/blob/master/v7.1A/Include/ShlGuid.h.
    IID_IShellBrowser    := "{000214E2-0000-0000-C000-000000000046}"  ; https://gist.github.com/hfiref0x/a77584e47b0feb3779f47c8d7609d4c4.

    ; CLSIDFromString function.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/combaseapi/nf-combaseapi-clsidfromstring.
    DllCall("Ole32.dll\CLSIDFromString", "Str", SID_STopLevelBrowser, "Ptr", &GUID, "UInt")
    DllCall("Ole32.dll\CLSIDFromString", "Str", IID_IShellBrowser, "Ptr", &IID, "UInt")

    ; IServiceProvider::QueryService method.
    ; https://docs.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.ole.interop.iserviceprovider.queryservice?view=visualstudiosdk-2017#Microsoft_VisualStudio_OLE_Interop_IServiceProvider_QueryService_System_Guid__System_Guid__System_IntPtr__.
    IShellBrowser := 0
    DllCall(NumGet(NumGet(IServiceProvider)+3*A_PtrSize), "Ptr", IServiceProvider, "Ptr", &GUID, "Ptr", &IID, "UPtrP", IShellBrowser, "UInt")
    ObjRelease(IServiceProvider)
    ; IShellBrowser interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ishellbrowser.

    ; IShellBrowser::QueryActiveShellView method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellbrowser-queryactiveshellview.
    IShellView := 0
    DllCall(NumGet(NumGet(IShellBrowser)+15*A_PtrSize), "Ptr", IShellBrowser, "UPtrP", IShellView, "UInt")
    ObjRelease(IShellBrowser)
    ; IShellView interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ishellview.

    ; IFolderView interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ifolderview.
    IFolderView := ComObjQuery(IShellView, "{CDE725B0-CCC9-4519-917E-325D72FAB4CE}")
    ObjRelease(IShellView)

    IID_IPersistFolder2 := "{1AC3D9F0-175C-11d1-95BE-00609797EA4F}"
    DllCall("Ole32.dll\CLSIDFromString", "Str", IID_IPersistFolder2, "Ptr", &IID, "UInt")

    ; IFolderView::GetFolder method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifolderview-getfolder.
    IPersistFolder2 := 0
    DllCall(NumGet(NumGet(IFolderView)+5*A_PtrSize), "Ptr", IFolderView, "Ptr", &IID, "UPtrP", IPersistFolder2, "UInt")
    ; IPersistFolder2 interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ipersistfolder2.

    ; IPersistFolder2::GetCurFolder method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ipersistfolder2-getcurfolder.
    pITEMIDLIST := 0
    DllCall(NumGet(NumGet(IPersistFolder2)+5*A_PtrSize), "Ptr", IPersistFolder2, "UPtrP", pITEMIDLIST, "UInt")
    ObjRelease(IPersistFolder2)

    ; SHGetPathFromIDListW function.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-shgetpathfromidlistw.
    VarSetCapacity(Path, 2*32767+2, 0)
    DllCall("Shell32.dll\SHGetPathFromIDListW", "Ptr", pITEMIDLIST, "Str", Path)

    ; ILFree function.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shlobj_core/nf-shlobj_core-ilfree.
    DllCall("Shell32.dll\ILFree", "Ptr", pITEMIDLIST)

    IID_IShellItemArray := "{b63ea76d-1f85-456f-a19c-48159efa858b}"
    DllCall("Ole32.dll\CLSIDFromString", "Str", IID_IShellItemArray, "Ptr", &IID, "UInt")

    ; _SVGIO Enumeration.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/ne-shobjidl_core-_svgio.
    SVGIO_SELECTION := 0x00000001

    ; IFolderView::Items method.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ifolderview-items.
    IShellItemArray := 0
    DllCall(NumGet(NumGet(IFolderView)+8*A_PtrSize), "Ptr", IFolderView, "UInt", SVGIO_SELECTION, "Ptr", &IID, "UPtrP", IShellItemArray, "UInt")
    ObjRelease(IFolderView)
    ; IShellItemArray interface.
    ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ishellitemarray.

    SelFilesList := ""
    if IShellItemArray
    {
        ; IShellItemArray::GetCount method.
        ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitemarray-getcount.
        NumItems := 0
        DllCall(NumGet(NumGet(IShellItemArray)+7*A_PtrSize), "Ptr", IShellItemArray, "UIntP", NumItems, "UInt")

        loop NumItems
        {
            ; IShellItemArray::GetItemAt method.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitemarray-getitemat.
            IShellItem := 0
            DllCall(NumGet(NumGet(IShellItemArray)+8*A_PtrSize), "Ptr", IShellItemArray, "UInt", A_Index-1, "UPtrP", IShellItem, "UInt")
            ; IShellItem interface.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nn-shobjidl_core-ishellitem.

            ; IShellItem::GetDisplayName method.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/nf-shobjidl_core-ishellitem-getdisplayname.
            pPath := 0
            DllCall(NumGet(NumGet(IShellItem)+5*A_PtrSize), "Ptr", IShellItem, "Int", 0, "UPtrP", pPath, "UInt")
            ObjRelease(IShellItem)

            SelFilesList .= StrGet(pPath,"UTF-16") . "`n"

            ; CoTaskMemFree function.
            ; https://docs.microsoft.com/en-us/windows/desktop/api/combaseapi/nf-combaseapi-cotaskmemfree.
            DllCall("Ole32.dll\CoTaskMemFree", "Ptr", pPath)
        }

        ObjRelease(IShellItemArray)
    }

    MsgBox Format("{1} (0x{1:08X}){4}{2}{4}{3}", hWnd, Path, SelFilesList, "`n----------------------------------`n")
}

ObjRelease(IShellWindows)
ExitApp
