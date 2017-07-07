
void absCpx(int len, COMPLEX *x, float *y){
	int ii;
	for(ii = 0; ii < len; ii++){
		y[ii] = sqrt(x[ii].real*x[ii].real + x[ii].imag*x[ii].imag);
	}
	return;
}
