unsigned __int64 __stdcall GdipBitmapCountPixel(unsigned int * Scan0, int w, int h, int Stride, unsigned int ARGB)
{
   int offset = Stride / 4;
   unsigned __int64 count = 0;

   for (int y1 = 0; y1 < h; ++y1)
   {
      for (int x1 = 0; x1 < w; ++x1)
      {
         if (Scan0[x1+(y1*offset)] == ARGB)
         {
            ++count;
         }
      }
   }

   return count;
}
