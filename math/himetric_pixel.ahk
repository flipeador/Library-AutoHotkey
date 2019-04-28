HimetricToPixel(Pixel, DPI := 0)
{
    Return Pixel * (1.0 / 2540.0) * ( DPI ? DPI : A_ScreenDPI )
} ;https://es.wikipedia.org/wiki/Píxel





PixelToHimetric(Pixel, DPI := 0)
{
    return ( Pixel * 2.54 / ( DPI ? DPI : A_ScreenDPI ) ) * 1000.0
} ; https://en.wikipedia.org/wiki/Himetric | https://www.pixelto.net/px-to-cm-converter | http://www.justintools.com/unit-conversion/length.php?k1=centimeters&k2=himetrics
