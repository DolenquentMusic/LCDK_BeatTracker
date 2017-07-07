By loading and running Batchy16k.m (and ensuring the path points 
to the Mixed_datafiles folder or a similar folder containing 
songs as .wav files and associated beat annotations in .txt files),
this script will populate the Mixed_Processed_16k folder with .h5 files
containing the features breakdown of the audio file and the corresponding binary
vector of the beats.

Running textGen.m with the folder of the processed .h5 files will generate
text files dividing these files into training, validation and testing datasets.