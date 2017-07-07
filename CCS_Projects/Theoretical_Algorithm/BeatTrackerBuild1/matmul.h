#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void matmul( int r1, int c1, float *x1, int c2, float *x2, float *y) {
    int i, j, k, c;
    float sum;
    c = 0;

    // Multiply each row in x1 by each column in x2.
    // The product of row m in x1 and column n in x2 is placed
    // in position (m,n) in the result.
    for (i = 0; i < r1; i++) {
        for (j = 0; j < c2; j++){
            sum = 0;
            for (k = 0; k < c1; k++) {
                sum +=  (*(x1+k+i*c1)) *  (*(x2+j+k*c2));
				//sum += x1[k + i * c1] * x2[j + k * c2];

            }

            *(y + c) = sum;
            c++;
        }
    }
}

