#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void hard_sig(int len, float *x) {

    int ii;
    float y;
	for(ii = 0; ii < len; ii++){
		y = (x[ii]*0.2) + 0.5;
		if (y < 0) {
			y = 0;
		} else if (y > 1) {
			y = 1;
		}
		x[ii] = y;
	}

}
