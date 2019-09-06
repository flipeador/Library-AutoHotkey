HimetricToPixel(Pixel, DPI := 0)
{
    return Pixel * (1.0 / 2540.0) * ( DPI ? DPI : A_ScreenDPI )
} ;https://es.wikipedia.org/wiki/Píxel





PixelToHimetric(Pixel, DPI := 0)
{
    return ( Pixel * 2.54 / ( DPI ? DPI : A_ScreenDPI ) ) * 1000.0
} ; https://en.wikipedia.org/wiki/Himetric | https://www.pixelto.net/px-to-cm-converter | http://www.justintools.com/unit-conversion/length.php?k1=centimeters&k2=himetrics





RadianToDegree(Radians, Centesimal := FALSE)
{
    return Centesimal
         ? Radians * 63.6619772368  ; 200/pi | 200/3.14159265359 = 63.6619772368.
         : Radians * 57.2957795131  ; 180/pi | 180/3.14159265359 = 57.2957795131.
}





/*
    Convertir grado sexagesimal/centesimal a radian.
*/
DegreeToRadian(Degrees, Centesimal := FALSE)
{
    return Centesimal
         ? Degrees * 0.01570796326  ; pi/200 | 3.14159265359/200 = 0.01570796326.
         : Degrees * 0.01745329251  ; pi/180 | 3.14159265359/180 = 0.01745329251.
}





CmToTwip(CM)
{
    return CM / 2.54 * 1440.0
}





TwipToCm(Twip)
{
    return Twip * 2.54 / 1440.0
}





TwipToPixel(Twip, DPI := 0)
{
    return Twip * ( DPI ? DPI : A_ScreenDPI ) / 1440
}





PixelToTwip(Pixel, DPI := 0)
{
    return Pixel / ( DPI ? DPI : A_ScreenDPI ) * 1440
}
