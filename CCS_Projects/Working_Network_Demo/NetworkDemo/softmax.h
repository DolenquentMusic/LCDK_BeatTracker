#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void softmax(float z[]) {
    int i;
    int n = 26;
    float z_exp[26];
    for (i=0; i<n; i++) {
        z_exp[i] = exp(z[i]);
    }

    float sum = 0;
    for (i=0; i<n; i++) {
        sum += z_exp[i];
    }

    for (i=0; i<n; i++) {
        z[i] = (z_exp[i]/sum);

    }

    return;
}
