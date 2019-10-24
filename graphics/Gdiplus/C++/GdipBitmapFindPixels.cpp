int __stdcall GdipBitmapFindPixels(unsigned int * Scan0, unsigned int w, unsigned int h, int Stride, unsigned int ARGB, unsigned int * pPoints)
{
   unsigned int offset = (unsigned int) Stride / 4;
   unsigned int count = 0;

   for (unsigned int y1 = 0; y1 < h; ++y1)
   {
      for (unsigned int x1 = 0; x1 < w; ++x1)
      {
         if (Scan0[x1+(y1*offset)] == ARGB)
         {
            pPoints[count++] = x1;
            pPoints[count++] = y1;
         }
      }
   }
   
   return 0;
}
