#include "DSP_Config.h"

#define LEFT 0
#define RIGHT 1
#define BUFFERSIZE 512
#define TIMESTEP 160
#define TIMELIMIT 1000


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

extern int kk, ii, idx, tsCount, audioIdx;
extern int dofft;
extern float audioIn[BUFFERSIZE];
extern int time, inputIdx;
extern float input[];



interrupt void Codec_ISR()
{
	if(CheckForOverrun()) // overrun error occurred (i.e. halted DSP)
		return; // so serial port is reset to recover


	CodecDataIn.UINT = ReadCodecData(); // get input data samples
	 /* add your code starting here */

	//audioIn[audioIdx] = CodecDataIn.Channel[RIGHT];


	audioIdx++; tsCount++;
	if(audioIdx >= BUFFERSIZE){
		audioIdx = 0;
	}
	if(tsCount >= TIMESTEP){
		tsCount = 0;
		dofft = 1;
		time++;
		if(time > TIMELIMIT) time = 1;
	}

	CodecDataOut.Channel[RIGHT] = input[inputIdx];
	CodecDataOut.Channel[LEFT] = input[inputIdx++];

	if(inputIdx > 5000) inputIdx = 0;

	WriteCodecData(CodecDataOut.UINT); // send output data to port
}
