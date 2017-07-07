#define PI 3.141592

void hanWindow(float *h){
	int ii;
	for(ii = 0; ii<512; ii++){
			h[ii] = 0.5 * ( 1.0 - cos((2*PI*(float)ii)/511.0) );
	}
	return;
}

void twiddleGen(COMPLEX *tw){
	int ii;
	// define twiddle factors
	for(ii=0; ii<512; ii++){
		tw[ii].real = cos((float)ii/(float)512.0*PI);
		tw[ii].imag = sin((float)ii/(float)512.0*PI);
	}
	return;
}
