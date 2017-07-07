#include "DSP_Config.h"
#include <stdio.h>
#include <stdlib.h>
#include "fft.h"
#include <math.h>

#include "filter16k.h"
#include "loadWeights.h"

#include "matmath.h"

#include "W1inv.h"
#include "inputLoad.h"

#define PI 3.141592
#define BUFFERSIZE  512 //2048
#define FFTSIZE 512
#define TIMEBUFFSIZE 200
#define NETBUFF 10
#define LEDTIMER 10
#define BEAT_DELAY 20;
#define TIMESTEP 160;
const float BEAT_THRESHOLD = 0.96;


COMPLEX fftIn[FFTSIZE], w512[FFTSIZE];
float fftOut[FFTSIZE/2 + 1];
#pragma DATA_SECTION(fftIn, ".fftIn");
#pragma DATA_SECTION(fftOut, ".fftOut");
#pragma DATA_SECTION(w512, ".w512");

int kk, ii, idx, tsCount, audioIdx, inputIdx;
int dofft = 0;

//Weight Vectors
float flt[21][257];
#pragma DATA_SECTION(flt, ".flt");
float W1[80][42];
#pragma DATA_SECTION(W1, ".w1");
float W2[80][20];
#pragma DATA_SECTION(W2, ".w2");
float W3[80][20];
#pragma DATA_SECTION(W3, ".w3");
float U1[80][20];
#pragma DATA_SECTION(U1, ".u1");
float U2[80][20];
#pragma DATA_SECTION(U2, ".u2");
float U3[80][20];
#pragma DATA_SECTION(U3, ".u3");
float b1[80];
#pragma DATA_SECTION(b1, ".b1");
float b2[80];
#pragma DATA_SECTION(b2, ".b2");
float b3[80];
#pragma DATA_SECTION(b3, ".b3");
float Vo[26][20];
#pragma DATA_SECTION(Vo, ".vo");
float Vb[26];
#pragma DATA_SECTION(Vb, ".vb");


