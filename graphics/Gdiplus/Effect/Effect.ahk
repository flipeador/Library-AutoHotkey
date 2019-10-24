/*
    The Effect class serves as a base class for classes that you can use to apply effects and adjustments to bitmaps.
    To apply an effect to a bitmap, create an instance of one of the descendants of the Effect class, and pass the object to the Graphics::DrawImage or Bitmap::ApplyEffect methods.

    Effect Class:
        https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nl-gdipluseffects-effect

    The following classes descend from Effect:
        Blur                      Enables you to apply a Gaussian blur effect to a bitmap and specify the nature of the blur.
        Sharpen                   Enables you to adjust the sharpness of a bitmap.
        Tint                      Enables you to apply a tint to a bitmap.
        RedEyeCorrection          Enables you to correct the red eyes that sometimes occur in flash photographs.
        ColorMatrixEffect         Enables you to apply an affine transformation to a bitmap.
        ColorLUT                  Enables you to make custom color adjustments to bitmaps.
        BrightnessContrast        Enables you to change the brightness and contrast of a bitmap.
        HueSaturationLightness    Enables you to change the hue, saturation, and lightness of a bitmap.
        ColorBalance              Enables you to change the color balance (relative amounts of red, green, and blue) of a bitmap.
        Levels                    Enables you to adjust the highlight, midtone, and shadow of a bitmap.
        ColorCurve                Enables you to adjust the exposure, density, contrast, highlight, shadow, midtone, white saturation, and black saturation of a bitmap.

    Image Effect Constants / GDI+ effect GUIDs:
        {633C80A4-1843-482b-9EF2-BE2834C5FDD4}  BlurEffectGuid                      Specifies the blur effect.
        {63CBF3EE-C526-402c-8F71-62C540BF5142}  SharpenEffectGuid                   Specifies the sharpen effect.
        {1077AF00-2848-4441-9489-44AD4C2D7A2C}  TintEffectGuid                      Specifies the tint effect.
        {74D29D05-69A4-4266-9549-3CC52836B632}  RedEyeCorrectionEffectGuid          Specifies the red-eye correction effect.
        {718F2615-7933-40e3-A511-5F68FE14DD74}  ColorMatrixEffectGuid               Specifies the color matrix effect.
        {A7CE72A9-0F7F-40d7-B3CC-D0C02D5C3212}  ColorLUTEffectGuid                  Specifies the color lookup table effect.
        {D3A1DBE1-8EC4-4c17-9F4C-EA97AD1C343D}  BrightnessContrastEffectGuid        Specifies the brightness contrast effect.
        {8B2DD6C3-EB07-4d87-A5F0-7108E26A9C5F}  HueSaturationLightnessEffectGuid    Specifies the hue saturation lightness effect.
        {537E597D-251E-48da-9664-29CA496B70F8}  ColorBalanceEffectGuid              Specifies the color balance effect.
        {99C354EC-2A31-4f3a-8C34-17A803B33A25}  LevelsEffectGuid                    Specifies the levels effect.
        {DD6A0022-58E4-4a67-9D9B-D48EB881A53D}  ColorCurveEffectGuid                Specifies the color curve effect.
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-constant-image-effect-constants
        https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-emfplus/18f3cb09-8793-42e1-9337-b24794d4223c
*/
class Effect extends GdiplusBase
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES (readonly)
    ; ===================================================================================================================
    static BlurEffectGuid                   := "{633C80A4-1843-482b-9EF2-BE2834C5FDD4}"  ; Specifies the blur effect.
    static SharpenEffectGuid                := "{63CBF3EE-C526-402c-8F71-62C540BF5142}"  ; Specifies the sharpen effect.
    static TintEffectGuid                   := "{1077AF00-2848-4441-9489-44AD4C2D7A2C}"  ; Specifies the tint effect.
    static RedEyeCorrectionEffectGuid       := "{74D29D05-69A4-4266-9549-3CC52836B632}"  ; Specifies the red-eye correction effect.
    static ColorMatrixEffectGuid            := "{718F2615-7933-40e3-A511-5F68FE14DD74}"  ; Specifies the color matrix effect.
    static ColorLUTEffectGuid               := "{A7CE72A9-0F7F-40d7-B3CC-D0C02D5C3212}"  ; Specifies the color lookup table effect.
    static BrightnessContrastEffectGuid     := "{D3A1DBE1-8EC4-4c17-9F4C-EA97AD1C343D}"  ; Specifies the brightness contrast effect.
    static HueSaturationLightnessEffectGuid := "{8B2DD6C3-EB07-4d87-A5F0-7108E26A9C5F}"  ; Specifies the hue saturation lightness effect.
    static ColorBalanceEffectGuid           := "{537E597D-251E-48da-9664-29CA496B70F8}"  ; Specifies the color balance effect.
    static LevelsEffectGuid                 := "{99C354EC-2A31-4f3a-8C34-17A803B33A25}"  ; Specifies the levels effect.
    static ColorCurveEffectGuid             := "{DD6A0022-58E4-4a67-9D9B-D48EB881A53D}"  ; Specifies the color curve effect.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES (readonly)
    ; ===================================================================================================================
    Ptr          := 0       ; (nativeEffect) Pointer to the object.
    AuxData      := 0       ; Pointer to a set of lookup tables created by a previous call to the Bitmap::ApplyEffect method.
    AuxDataSize  := 0       ; The size, in bytes, of the auxiliary data created by a previous call to the Bitmap::ApplyEffect method.
    UseAuxData   := FALSE   ; Sets or clears a flag that specifies whether the Bitmap::ApplyEffect method should return a pointer to the auxiliary data that it creates.


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        DllCall("Gdiplus.dll\GdipDeleteEffect", "Ptr", this.FreeAuxData())
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-bitmap-flat


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    FreeAuxData()
    {
        Gdiplus.Free(this.AuxData)
        return this.SetAuxData(0, 0)
    }

    SetAuxData(AuxData, Size, Flag := -1)
    {
        this.AuxData     := AuxData
        this.AuxDataSize := Size
        this.UseAuxData  := Flag==-1 ? this.UseAuxData : Flag
        return this
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Gets the total size, in bytes, of the parameters currently set for this Effect object.
        Return value:
            Returns the total size, in bytes, of the parameters.
    */
    GetParameterSize()
    {
        local Size := 0
        Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetEffectParameterSize", "Ptr", this, "UIntP", Size)
        return Size
    } ; https://docs.microsoft.com/en-us/windows/win32/api/gdipluseffects/nf-gdipluseffects-effect-getparametersize

    /*
        Gets the parameters for this Effect object.
        Return value:
            If the method succeeds, the return value is a Buffer object.
            If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
    */
    GetParameters()
    {
        local Params := BufferAlloc(this.GetParameterSize())
        return (Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipGetEffectParameters", "Ptr", this, "UIntP", Params.Size, "Ptr", Params))
             ? 0       ; Error.
             : Params  ; Ok.
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-bitmap-flat

    /*
        Sets the parameters for this Effect object.
        Return value:
            Returns TRUE if successful, or FALSE otherwise. To get extended error information, check «Gdiplus.LastStatus».
    */
    SetParameters(Params, Size := 0)
    {
        return !(Gdiplus.LastStatus := DllCall("Gdiplus.dll\GdipSetEffectParameters", "Ptr", this, "Ptr", Params, "UInt", Size||Params.Size))
    } ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-bitmap-flat


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    #Include Blur.ahk                    ; https://docs.microsoft.com/es-es/windows/desktop/api/gdipluseffects/nl-gdipluseffects-blur
    #Include Sharpen.ahk                 ; https://msdn.microsoft.com/en-us/library/ms534503(v=VS.85).aspx
    #Include Tint.ahk                    ; https://msdn.microsoft.com/en-us/library/ms534513(v=VS.85).aspx
    #Include RedEyeCorrection.ahk        ; https://msdn.microsoft.com/en-us/library/ms534499(v=VS.85).aspx
    #Include ColorMatrixEffect.ahk       ; https://msdn.microsoft.com/en-us/library/ms534431(v=VS.85).aspx
    #Include ColorLUT.ahk                ; https://msdn.microsoft.com/en-us/library/ms534430(v=VS.85).aspx
    #Include BrightnessContrast.ahk      ; https://msdn.microsoft.com/en-us/library/ms534423(v=VS.85).aspx
    #Include HueSaturationLightness.ahk  ; https://msdn.microsoft.com/en-us/library/ms534461(v=VS.85).aspx
    #Include ColorBalance.ahk            ; https://msdn.microsoft.com/en-us/library/ms534428(v=VS.85).aspx
    #Include Levels.ahk                  ; https://msdn.microsoft.com/en-us/library/ms534471(v=VS.85).aspx
    #Include ColorCurve.ahk              ; https://msdn.microsoft.com/en-us/library/ms534429(v=VS.85).aspx
}





; #######################################################################################################################
; NESTED CLASSES (Gdiplus)                                                                                              #
; #######################################################################################################################
#Include Classes\BlurParams.ahk                    ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-blurparams
#Include Classes\SharpenParams.ahk                 ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-sharpenparams
#Include Classes\TintParams.ahk                    ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-tintparams
#Include Classes\RedEyeCorrectionParams.ahk        ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-redeyecorrectionparams
#Include Classes\ColorLUTParams.ahk                ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-colorlutparams
#Include Classes\BrightnessContrastParams.ahk      ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-brightnesscontrastparams
#Include Classes\HueSaturationLightnessParams.ahk  ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-huesaturationlightnessparams
#Include Classes\ColorBalanceParams.ahk            ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-colorbalanceparams
#Include Classes\LevelsParams.ahk                  ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-levelsparams
#Include Classes\ColorCurveParams.ahk              ; https://docs.microsoft.com/es-es/windows/desktop/api/Gdipluseffects/ns-gdipluseffects-colorcurveparams





; #######################################################################################################################
; STATIC METHODS (Gdiplus)                                                                                              #
; #######################################################################################################################
/*
    Creates an Effect object. This method is intended for private use.
    Parameters:
        Guid:
            A string identifying a GUID with the effect to be created.
            See Image Effect Constants / GDI+ effect GUIDs.
    Return value:
        If the method succeeds, the return value is a pointer to the Effect object.
        If the method fails, the return value is zero. To get extended error information, check «Gdiplus.LastStatus».
*/
static Effect(Guid)
{
    local Buffer := BufferAlloc(16)  ; GUID Buffer.
    DllCall("Ole32.dll\CLSIDFromString", "Ptr", &Guid, "Ptr", Buffer, "HRESULT")  ; Throws an exception if an error occurs.

    local pEffect := 0
    Gdiplus.LastStatus := A_PtrSize == 4  ; AutoHotkeyU32.
                        ? DllCall("Gdiplus.dll\GdipCreateEffect", "UInt64", NumGet(Buffer,"UInt64"), "UInt64", NumGet(Buffer,8,"UInt64"), "UPtrP", pEffect)
                        : DllCall("Gdiplus.dll\GdipCreateEffect", "Ptr", Buffer, "UPtrP", pEffect)
    return pEffect  ; Returns a pointer to the GDI+ Effect object.
} ; https://docs.microsoft.com/es-es/windows/win32/gdiplus/-gdiplus-bitmap-flat
