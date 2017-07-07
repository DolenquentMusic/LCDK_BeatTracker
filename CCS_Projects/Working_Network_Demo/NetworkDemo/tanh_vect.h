#include <math.h>

float fast_tanh(float x){
  if(x>4.97) return 1;
  else if(x<-4.97) return -1;
  else{
	  float x2 = x * x;
	  float a = x * (135135.0f + x2 * (17325.0f + x2 * (378.0f + x2)));
	  float b = 135135.0f + x2 * (62370.0f + x2 * (3150.0f + x2 * 28.0f));
	  return a / b;
  }
}

void tanh_vect(int len, float *x) {

    int ii = 0;
    float y = 0;
    double z = 0;
	for(ii = 0; ii < len; ii++){
		z = x[ii];
		x[ii] = fast_tanh(z);
	}

}

void tanh_vect_pass(int len, float *x, float *y) {

    int ii = 0;
    float z = 0;
	for(ii = 0; ii < len; ii++){
		z = x[ii];
		y[ii] = fast_tanh(z);
	}

}

