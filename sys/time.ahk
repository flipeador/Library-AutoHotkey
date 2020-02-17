/*
    Formats a duration of time as a time string for a locale specified by name.
    Parameters:
        LocaleName:
            A locale name, or one of the following predefined values.
            ┌─────────────────────────┬────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │          Value          │          Constant          │                                                                                                      Meaning                                                                                                      │
            ├─────────────────────────┼────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0                       │ LOCALE_NAME_USER_DEFAULT   │ Name of an invariant locale that provides stable locale and calendar data.                                                                                                                                        │
            │ ""                      │ OCALE_NAME_INVARIANT       │ Name of the current user locale, matching the preference set in the regional and language options portion of Control Panel. This locale can be different from the locale for the current user interface language. │
            │ "!x-sys-default-locale" │ LOCALE_NAME_SYSTEM_DEFAULT │ Name of the current operating system locale.                                                                                                                                                                      │
            └─────────────────────────┴────────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        Duration:
            A SYSTEMTIME structure (Buffer-like object) that contains the time duration information to format.
            SYSTEMTIME structure: (https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime).
            ---------------------------------------------------------------------------------------
            A 64-bit unsigned integer that represents the number of 100-nanosecond intervals in the duration.
            To specify milliseconds, multiply this value by 10000.
        Format:
            The format string with characters as shown below. Single quotes are used to escape characters.
            If this parameter is 0, the function is to format the string according to the duration format for the specified locale.
            If this parameter is not set to 0, the function uses the locale only for information not specified in the format picture string.
            ┌───────────┬────────────────────────────────────────────────────┐
            │ Character │                      Meaning                       │
            ├───────────┼────────────────────────────────────────────────────┤
            │ d         │ Days.                                              │
            │ h  / H    │ Hours.                                             │
            │ hh / HH   │ Hours; if less than ten, prepend a leading zero.   │
            │ m         │ Minutes.                                           │
            │ mm        │ Minutes; if less than ten, prepend a leading zero. │
            │ s         │ Seconds.                                           │
            │ ss        │ Seconds; if less than ten, prepend a leading zero. │
            │ f         │ Fractions of a second.                             │
            │ ''        │ Characters between single quotes are escaped.      │
            └───────────┴────────────────────────────────────────────────────┘
        Flags:
            Flags specifying various function options that can be set if «Format» is set to 0.
            ┌────────────┬───────────────────────┬──────────────────────────────────────────────────────────────────────────────────────┐
            │   Value    │       Constant        │                                      Meaning                                         │
            ├────────────┼───────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x80000000 │ LOCALE_NOUSEROVERRIDE │ Format the string using the system default duration format for the specified locale. │
            └────────────┴───────────────────────┴──────────────────────────────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is the duration string.
        If the function fails, an exception is thrown describing the error. A_LastError contains extended error information.
        ┌────────────┬───────────────────────────┬─────────────────────────────────────────────────────────────────────────────────┐
        │   Value    │         Constant          │                                     Meaning                                     │
        ├────────────┼───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
        │ 0x0000007A │ ERROR_INSUFFICIENT_BUFFER │ A supplied buffer size was not large enough, or it was incorrectly set to NULL. │
        │ 0x00000057 │ ERROR_INVALID_PARAMETER   │ Any of the parameter values was invalid.                                        │
        └────────────┴───────────────────────────┴─────────────────────────────────────────────────────────────────────────────────┘
    Remarks:
        This function can format data that changes between releases, for example, due to a custom locale.
        If your application must persist or transmit data, see Using Persistent Locale Data.
    Using Persistent Locale Data:
        https://docs.microsoft.com/en-us/windows/win32/intl/using-persistent-locale-data
    Format milliseconds without DllCall:
        ┌─────────┬───────────────────────────┐
        │  Type   │           Code            │
        ├─────────┼───────────────────────────┤
        │ Days    │ Floor(ms/86400000)        │
        │ Hours   │ Floor(Mod(ms/3600000,24)) │
        │ Minutes │ Floor(Mod(ms/60000,60))   │
        │ Seconds │ Floor(Mod(ms/1000,60))    │
        └─────────┴───────────────────────────┘
        https://www.autohotkey.com/boards/viewtopic.php?t=45476#p217893
    Example:
        MsgBox(GetTimeFormat("",654546541653*10000,"d'`sdays`s'h:mm:ss"))  ; 7575 days 18:29:01.
*/
GetTimeFormat(LocaleName, Duration, Format, Flags := 0)  ; WIN_V+
{
    local DurationStr := BufferAlloc(2*256)  ; Buffer in which the function retrieves the duration string.
    if DllCall("Kernel32.dll\GetDurationFormatEx",    "Ptr", Type(LocaleName)=="String" ? &LocaleName : LocaleName  ; lpLocaleName.
                                                 ,   "UInt", Flags                                                  ; dwFlags.
                                                 ,   "UPtr", IsObject(Duration) ? Duration.Ptr : 0                  ; lpDuration.
                                                 , "UInt64", IsObject(Duration) ? 0            : Duration           ; ullDuration.
                                                 ,    "Ptr", Type(Format)    =="String" ? &Format     : Format      ; lpFormat.
                                                 ,   "UPtr", DurationStr.Ptr                                        ; lpDurationStr.
                                                 ,    "Int", DurationStr.Size//2)                                   ; cchDuration.
        return StrGet(DurationStr)
    throw Exception(A_LastError==0x7A?"ERROR_INSUFFICIENT_BUFFER":A_LastError==0x57?"ERROR_INVALID_PARAMETER":"Unknown error."
        , -1, Format("Function {} error 0x{:08X}.",A_ThisFunc,A_LastError))
} ; https://docs.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getdurationformatex





/*
    Formats a date as a date string for a locale specified by name. The function formats either a specified date or the local system date.
    Parameters:
        LocaleName:
            See the GetTimeFormat function.
        Date:
            A SYSTEMTIME structure that contains the date information to format.
            If this parameter is 0, the function uses the current local system date.
            SYSTEMTIME structure: (https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime).
        Format:
            A string that is used to form the date as shown below. Single quotes are used to escape characters.
            If the application must display a single quotation mark, it should place two single quotation marks in a row.
            ┌─────────────────────────────────────────────────────────────────────────────────────┐
            │         The following table defines the format types used to represent days         │
            ├───────────┬─────────────────────────────────────────────────────────────────────────┤
            │ Character │                                 Meaning                                 │
            ├───────────┼─────────────────────────────────────────────────────────────────────────┤
            │ d         │ Day of the month as digits without leading zeros for single-digit days. │
            │ dd        │ Day of the month as digits with leading zeros for single-digit days.    │
            │ ddd       │ Abbreviated day of the week.                                            │
            │ dddd      │ Day of the week.                                                        │
            └───────────┴─────────────────────────────────────────────────────────────────────────┘
            ┌───────────────────────────────────────────────────────────────────────────────────┐
            │       The following table defines the format types used to represent months       │
            ├───────────┬───────────────────────────────────────────────────────────────────────┤
            │ Character │                                Meaning                                │
            ├───────────┼───────────────────────────────────────────────────────────────────────┤
            │ M         │ Month as digits without leading zeros for single-digit months.        │
            │ MM        │ Month as digits with leading zeros for single-digit months.           │
            │ MMM       │ Abbreviated month.                                                    │
            │ MMMM      │ Month.                                                                │
            └───────────┴───────────────────────────────────────────────────────────────────────┘
            ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │                   The following table defines the format types used to represent years                    │
            ├───────────┬───────────────────────────────────────────────────────────────────────────────────────────────┤
            │ Character │                                            Meaning                                            │
            ├───────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
            │ y         │ Year represented only by the last digit.                                                      │
            │ yy        │ Year represented only by the last two digits. A leading zero is added for single-digit years. │
            │ yyyy      │ Year represented by a full four or five digits, depending on the calendar used.               │
            └───────────┴───────────────────────────────────────────────────────────────────────────────────────────────┘
            ┌────────────────────────────────────────────────────────────────────────────────────────┐
            │    The following table defines the format types used to represent a period or era.     │
            ├───────────┬────────────────────────────────────────────────────────────────────────────┤
            │ Character │                                  Meaning                                   │
            ├───────────┼────────────────────────────────────────────────────────────────────────────┤
            │ g, gg     │ Period/era string. Ignored if there is no associated era or period string. │
            └───────────┴────────────────────────────────────────────────────────────────────────────┘
            The function uses the specified locale only for information not specified in the format picture string.
            The application can set this parameter to 0 to format the string according to the date format for the specified locale.
        Flags:
            Flags specifying various function options that can be set if «Format» is set to 0.
            ┌────────────┬───────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
            │ Value      │ Constant              │ Meaning                                                                                                                                                                                                                                                                                                                                                                                      │
            ├────────────┼───────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
            │ 0x80000000 │ LOCALE_NOUSEROVERRIDE │ Format the string using the system default duration format for the specified locale.                                                                                                                                                                                                                                                                                                         │
            │ 0x00000040 │ DATE_AUTOLAYOUT       │ Windows 7 and later: Detect the need for right-to-left and left-to-right reading layout using the locale and calendar information, and add marks accordingly. This value cannot be used with DATE_LTRREADING or DATE_RTLREADING. DATE_AUTOLAYOUT is preferred over DATE_LTRREADING and DATE_RTLREADING because it uses the locales and calendars to determine the correct addition of marks. │
            │ 0x00000002 │ DATE_LONGDATE         │ Use the long date format. This value cannot be used with DATE_MONTHDAY, DATE_SHORTDATE, or DATE_YEARMONTH.                                                                                                                                                                                                                                                                                   │
            │ 0x00000010 │ DATE_LTRREADING       │ Add marks for left-to-right reading layout. This value cannot be used with DATE_RTLREADING.                                                                                                                                                                                                                                                                                                  │
            │ 0x00000020 │ DATE_RTLREADING       │ Add marks for right-to-left reading layout. This value cannot be used with DATE_LTRREADING.                                                                                                                                                                                                                                                                                                  │
            │ 0x00000001 │ DATE_SHORTDATE        │ Use the short date format. This is the default. This value cannot be used with DATE_MONTHDAY, DATE_LONGDATE, or DATE_YEARMONTH.                                                                                                                                                                                                                                                              │
            │ 0x00000004 │ DATE_USE_ALT_CALENDAR │ Use the alternate calendar, if one exists, to format the date string. If this flag is set, the function uses the default format for that alternate calendar, rather than using any user overrides. The user overrides will be used only in the event that there is no default format for the specified alternate calendar.                                                                   │
            │ 0x00000008 │ DATE_YEARMONTH        │ Use the year/month format. This value cannot be used with DATE_MONTHDAY, DATE_SHORTDATE, or DATE_LONGDATE.                                                                                                                                                                                                                                                                                   │
            │ 0x00000080 │ DATE_MONTHDAY         │ Windows 10: Use the combination of month and day formats appropriate for the specified locale. This value cannot be used with DATE_YEARMONTH, DATE_SHORTDATE, or DATE_LONGDATE.                                                                                                                                                                                                              │
            └────────────┴───────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    Return value:
        If the function succeeds, the return value is the formatted date string.
        If the function fails, an exception is thrown describing the error. A_LastError contains extended error information.
        ┌────────────┬───────────────────────────┬─────────────────────────────────────────────────────────────────────────────────┐
        │   Value    │         Constant          │                                     Meaning                                     │
        ├────────────┼───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
        │ 0x0000007A │ ERROR_INSUFFICIENT_BUFFER │ A supplied buffer size was not large enough, or it was incorrectly set to NULL. │
        │ 0x000003EC │ ERROR_INVALID_FLAGS       │ The values supplied for flags were not valid.                                   │
        │ 0x00000057 │ ERROR_INVALID_PARAMETER   │ Any of the parameter values was invalid.                                        │
        └────────────┴───────────────────────────┴─────────────────────────────────────────────────────────────────────────────────┘
    Day, Month, Year, and Era Format Pictures:
        https://docs.microsoft.com/en-us/windows/win32/intl/day--month--year--and-era-format-pictures
    Example:
        MsgBox(GetDateFormat(0,GetSystemTime(),"dddd,`sMMMM`syyyy"))
*/
GetDateFormat(LocaleName, Date, Format, Flags := 0)
{
    local DateStr := BufferAlloc(2*256)  ; Buffer in which the function retrieves the formatted date string.
    if DllCall("Kernel32.dll\GetDateFormatEx",    "Ptr", Type(LocaleName)=="String" ? &LocaleName : LocaleName  ; lpLocaleName.
                                             ,   "UInt", Flags                                                  ; dwFlags.
                                             ,    "Ptr", Date                                                   ; SYSTEMTIME*.
                                             ,    "Ptr", Type(Format)    =="String" ? &Format     : Format      ; lpFormat.
                                             ,   "UPtr", DateStr.Ptr                                            ; lpDateStr.
                                             ,    "Int", DateStr.Size//2                                        ; cchDate.
                                             ,   "UPtr", 0)                                                     ; lpCalendar.
        return StrGet(DateStr)
    throw Exception(A_LastError==0x7A?"ERROR_INSUFFICIENT_BUFFER":A_LastError==0x57?"ERROR_INVALID_PARAMETER"
        :A_LastError==0x3EC?"ERROR_INVALID_FLAGS":"Unknown error.", -1, Format("Function {} error 0x{:08X}.",A_ThisFunc,A_LastError))
} ; https://docs.microsoft.com/en-us/windows/win32/api/datetimeapi/nf-datetimeapi-getdateformatex





/*
    Retrieves the current system date and time. The system time is expressed in Coordinated Universal Time (UTC).
    Parameters:
        Buffer:
            A SYSTEMTIME structure to receive the current system date and time.
            If this parameter is 0, a 16-byte buffer is automatically allocated and returned.
    Return value:
        Returns the value specified in parameter «Buffer».
*/
GetSystemTime(Buffer := 0)
{
    DllCall("Kernel32.dll\GetSystemTime", "Ptr", Buffer:=(Buffer||BufferAlloc(16)))
    return Buffer  ; SYSTEMTIME structure.
} ; https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemtime





/*
    Retrieves the current local date and time. See the GetSystemTime function.
*/
GetLocalTime(Buffer := 0)
{
    DllCall("Kernel32.dll\GetLocalTime", "Ptr", Buffer:=(Buffer||BufferAlloc(16)))
    return Buffer  ; SYSTEMTIME structure.
} ; https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getlocaltime
