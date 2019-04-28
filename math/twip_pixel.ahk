TwipToPixel(Twip, DPI := 0)
{
    return Twip * ( DPI ? DPI : A_ScreenDPI ) / 1440
}




PixelToTwip(Pixel, DPI := 0)
{
    return Pixel / ( DPI ? DPI : A_ScreenDPI ) * 1440
}
