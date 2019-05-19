#Include Base64ToComByteArray.ahk
#Include ComByteArrayToBitmap.ahk





Base64ToBitmap(Base64)
{
    try
        return ComByteArrayToBitmap(Base64ToComByteArray(Base64))
    return 0
}
