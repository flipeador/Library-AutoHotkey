#define min(a,b)            (((a) < (b)) ? (a) : (b))
#define max(a,b)            (((a) > (b)) ? (a) : (b))


double _stdcall Remap(double value, double old_min, double old_max, double new_min, double new_max)
{
	// Range check.
	if (old_min == old_max)
		throw 0x00000001;
	if (new_min == new_max)
		throw 0x00000002;
	
	// Check reversed input range.
	double old_min2 = min(old_min, old_max);
	double old_max2 = max(old_min, old_max);

	// Check reversed output range.
	double new_min2 = min(new_min, new_max);
	double new_max2 = max(new_min, new_max);

	double portion = (old_min2 == old_min)
		? ((value - old_min2) * (new_max2 - new_min2) / (old_max2 - old_min2))
		// Reverse input.
		: ((value - old_min2) * (new_max2 - new_min2) / (old_max2 - old_min2));

	return (new_min2 == new_min)
		? (portion + new_min2)
		// Reverse output.
		: (new_max2 - portion);
} // https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
