#include <stdio.h>
#include <stdlib.h>
#include <math.h>


void point_mult( float v[], float u[], int n, float y[]){

    int i;
    for (i = 0; i < n; i++)
        y[i] = v[i]*u[i];

    return;
}

void point_mult_cpxR( float v[], COMPLEX u[], int n, COMPLEX y[]){

    int i;
    for (i = 0; i < n; i++)
        y[i].real = v[i]*u[i].real;

    return;
}
