
void matadd(int row, float *x1, float *x2, float *y) {
    int i;

    for (i=0; i<row; i++) {
        y[i] = (x1[i] + x2[i]);
    }
}

void matsub(int row, float *x1, float *x2, float *y) {
    int i;

    for (i=0; i<row; i++) {
        y[i] = (x1[i] - x2[i]);
    }
}
