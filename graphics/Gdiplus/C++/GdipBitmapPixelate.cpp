int __stdcall GdipBitmapPixelate(unsigned char * sBitmap, unsigned char * dBitmap, int w, int h, int Stride, int Size)
{
    int sA, sR, sG, sB, rw, rh, o;

    for (int y1 = 0; y1 < h/Size; ++y1)
    {
        for (int x1 = 0; x1 < w/Size; ++x1)
        {
            sA = sR = sG = sB = 0;
            for (int y2 = 0; y2 < Size; ++y2)
            {
                for (int x2 = 0; x2 < Size; ++x2)
                {
                    o = 4*(x2+x1*Size)+Stride*(y2+y1*Size);
                    sA += sBitmap[3+o];
                    sR += sBitmap[2+o];
                    sG += sBitmap[1+o];
                    sB += sBitmap[o];
                }
            }
            
            sA /= Size*Size;
            sR /= Size*Size;
            sG /= Size*Size;
            sB /= Size*Size;
            for (int y2 = 0; y2 < Size; ++y2)
            {
                for (int x2 = 0; x2 < Size; ++x2)
                {
                    o = 4*(x2+x1*Size)+Stride*(y2+y1*Size);
                    dBitmap[3+o] = sA;
                    dBitmap[2+o] = sR;
                    dBitmap[1+o] = sG;
                    dBitmap[o] = sB;
                }
            }
        }
        
        if (w % Size != 0)
        {
            sA = sR = sG = sB = 0;
            for (int y2 = 0; y2 < Size; ++y2)
            {
                for (int x2 = 0; x2 < w % Size; ++x2)
                {
                    o = 4*(x2+(w/Size)*Size)+Stride*(y2+y1*Size);
                    sA += sBitmap[3+o];
                    sR += sBitmap[2+o];
                    sG += sBitmap[1+o];
                    sB += sBitmap[o];
                }
            }
            
            int tmp = (w % Size)*Size;
            sA = tmp ? (sA / tmp) : 0;
            sR = tmp ? (sR / tmp) : 0;
            sG = tmp ? (sG / tmp) : 0;
            sB = tmp ? (sB / tmp) : 0;
            for (int y2 = 0; y2 < Size; ++y2)
            {
                for (int x2 = 0; x2 < w % Size; ++x2)
                {
                    o = 4*(x2+(w/Size)*Size)+Stride*(y2+y1*Size);
                    dBitmap[3+o] = sA;
                    dBitmap[2+o] = sR;
                    dBitmap[1+o] = sG;
                    dBitmap[o] = sB;
                }
            }
        }
    }

    for (int x1 = 0; x1 < w/Size; ++x1)
    {
        sA = sR = sG = sB = 0;
        for (int y2 = 0; y2 < h % Size; ++y2)
        {
            for (int x2 = 0; x2 < Size; ++x2)
            {
                o = 4*(x2+x1*Size)+Stride*(y2+(h/Size)*Size);
                sA += sBitmap[3+o];
                sR += sBitmap[2+o];
                sG += sBitmap[1+o];
                sB += sBitmap[o];
            }
        }
        
        int tmp = Size*(h % Size);
        sA = tmp ? (sA / tmp) : 0;
        sR = tmp ? (sR / tmp) : 0;
        sG = tmp ? (sG / tmp) : 0;
        sB = tmp ? (sB / tmp) : 0;
        for (int y2 = 0; y2 < h % Size; ++y2)
        {
            for (int x2 = 0; x2 < Size; ++x2)
            {
                o = 4*(x2+x1*Size)+Stride*(y2+(h/Size)*Size);
                dBitmap[3+o] = sA;
                dBitmap[2+o] = sR;
                dBitmap[1+o] = sG;
                dBitmap[o] = sB;
            }
        }
    }
    
    sA = sR = sG = sB = 0;
    for (int y2 = 0; y2 < h % Size; ++y2)
    {
        for (int x2 = 0; x2 < w % Size; ++x2)
        {
            o = 4*(x2+(w/Size)*Size)+Stride*(y2+(h/Size)*Size);
            sA += sBitmap[3+o];
            sR += sBitmap[2+o];
            sG += sBitmap[1+o];
            sB += sBitmap[o];
        }
    }
    
    int tmp = (w % Size)*(h % Size);
    sA = tmp ? (sA / tmp) : 0;
    sR = tmp ? (sR / tmp) : 0;
    sG = tmp ? (sG / tmp) : 0;
    sB = tmp ? (sB / tmp) : 0;
    for (int y2 = 0; y2 < h % Size; ++y2)
    {
        for (int x2 = 0; x2 < w % Size; ++x2)
        {
            o = 4*(x2+(w/Size)*Size)+Stride*(y2+(h/Size)*Size);
            dBitmap[3+o] = sA;
            dBitmap[2+o] = sR;
            dBitmap[1+o] = sG;
            dBitmap[o] = sB;
        }
    }
    return 0;
}
