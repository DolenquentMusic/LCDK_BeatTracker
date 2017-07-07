%%%LayerViewer.m

%Loads images of the layer weights.

% David Dolengewicz 2017

path = 'bt3_model_mixed16k.hdf5';

[W1 W2 W3 U1 U2 U3 b1 b2 b3 Vo Vb] = loadWeights(path_model);
a = {W1 W2 W3 U1 U2 U3 b1 b2 b3 Vo Vb};
dims = [];
for ii = 1:11
    dims(ii, :) = size(a{ii});
end


for ii = 1:11
    figure(ii);
    imagesc(a{ii});
end

dims