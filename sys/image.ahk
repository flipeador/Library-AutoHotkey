/*
    Loads an icon, cursor, animated cursor, or bitmap.
    Parameters:
        hInstance:
            A handle to the module of either a DLL or executable (.exe) that contains the image to be loaded.
            To load an OEM image or a stand-alone resource, set this parameter to zero.
        Image:
            The image to be loaded. This parameter must be an integer or a string.
            ---------------------------------------------------------------------------------------
            If the image resource is to be loaded by name from the module, specify a string that contains the name of the image resource.
            If the image resource is to be loaded by ordinal from the module, specify a integer value.
            ---------------------------------------------------------------------------------------
            If LR_LOADFROMFILE is used, specify the name of the file that contains the stand-alone resource (icon, cursor, or bitmap file).
            ---------------------------------------------------------------------------------------
            If «hInstance» is zero and LR_LOADFROMFILE is not used, specify the OEM image to load.
        Type:
            The type of image to be loaded. This parameter can be one of the following values.
            ┌───────┬──────────────┬─────────────────────────────────────────────┐
            │ Value │ Constant     │ Meaning                                     │
            ├───────┼──────────────┼─────────────────────────────────────────────┤
            │ 0     │ IMAGE_BITMAP │  Loads a bitmap. This is the default value. │
            │ 1     │ IMAGE_ICON   │  Loads an icon.                             │
            │ 2     │ IMAGE_CURSOR │  Loads a cursor.                            │
            └───────┴──────────────┴─────────────────────────────────────────────┘
        Width / Height:
            The width and height, in pixels, of the image.
            If this parameter is zero and LR_DEFAULTSIZE is used, the function uses the SM_CXICON/SM_CYICON or SM_CXCURSOR/SM_CYCURSOR system metric value.
            If this parameter is zero and LR_DEFAULTSIZE is not used, the function uses the actual resource width.
        Flags:
            This parameter can be one or more of the following values.
            ┌────────────┬─────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value      │ Constant            │ Meaning                                                                                                                  │
            ├────────────┼─────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x00000001 │ LR_MONOCHROME       │ Loads the image in black and white.                                                                                      │
            │ 0x00000010 │ LR_LOADFROMFILE     │ Loads the stand-alone image from the file specified by «Image» (icon, cursor, or bitmap file).                           │
            │ 0x00000040 │ LR_DEFAULTSIZE      │ Uses the width or height specified by the system metric values for cursors or icons, if Width or Height are set to zero. │
            │ 0x00000080 │ LR_VGACOLOR         │ Uses true VGA colors.                                                                                                    │
            │ 0x00002000 │ LR_CREATEDIBSECTION │ Return a DIB section bitmap rather than a compatible bitmap (IMAGE_BITMAP).                                              │
            │ 0x00008000 │ LR_SHARED           │ Shares the image handle if the image is loaded multiple times.                                                           │
            └────────────┴─────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
LoadImage(hInstance, Image, Type := 0, Width := 0, Height := 0, Flags := 0)
{
    return DllCall("User32.dll\LoadImageW"
        , "UPtr", hInstance                               ; hInst.
        , "UPtr", Type(Image)=="String" ? &Image : Image  ; name.
        , "UInt", Type                                    ; type.
        ,  "Int", Width                                   ; cx.
        ,  "Int", Height                                  ; cy.
        , "UInt", Flags                                   ; fuLoad.
        , "UPtr")                                         ; Return value (HANDLE).
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadimagew





/*
    Creates a new image (icon, cursor, or bitmap) and copies the attributes of the specified image to the new one.
    Parameters:
        hImage:
            A handle to the image to be copied.
        Type:
            The type of image to be copied. See the LoadImage function.
        Width / Height:
            The desired width and height, in pixels, of the image.
            If this is zero, then the returned image will have the same width/height as the original image.
        Flags:
            This parameter can be one or more of the following values.
            ┌────────────┬─────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value      │ Constant            │ Meaning                                                                                                                  │
            ├────────────┼─────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x00000001 │ LR_MONOCHROME       │ Creates a new monochrome image.                                                                                          │
            │ 0x00000004 │ LR_COPYRETURNORG    │ Returns the original image if it satisfies the criteria for the copy—that is, correct dimensions and color depth.        │
            │ 0x00000008 │ LR_COPYDELETEORG    │ Deletes the original image after creating the copy.                                                                      │
            │ 0x00000040 │ LR_DEFAULTSIZE      │ Uses the width or height specified by the system metric values for cursors or icons, if Width or Height are set to zero. │
            │ 0x00002000 │ LR_CREATEDIBSECTION │ Return a DIB section bitmap rather than a compatible bitmap (IMAGE_BITMAP).                                              │
            │ 0x00004000 │ LR_COPYFROMRESOURCE │ Tries to reload an icon or cursor resource from the original resource file rather than simply copying the current image. │
            └────────────┴─────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is a handle to the duplicate image.
        If the function fails, the return value is zero. A_LastError contains extended error information.
*/
CopyImage(hImage, Type := 0, Width := 0, Height := 0, Flags := 0)
{
    return DllCall("User32.dll\CopyImage"
        , "UPtr", hImage  ; h.
        , "UInt", Type    ; type.
        ,  "Int", Width   ; cx.
        ,  "Int", Height  ; cy.
        , "UInt", Flags   ; flags.
        , "UPtr")         ; Return value (HANDLE).
} ; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-copyimage





/*
    Destroys a image (icon, cursor, or bitmap) and frees any memory the cursor occupied.
    Parameters:
        hImage:
            A handle to the image to be destroyed. The image must not be in use.
        Type:
            The type of image to be destroyed. See the LoadImage function.
    Return value:
        If the function succeeds, the return value is nonzero.
        If the function fails, the return value is zero.
    Remarks:
        Do not use this function to destroy a shared image.
        A shared image is valid as long as the module from which it was loaded remains in memory.
*/
DestroyImage(hImage, Type := 0)
{
    switch (Type)
    {
    case 0: return DllCall("Gdi32.dll\DeleteObject"  , "UPtr", hImage)  ; https://docs.microsoft.com/windows/desktop/api/wingdi/nf-wingdi-deleteobject
    case 1: return DllCall("User32.dll\DestroyIcon"  , "UPtr", hImage)  ; https://docs.microsoft.com/windows/desktop/api/winuser/nf-winuser-destroyicon
    case 2: return DllCall("User32.dll\DestroyCursor", "UPtr", hImage)  ; https://docs.microsoft.com/windows/desktop/api/winuser/nf-winuser-destroycursor
    }
    throw Exception("Function DestroyImage invalid parameter #2.", -1)
}
