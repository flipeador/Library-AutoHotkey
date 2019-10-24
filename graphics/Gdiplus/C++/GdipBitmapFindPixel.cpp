unsigned int __stdcall GdipBitmapFindPixel(unsigned int * Scan0, int w, int h, int Stride, unsigned int ARGB, int * x, int * y)
{
    int offset = Stride / 4;

    for (int y1 = 0; y1 < h; ++y1)
    {
        for (int x1 = 0; x1 < w; ++x1)
        {
            if (Scan0[x1+(y1*offset)] == ARGB)
            {
                x[0] = x1; y[0] = y1;
                return 0;    // Ok
            }
        }
    }
    
    return 1;    // GenericError
}
