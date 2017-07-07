%Layer Saver
% Generates .txt files containing the network weights for importing
% into C code

% David Dolengewicz 2017

inpath = 'bt3_model_mixed16k_final.hdf5';
outpath = 'layerTexts16k_v2/';
if ~isdir(outpath) mkdir(outpath); end

[W1 W2 W3 U1 U2 U3 b1 b2 b3 Vo Vb] = loadWeights(path_model);


matExp(W1, [outpath 'W1.txt']);
matExp(U1, [outpath 'U1.txt']);
listExp(b1, [outpath 'b1.txt']);
matExp(W2, [outpath 'W2.txt']);
matExp(U2, [outpath 'U2.txt']);
listExp(b2, [outpath 'b2.txt']);
matExp(W3, [outpath 'W3.txt']);
matExp(U3, [outpath 'U3.txt']);
listExp(b3, [outpath 'b3.txt']);
matExp(Vo, [outpath 'Vo.txt']);
listExp(Vb, [outpath 'Vb.txt']);
