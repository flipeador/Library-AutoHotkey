class ImageList
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static  DPI := A_ScreenDPI  ; The DPI to use for scaling the metrics.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Handle := 0  ; The handle to the image list.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Creates a new image list.
        Parameters:
            Width:
                The width, in pixels, of each image.
            Height:
                The height, in pixels, of each image.
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
        Width := Width == -1 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 49, "UInt", ImageList.DPI)  ; SM_CXSMICON.
               : Width == -2 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 11, "UInt", ImageList.DPI)  ; SM_CXICON.
               : Abs(Integer(Width))

        Height := Height == -1 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 50, "UInt", ImageList.DPI)  ; SM_CYSMICON.
                : Height == -2 ? DllCall("User32.dll\GetSystemMetricsForDpi", "Int", 12, "UInt", ImageList.DPI)  ; SM_CYICON.
                : Abs(Integer(Height))

        this.Handle := DllCall("Comctl32.dll\ImageList_Create", "Int", Width
                                                              , "Int", Height
                                                              , "UInt", Flags
                                                              , "Int", InitialCount
                                                              , "Int", GrowCount
                                                              , "UPtr")

        if (this.Handle == 0)
            throw Exception("Class ImageList::ImageList.", -1, "ImageList_Create failed.")
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/nf-commctrl-imagelist_create


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    class FromBase64 extends ImageList
    {
        /*
            Creates an image list from a Base64 string.
            Parameters:
                Data:
                    A string, a pointer to a null terminated string or a buffer object containing a null terminated string.
        */
        __New(Data)
        {
            local pData := Type(Data) == "String" ? &Data : Data, Size := 0
            DllCall("Crypt32.dll\CryptStringToBinaryW", "Ptr", pData, "UInt", 0, "UInt", 0x00000001, "Ptr", 0, "UIntP", Size, "Ptr", 0, "UInt", 0)
            local Buffer := BufferAlloc(Size)
            DllCall("Crypt32.dll\CryptStringToBinaryW", "Ptr", pData, "UInt", 0, "UInt", 0x00000001, "Ptr", Buffer, "UIntP", Size, "Ptr", 0, "UInt", 0)
            local IStream := DllCall("Shlwapi.dll\SHCreateMemStream", "Ptr", Buffer, "UInt", Size)
            this.Handle := DllCall("Comctl32.dll\ImageList_Read", "Ptr", IStream, "UPtr")
            ObjRelease(IStream)
            if (this.Handle == 0)
                throw Exception("Class ImageList::FromBase64.", -1, "ImageList_Read failed.")
        } ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=41891
    }

    class FromImageList extends ImageList
    {
        /*
            Creates a duplicate of an existing image list.
        */
        __New(_ImageList)
        {
            this.Handle := DllCall("Comctl32.dll\ImageList_Duplicate", "Ptr", IsObject(_ImageList)?_ImageList.Handle:_ImageList, "UPtr")
            if (this.Handle == 0)
                throw Exception("Class ImageList::FromImageList.", -1, "ImageList_Duplicate failed.")
        }
    }

    class FromHandle extends ImageList
    {
        __New(Handle)
        {
            if (Type(Handle) !== "Integer" || Handle == 0)
                throw Exception("Class ImageList::FromHandle.", -1, "Invalid handle.")
            this.Handle := Handle
        }
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Handle !== 0)
            DllCall("Comctl32.dll\ImageList_Destroy", "Ptr", this.Handle)
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
            Returns an object with the keys 'W' and 'H' if successful, or zero otherwise.
    */
    GetIconSize()
    {
        local Width := 0, Height := 0
        local R := DllCall("Comctl32.dll\ImageList_Destroy", "Ptr", this.Handle, "IntP", Width, "IntP", Height)
        return R ? { W:Width , H:Height } : 0
    } ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/nf-commctrl-imagelist_geticonsize

    /*
        Saves the image list as a Base64 string.
        Return value:
            Returns the binary data encoded as a Base64 string.
    */
    Save()
    {
        local IStream := 0, hGlobal := 0, ReqSize := 0
        DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", 0, "Int", TRUE, "PtrP", IStream)
        DllCall("Comctl32.dll\ImageList_Write", "Ptr", this.Handle, "Ptr", IStream)
        DllCall("Ole32.dll\GetHGlobalFromStream", "Ptr", IStream, "PtrP", hGlobal)
        local pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hGlobal, "Ptr")
        local Size  := DllCall("Kernel32.dll\GlobalSize", "Ptr", hGlobal, "Ptr")
        DllCall("Crypt32.dll\CryptBinaryToStringW", "Ptr", pData, "UInt", Size, "UInt", 0x40000001, "Ptr", 0, "UIntP", ReqSize)
        local Buffer := BufferAlloc(2*ReqSize)  ; Required number of characters, including the terminating NULL character.
        DllCall("Crypt32.dll\CryptBinaryToStringW", "Ptr", pData, "UInt", Size, "UInt", 0x40000001, "Ptr", Buffer, "UIntP", ReqSize)
        DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hGlobal), ObjRelease(IStream)
        return StrGet(Buffer, "UTF-16")
    } ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=41891
}
