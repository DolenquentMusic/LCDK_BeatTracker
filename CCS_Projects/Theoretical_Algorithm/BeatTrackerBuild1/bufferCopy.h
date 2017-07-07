void bufferCopy(int buffSize, int startIdx, float *buff, int copySize,  float *copy){

	int idx = startIdx;
	int ii;
	for(ii = copySize - 1; ii >= 0; ii--){
		copy[ii] = buff[idx--];
		if(idx < 0) idx = buffSize - 1;
	}

	return;

}
void bufferCopyCpx(int buffSize, int startIdx, float *buff, int copySize,  COMPLEX *copy){

	int idx = startIdx;
	int ii;
	for(ii = copySize - 1; ii >= 0; ii--){
		copy[ii].real = buff[idx--];
		copy[ii].imag = 0;
		if(idx < 0) idx = buffSize - 1;
	}

	return;

}

void concat(int xlen, float *x,int ylen, float *y, float *z) {
	int i;
	int k = 0;
	for(i = 0; i<xlen; i++){
		z[k++] = x[i];
	}
	for(i = 0; i<ylen; i++){
			z[k++] = y[i];
	}

	return;
}

void logmat(int len, float *x){
	int i;
	for(i = 0; i < len; i++){
		x[i] = log(x[i] + .0001);
	}
	return;
}
