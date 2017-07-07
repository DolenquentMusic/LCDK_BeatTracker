#include "DSP_Config.h"

#define LEFT 0
#define RIGHT 1

#define BUFFER_SIZE 4096
#define TIME_STEP 441


volatile union {
Uint32 UINT;
Int16 Channel[2];
} CodecDataIn, CodecDataOut;

struct cmpx //complex data structure used by FFT
 {
 float real;
 float imag;
 };

typedef struct cmpx COMPLEX;
/* add any global variables here */

extern int kk, ii, idx;
extern int startflag;
extern COMPLEX X[2048];



interrupt void Codec_ISR()
{
	if(CheckForOverrun()) // overrun error occurred (i.e. halted DSP)
		return; // so serial port is reset to recover


	CodecDataIn.UINT = ReadCodecData(); // get input data samples
	 /* add your code starting here */
/*
	if( kk > TIME_STEP ) {
		kk = 0;
		startflag = 1;

	}


		X[idx].real = CodecDataIn.Channel[RIGHT];
		X[idx].imag = 0;
		idx++;

		if(idx>BUFFER_SIZE) {
			idx = 0;
		}

*/
	CodecDataOut.Channel[RIGHT] = CodecDataIn.Channel[RIGHT];
	CodecDataOut.Channel[LEFT] = CodecDataIn.Channel[RIGHT];

	WriteCodecData(CodecDataOut.UINT); // send output data to port
}
