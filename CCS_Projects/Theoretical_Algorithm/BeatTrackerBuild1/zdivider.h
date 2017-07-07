


void zdivider(int units, float *z, float *i, float *f, float *Chat, float *o)
{
	int zidx = 0;
	int idx;
	for(idx = 0; idx < units; idx++){
		i[idx] = z[zidx++];
	}
	for(idx = 0; idx < units; idx++){
		f[idx] = z[zidx++];
	}
	for(idx = 0; idx < units; idx++){
		Chat[idx] = z[zidx++];
	}
	for(idx = 0; idx < units; idx++){
		o[idx] = z[zidx++];
	}

}
