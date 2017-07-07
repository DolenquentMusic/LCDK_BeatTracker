#include <stdio.h>
#include <stdlib.h>
#include <math.h>


void point_mult(const float v[], const float u[], int n, float y[]){
    float result = 0.0;
    int i;
    for (i = 0; i < n; i++)
        y[i] = v[i]*u[i];

    return;
}
