const float X[80] = {0.225757, 0.165737, 0.128721, 0.467639, -0.168229, 0.510045, 0.364179, 0.208205, -0.149549, 0.173735, 0.066247, 0.640243, 0.035746, 0.522927, -0.095685, 0.628491, 0.182934, 0.042282, 0.188416, 0.449807, 1.036840, 1.186066, 1.041925, 1.050535, 0.909933, 0.974134, 0.935211, 1.029031, 1.067633, 1.035310, 0.948605, 1.071917, 1.067995, 1.072947, 1.061558, 1.142658, 1.045762, 1.188841, 1.049259, 0.900884, 0.005886, 0.060579, 0.183919, 0.205340, -0.073454, -0.031983, 0.078626, 0.125326, 0.029690, 0.091472, -0.081215, 0.922800, 0.147669, -0.156747, 0.152466, 0.671802, -0.022470, -0.024599, -0.003779, 0.703211, 0.094698, -0.036126, 0.148803, 0.050594, 0.052820, -0.021526, 0.370017, -0.028752, 0.159454, 0.089802, 0.077603, 0.268454, 0.099367, 0.053404, 0.101568, 0.088568, 0.153991, 0.282096, 0.171387, 0.201752};

void b3load(float *Y)       //input sample array, number of points
{
	int i = 0;

	for(i = 0; i < 80; i++){
		  Y[i] =  X[i];

	}

  return;
}