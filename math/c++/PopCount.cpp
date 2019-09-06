unsigned int _stdcall popcount64d(unsigned __int64 x)
{
	unsigned int count;
    for (count=0; x; count++)
        x &= x - 1;
    return count;
}
