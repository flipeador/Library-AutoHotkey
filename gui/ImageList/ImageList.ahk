; AutoHotkey v2.0-a104-3e7a969d.

/*
    Encapsulates the creation and manipulation of a image list in a class.
*/
class IImageList  ; https://github.com/flipeador  |  https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=60315
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static DPI := A_ScreenDPI  ; The DPI to use for scaling metrics.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Handle := 0  ; The image list Handle.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Creates a new image list. The CreateImageList function can be used to create the image list.
        Parameters:
            Width:
                The width, in pixels, of each image.
                If this parameter is -1, the recommended width of a small icon is used.
                If this parameter is -2, the default width of an icon is used.
            Height:
                The height, in pixels, of each image.
                If this parameter is -1, the recommended height of a small icon is used.
                If this parameter is -2, the default height of an icon is used.
            InitialCount:
                The number of images that the image list initially contains.
            GrowCount:
                The number of images by which the image list can grow when the system needs to make room for new images.
                This parameter represents the number of new images that the resized image list can contain.
            Flags:
                A set of bit flags that specify the type of image list to create.
                This parameter can be a combination of the Image List Creation Flags.
        Image List Creation Flags:
            https://msdn.microsoft.com/en-us/library/Bb775232(v=VS.85).aspx
    */
    __New(Width := -1, Height := -1, InitialCount := 2, GrowCount := 5, Flags := 0x00020020)
    {
        Width := Width == -1 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 49, "UInt", IImageList.DPI)  ; SM_CXSMICON.
               : Width == -2 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 11, "UInt", IImageList.DPI)  ; SM_CXICON.
               : Abs(Integer(Width))

        Height := Height == -1 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 50, "UInt", IImageList.DPI)  ; SM_CYSMICON.
                : Height == -2 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 12, "UInt", IImageList.DPI)  ; SM_CYICON.
                : Abs(Integer(Height))

        this.Handle := DllCall("Comctl32.dll\ImageList_Create",  "Int", Width
                                                              ,  "Int", Height
                                                              , "UInt", Flags
                                                              ,  "Int", InitialCount
                                                              ,  "Int", GrowCount
                                                              , "UPtr")

        if (this.Handle == 0)
            throw Exception("IImageList.New() - ImageList_Create Error.", -1)
        this.Ptr := this.Handle
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/nf-commctrl-imagelist_create


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    class FromData extends IImageList
    {
        /*
            Creates an image list from data. The ImageListFromData function can be used to create the image list.
            Parameters:
                Data:
                    If this parameter is an string, specifies data encoded as Base64.
                    If this parameter is an object, must have the Ptr and Size properties, specifies a buffer.
                    If this parameter is an integer, specifies a pointer to an IStream interface.
        */
        __New(Data)
        {
            if (Type(Data) == "String")  ; From Base64.
            {
                local Buffer, Size := 0
                DllCall("Crypt32.dll\CryptStringToBinaryW", "Ptr", &Data, "UInt", 0, "UInt", 0x1, "Ptr", 0, "UIntP", Size, "Ptr", 0, "UInt", 0)
                DllCall("Crypt32.dll\CryptStringToBinaryW", "Ptr", &Data, "UInt", 0, "UInt", 0x1, "Ptr", Buffer:=BufferAlloc(Size), "UIntP", Size, "Ptr", 0, "UInt", 0)
                Data := Buffer
            }
            local IStream := IsObject(Data) ? DllCall("Shlwapi.dll\SHCreateMemStream","Ptr",Data,"UInt",Data.Size) : Data
            this.Handle := DllCall("Comctl32.dll\ImageList_Read", "Ptr", IStream, "UPtr")
            try ObjRelease(IsObject(Data) ? IStream : 0)
            if (this.Handle == 0)
                throw Exception("IImageList.FromData.New() - ImageList_Read Error.", -1)
            this.Ptr := this.Handle
        } ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=41891
    }

    class FromImageList extends IImageList
    {
        /*
            Creates a duplicate of an existing image list. The DuplicateImageList function can be used to create the image list.
        */
        __New(ImageList)
        {
            this.Handle := DllCall("Comctl32.dll\ImageList_Duplicate", "Ptr", ImageList, "UPtr")
            if (this.Handle == 0)
                throw Exception("IImageList.FromImageList.New() - ImageList_Duplicate Error.", -1)
            this.Ptr := this.Handle
        }
    }

    class FromHandle extends IImageList
    {
        /*
            Initializes the object from an existing image list. The ImageListFromHandle function can be used for this purpose.
        */
        __New(Handle)
        {
            if !DllCall("Comctl32.dll\ImageList_GetIconSize", "Ptr", Handle, "IntP", 0, "IntP", 0)
                throw Exception("IImageList.FromHandle.New() - Invalid image list.", -1)
            this.Ptr := this.Handle := Handle
        }
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    /*
        Destroys the image list and releases all associated resources.
    */
    __Delete()
    {
        if (this.Handle !== 0)
            DllCall("Comctl32.dll\ImageList_Destroy", "Ptr", this)
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/nf-commctrl-imagelist_destroy


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Adds an image or images to the image list.
        Return value:
            Returns the zero-based index of the first new image if successful, or -1 otherwise.
    */
    Add(Filename, IconNumber := 1, ResizeNonIcon := 0)
    {
        return ResizeNonIcon ? IL_Add(this.Handle, Type(Filename)=="Integer"?"HBITMAP:*" . Filename:Filename, IconNumber, ResizeNonIcon) - 1
             : IL_Add(this.Handle, Type(Filename)=="Integer"?"HBITMAP:*" . Filename:Filename, IconNumber) - 1
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/nf-commctrl-imagelist_add

    /*
        Retrieves the dimensions of images in the image list. All images in an image list have the same dimensions.
        Return value:
            If the method succeeds, the return value is an object with the properties W(idth) and H(eight).
            If the method fails, the return value is zero.
    */
    GetIconSize()
    {
        local Width := 0, Height := 0
        return DllCall("Comctl32.dll\ImageList_GetIconSize", "Ptr", this, "IntP", Width, "IntP", Height)
             ? { W:Width , H:Height }  ; Ok.
             : 0                       ; Error.
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/nf-commctrl-imagelist_geticonsize

    /*
        Saves the image list as a Base64 string.
        Return value:
            The return value is a string containing the binary data encoded as a Base64 string.
        Remarks:
            The ImageListFromData function can be used to recreate the image list from this data.
    */
    Save()
    {
        local IStream := 0, hGlobal := 0, ReqSize := 0
        DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", 0, "Int", TRUE, "PtrP", IStream)
        DllCall("Comctl32.dll\ImageList_Write", "Ptr", this, "Ptr", IStream)
        DllCall("Ole32.dll\GetHGlobalFromStream", "Ptr", IStream, "PtrP", hGlobal)
        local pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hGlobal, "Ptr")
        local Size  := DllCall("Kernel32.dll\GlobalSize", "Ptr", hGlobal, "Ptr")
        DllCall("Crypt32.dll\CryptBinaryToStringW", "Ptr", pData, "UInt", Size, "UInt", 0x40000001, "Ptr", 0, "UIntP", ReqSize)
        local Buffer := BufferAlloc(2*ReqSize)  ; Required number of characters, including the terminating NULL character.
        DllCall("Crypt32.dll\CryptBinaryToStringW", "Ptr", pData, "UInt", Size, "UInt", 0x40000001, "Ptr", Buffer, "UIntP", ReqSize)
        DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hGlobal), ObjRelease(IStream)
        return StrGet(Buffer)
    } ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=41891


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Retrieves the number of images in the image list.
    */
    Count[] => DllCall("Comctl32.dll\ImageList_GetImageCount", "Ptr", this)
    ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-imagelist_getimagecount
}





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
CreateImageList(Width := -1, Height := -1, InitialCount := 2, GrowCount := 5, Flags := 0x00020020)
{
    return IImageList.New(Width, Height, InitialCount, GrowCount, Flags)
}

DuplicateImageList(ImageList)
{
    return IImageList.FromImageList.New(ImageList)
}

ImageListFromData(Data)
{
    return IImageList.FromData.New(Data)
}

ImageListFromHandle(Handle)
{
    return IImageList.FromHandle.New(Handle)
}
