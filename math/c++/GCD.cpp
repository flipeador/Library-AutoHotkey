size_t _stdcall GCD(size_t x, size_t y)
{
    while (y)
    {
        size_t r = x % y;
        x = y;
        y = r;
    }
    return x;
}