///*****//Network Connections
float h0[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
float c0[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

//Layer 1
float z1[80];
float i1[20];
float f1[20];
float o1[20];
float Chat1[20];
//time steps first for h and C
float h1[10][20];
float C1[10][20];
float temp20_1[20];

//Layer 2
float z2[80];
float i2[20];
float f2[20];
float o2[20];
float Chat2[20];
//time steps first for h and C
float h2[10][20];
float C2[10][20];
float temp20_2[20];

//Layer 3
float z3[80];
float i3[20];
float f3[20];
float o3[20];
float Chat3[20];
//time steps first for h and C
float h3[10][20];
float C3[10][20];
float temp20_3[20];

float output[TIMEBUFFSIZE][26];
#pragma DATA_SECTION(output, ".output");
float out3[10][3];

///***/// End Network Connections


float han512[512];

//test vars
/*
float W1inv[42][80];
float mmTest[80][80];
float smTest[26];
float dotTest[26];
float mulProd[2][1];
float addTest[80];
*/

float input[16000];
#pragma DATA_SECTION(input, ".input");


int time = -1; int time_m1 = 0; int time_m2 = 0;
int beatdly = 0;
int units = 20;
int ledCount = LEDTIMER;
short isBeat = 0;
float features[42];
float logdiffs[21];

float filterOut[TIMEBUFFSIZE][21];
#pragma DATA_SECTION(filterOut, ".filterOut");
float beatActivation[TIMEBUFFSIZE];
#pragma DATA_SECTION(beatActivation, ".beatActivation");
short beatVector[TIMEBUFFSIZE];
#pragma DATA_SECTION(beatVector, ".beatVector");


//audio buffers
float audioIn[BUFFERSIZE];
#pragma DATA_SECTION(audioIn, ".audioIn");


int main()
{
	//DSP_Init();


	tsCount = 0;
	audioIdx = 0;
	zeroVectorFloat(BUFFERSIZE, audioIn);
	zeroVectorShort(TIMEBUFFSIZE, beatVector);
	filter16k(flt);
	loadWeights20(W1, W2, W3, U1, U2, U3, b1, b2, b3, Vo, Vb);     //input Weights arrays of units = 20
	hanWindow(han512);
	twiddleGen(w512);
	//inputLoad(input);
	soundLoad(input);



	dofft = 1;
	inputIdx = 511;
	bufferCopy(BUFFERSIZE, 511, input, BUFFERSIZE, audioIn);
	audioIdx = 511;
	time = 0;
	inputIdx = time;

	while(1) {


		if(time >= inputIdx) dofft = 1;

		if(dofft) {
			inputIdx += TIMESTEP;
			if(inputIdx >= 16000) inputIdx = 511;
		bufferCopy(BUFFERSIZE, inputIdx, input, BUFFERSIZE, audioIn);

		time_m1 = time - 1;
		time_m2 = time - 2;
		if(time_m1 < 0) time_m1 += TIMEBUFFSIZE;
		if(time_m1 < 0) time_m2 += TIMEBUFFSIZE;


		bufferCopyCpx(BUFFERSIZE, audioIdx, audioIn, BUFFERSIZE, fftIn);
		//zeroVectorCpxI(512, fftIn);
		point_mult_cpxR( han512, fftIn, 512, fftIn);
		fft(fftIn, FFTSIZE, w512);
		absCpx(FFTSIZE/2 + 1, fftIn, fftOut);
		matmul(21, 257, (float *)flt, 1,  (float *)fftOut, (float *)filterOut[time]); // W1 * input

		logmat(21, filterOut[time]);
		if(time == 0){
			concat(21, filterOut[time], 21, filterOut[time], features);
		}
		else { //weird skip here
			matsub(21, filterOut[time], filterOut[time_m1], logdiffs);
			concat(21, filterOut[time],21, logdiffs, features);
		}


		//forward pass

		//Layer 1
		if(time == 0){ //memory fault
			matmul(80, 20, (float *)U1, 1,  (float *)h0, (float *)temp20_1);
			matmul(80, 20, (float *)U2, 1,  (float *)h0, (float *)temp20_2);
			matmul(80, 20, (float *)U3, 1,  (float *)h0, (float *)temp20_3);
		}
		else {
			matmul(80, 20, (float *)U1, 1,  (float *)h1[time_m1], (float *)temp20_1);
			matmul(80, 20, (float *)U2, 1,  (float *)h2[time_m1], (float *)temp20_2);
			matmul(80, 20, (float *)U3, 1,  (float *)h3[time_m1], (float *)temp20_3);
		}


				matmul(80, 42, (float *)W1, 1,  (float *)features, (float *)z1); // W1 * input
				matadd(80, z1, temp20_1, z1);	//Z += U*Htm1
				matadd(80, z1, b1, z1);
				//i, f, Chat, o //1
				zdivider(units, z1, i1, f1, Chat1, o1);
				hard_sig(20, i1);
				hard_sig(20, f1);
				tanh_vect(20, Chat1);
				hard_sig(20, o1);
				point_mult(i1, Chat1, 20, Chat1);

				if(time == 0){
					point_mult(f1, c0, 20, C1[time]);
				}
				else {
					point_mult(f1, C1[time_m1], 20, C1[time]);
				}

				matadd(20, Chat1, C1[time], C1[time]);
				tanh_vect_pass(20, C1[time], h1[time]);
				point_mult(o1, h1[time], 20, h1[time]);


				//Layer 2
				matmul(80, 20, (float *)W2, 1,  (float *)h1[time], (float *)z2);
				matadd(80, z2, temp20_2, z2);
				matadd(80, z2, b1, z2);
				//i, f, Chat, o //1
				zdivider(units, z2, i2, f2, Chat2, o2);
				hard_sig(20, i2); hard_sig(20, f2);
				tanh_vect(20, Chat2);
				hard_sig(20, o2);
				point_mult(i2, Chat2, 20, Chat2);
				if(time == 0) {
				point_mult(f2, c0, 20, C2[time]);
				}
				else {
					point_mult(f2, C2[time_m1], 20, C2[time]);
				}

				matadd(20, Chat2, C2[time], C2[time]);
				tanh_vect_pass(20, C2[time], h2[time]);
				point_mult(o2, h2[time], 20, h2[time]);

				//Layer 3
				matmul(80, 20, (float *)W3, 1,  (float *)h2[time], (float *)z3);
				matadd(80, z3, temp20_3, z3);
				matadd(80, z3, b3, z3);
				//i, f, Chat, o //1
				zdivider(units, z3, i3, f3, Chat3, o3);
				hard_sig(20, i3); hard_sig(20, f3);
				tanh_vect(20, Chat3);
				hard_sig(20, o3);
				point_mult(i3, Chat3, 20, Chat3);
				if(time == 0) {
					point_mult(f3, c0, 20, C3[time]);
				}
				else {
					point_mult(f1, C3[time_m1], 20, C3[time]);
				}
				matadd(20, Chat3, C3[time], C3[time]);
				tanh_vect_pass(20, C3[time], h3[time]);
				point_mult(o3, h3[time], 20, h3[time]);

				//output Layer
				matmul(26, 20, (float *)Vo, 1,  (float *)h3[time], (float *)output[time]);
				matadd(26, output[time], Vb, output[time]);

				softmax(output[time]);

				if(time == 0){
					beatActivation[time]=output[time][0];
				}
				else if(time == 1){
					beatActivation[time] = output[time][0] + output[time_m1][1];
				}
				if(time > 1){
					beatActivation[time] = beatActivationFunct(output[time], output[time_m1], output[time_m2]);
				}

				if(beatdly <= 0 && beatActivation[time] > BEAT_THRESHOLD)  {
					isBeat = 1;
					ledCount = 0;
					WriteLEDs(15);
					beatVector[time] = 1;
					beatdly = BEAT_DELAY + 1;
				}

				if(ledCount < LEDTIMER){
					ledCount++;
				}
				else {
					WriteLEDs(0);
					isBeat = 0;
				}

				if(beatdly > 0)	beatdly--;



				wait(100000);

				dofft = 0;


		}
		time++;
		if(time > 16000) time = 1;
		//wait(100000);
	}

/*
	for(time = 0; time < TIMEBUFFSIZE; time++)
	{

	}
	

*/


	while(1) {


	}
}

