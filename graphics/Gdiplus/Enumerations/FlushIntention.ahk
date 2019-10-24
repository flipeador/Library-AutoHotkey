/*
    The FlushIntention enumeration specifies when to flush the queue of graphics operations.

    FlushIntention Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-flushintention
*/
class FlushIntention
{
    static Flush := 0  ; Flush all batched rendering operations.
    static Sync  := 1  ; Flush all batched rendering operations and wait for them to complete.
}
