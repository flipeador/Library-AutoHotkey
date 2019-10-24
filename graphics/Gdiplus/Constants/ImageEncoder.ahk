/*
    The Gdiplus::Image::Save method of the Gdiplus::Image class receive an EncoderParameters object that contains an array of EncoderParameter objects.
    Each EncoderParameter object has a GUID data member that specifies the parameter category.
    The following constants represent GUIDs that specify the various parameter categories.

    Image Encoder Constants:
        https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-constant-image-encoder-constants
*/
static EncoderCompression      := "{E09D739D-CCD4-44EE-8EBA-3FBF8BE4FC58}"  ;
static EncoderColorDepth       := "{66087055-AD66-4C7C-9A18-38A2310B8337}"  ;
static EncoderScanMethod       := "{3A4E2661-3109-4E56-8536-42C156E7DCFA}"  ;
static EncoderVersion          := "{24D18C76-814A-41A4-BF53-1C219CCCF797}"  ;
static EncoderRenderMethod     := "{6D42C53A-229A-4825-8BB7-5C99E2B9A8B8}"  ;
static EncoderQuality          := "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"  ;
static EncoderTransformation   := "{8D0EB2D1-A58E-4EA8-AA14-108074B7B6F9}"  ;
static EncoderLuminanceTable   := "{EDB33BCE-0266-4A77-B904-27216099E717}"  ;
static EncoderChrominanceTable := "{F2E455DC-09B3-4316-8260-676ADA32481C}"  ;
static EncoderSaveFlag         := "{292266FC-AC40-47BF-8CFC-A85B89A655DE}"  ;
static EncoderColorSpace       := "{AE7A62A0-EE2C-49D8-9D07-1BA8A927596E}"  ; (GDIPVER >= 0x0110).
static EncoderImageItems       := "{63875E13-1F1D-45AB-9195-A29B6066A650}"  ; (GDIPVER >= 0x0110).
static EncoderSaveAsCMYK       := "{A219BBC9-0A9D-4005-A3EE-3A421B8BB06C}"  ; (GDIPVER >= 0x0110).
