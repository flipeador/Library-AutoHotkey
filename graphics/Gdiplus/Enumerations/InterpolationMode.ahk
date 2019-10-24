/*
    The InterpolationMode enumeration specifies the algorithm that is used when images are scaled or rotated.
    This enumeration is used by the InterpolationMode property of the Gdiplus::Graphics class.

    InterpolationMode Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-interpolationmode
*/
class InterpolationMode
{
    static Invalid             := -1  ; Used internally.
    static Default             :=  0  ; Specifies the default interpolation mode.
    static LowQuality          :=  1  ; Specifies a low-quality mode.
    static HighQuality         :=  2  ; Specifies a high-quality mode.
    static Bilinear            :=  3  ; Specifies bilinear interpolation. No prefiltering is done. This mode is not suitable for shrinking an image below 50 percent of its original size.
    static Bicubic             :=  4  ; Specifies bicubic interpolation. No prefiltering is done. This mode is not suitable for shrinking an image below 25 percent of its original size.
    static NearestNeighbor     :=  5  ; Specifies nearest-neighbor interpolation.
    static HighQualityBilinear :=  6  ; Specifies high-quality, bilinear interpolation. Prefiltering is performed to ensure high-quality shrinking.
    static HighQualityBicubic  :=  7  ; Specifies high-quality, bicubic interpolation. Prefiltering is performed to ensure high-quality shrinking. This mode produces the highest quality transformed images.
}
