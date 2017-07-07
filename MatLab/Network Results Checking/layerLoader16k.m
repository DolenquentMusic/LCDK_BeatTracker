%%% layerLoader16k.m
%{
Takes .h5 files containing input 'frames' and output 'beats' vectors
as well as one hot beat representations and full predictions from 
testSongPredictions.mat.

Uses the frames data to generate LSTM network predictions using the 
network model given in path_model and compares them to the actual 
beats from testSongPredictions.mat

David Dolengewicz 2017
%}


clear all
close all

plotSpecs = true;
plotPreds = true;
%path_weights = '\BeatTrackinCode\Currated_Code\LayerLoader\bt3_weights_mixed1024_1.h5';
path_input = 'TestSong_Data16k\';
path_model = 'bt3_model_mixed16k_final.hdf5';
load('testSongPredictions.mat');

units = 20;

[W1 W2 W3 U1 U2 U3 b1 b2 b3 Vo Vb] = loadWeights(path_model);
[filenames, filecount] = getFilenames(path_input);

for ii = 1:filecount

frames{ii} = h5read([path_input filenames{ii}], '/frames');
y(:,ii) = h5read([path_input filenames{ii}], '/beats');

end


for( ii = 1:size(testSongData, 3))
%initial x h and c
x = frames{ii};
h0 = zeros(units, 1);
c0 = zeros(units, 1);


h1 = []; h2 = []; h3 = [];
c1 =[]; c2 = []; c3 = [];

%first timestep
t = 1;

%Layer 1
z1 =  W1 * x(:,t);
z1 = z1 + ( U1 * h0);
z1 = z1 + b1;

i1 = hard_sig(z1(1:units));
f1 = hard_sig(z1(units+1:2*units));
Chat1 = tanh(z1(2*units+1:3*units));
o1 = hard_sig(z1(3*units + 1:end));
%o1(t) = hard_sig(z1(3*units + 1:end) + Vo*c0);
c1(:,t) = i1 .* Chat1 + f1 .* c0;
h1(:,t) = o1 .* tanh(c1(:,t));

%Layer 2
z2 =  W2 * h1(:,t);
z2 = z2 + ( U2 * h0);
z2 = z2 + b2;

i2 = hard_sig(z2(1:units));
f2 = hard_sig(z2(units+1:2*units));
Chat2 = tanh(z2(2*units+1:3*units));
o2 = hard_sig(z2(3*units + 1:end));
%o2(t) = hard_sig(z2(3*units + 1:end) + Vo*c0);
c2(:,t) = i2 .* Chat2 + f2 .* c0;
h2(:,t) = o2 .* tanh(c2(:,t));


%Layer 3
z3 =  W3 * h2(:,t);
z3 = z3 + ( U3 * h0);
z3 = z3 + b3;

i3 = hard_sig(z3(1:units));
f3 = hard_sig(z3(units+1:2*units));
Chat3 = tanh(z3(2*units+1:3*units));
o3 = hard_sig(z3(3*units + 1:end));
%o3(t) = hard_sig(z3(3*units + 1:end) + Vo*c0);
c3(:,t) = i3 .* Chat3 + f3 .* c0;
h3(:,t) = o3 .* tanh(c3(:,t));

out(:,t, ii) = softmax(Vo * h3(:,t) + Vb);

%rest of the timesteps
    for t = 2:size(x, 2);

        %Layer 1
        z1 =  W1 * x(:,t);
        z1 = z1 + ( U1 * h1(:,t-1));
        z1 = z1 + b1;

        i1 = hard_sig(z1(1:units));
        f1 = hard_sig(z1(units+1:2*units));
        Chat1 = tanh(z1(2*units+1:3*units));
        o1 = hard_sig(z1(3*units + 1:end));
        %o1(t) = hard_sig(z1(3*units + 1:end) + Vo*c1(:,t-1));
        c1(:,t) = i1 .* Chat1 + f1 .* c1(:,t-1);
        h1(:,t) = o1 .* tanh(c1(:,t));



        %Layer 2
        z2 =  W2 * h1(:,t);
        z2 = z2 + ( U2 * h2(:,t-1));
        z2 = z2 + b2;

        i2 = hard_sig(z2(1:units));
        f2 = hard_sig(z2(units+1:2*units));
        Chat2 = tanh(z2(2*units+1:3*units));
        o2 = hard_sig(z2(3*units + 1:end));
        %o2(t) = hard_sig(z2(3*units + 1:end) + Vo*c2(:,t-1));
        c2(:,t) = i2 .* Chat2 + f2 .* c2(:,t-1);
        h2(:,t) = o2 .* tanh(c2(:,t));


        %Layer 3
        z3 =  W3 * h2(:,t);
        z3 = z3 + ( U3 * h3(:,t-1));
        z3 = z3 + b3;

        i3 = hard_sig(z3(1:units));
        f3 = hard_sig(z3(units+1:2*units));
        Chat3 = tanh(z3(2*units+1:3*units));
        o3 = hard_sig(z3(3*units + 1:end));
        %o3(t) = hard_sig(z3(3*units + 1:end) + Vo*c3(:,t-1));
        c3(:,t) = i3 .* Chat3 + f3 .* c3(:,t-1);
        h3(:,t) = o3 .* tanh(c3(:,t));

        out(:,t, ii) = softmax(Vo * h3(:,t) + Vb);

    end

end

if(plotSpecs)
    for ii = 1:size(out, 3)
    
    figure(ii)
    subplot(2, 1, 1);
    imagesc(out(:,:,ii));
    title('network prediction');
    xlim([500, 1000]);
    %figure(ii+100)
    subplot(2, 1, 2);
    imagesc(testSongData(:,:,ii));
    title('actual training output');
    xlim([500, 1000]);
    
    
    figure(ii+200)
    %imagesc(abs(out-outExp));
    hold on
    stem(out(1, :, ii))
    stem(testSongData(1, :, ii))
    title('Layer 1');
    hold off
    end

end

testVect = [[0,0,1];[0,1,0];[1,0,0]];
threshold = .85;
zeroOut = 10;

for(ii = 1:size(out,3))
    

a = xcorr2(out(1:3, :, ii), testVect);
corrs{ii} = a(3,2:end-1);
predVect(:,ii) = a(3, :) > threshold;
for(jj = 1:size(predVect, 1)-zeroOut)
    if(predVect(jj, ii) == 1)
        predVect(jj+1:jj+zeroOut, ii) = [zeros(1, zeroOut)];
        jj = jj + zeroOut;
    end
end
beatPreds = find(predVect(:, ii) == 1);
predTimes{ii} = .01*beatPreds;
beatTimes{ii} = .01*(find(testSongData(1,:,ii) == 1));
   
end

if(plotPreds)
    for ii = 1:9%1:size(predVect, 2)
    figure(ii + 1000)
    %hold on
    subplot(2, 1, 1);
    stem(predVect(:,ii))
    subplot(2, 1, 2);
    stem(testSongData(1, :, ii))
    %hold off
    end
end

set(gcf, 'menubar', 'none', 'ToolBar', 'none');

%autoArrangeFigures(3, 3,1);


for ii = 1:size(predTimes, 2)
    [mainscore(ii), backupscores{ii}] = beatEvaluator(predTimes{ii}, beatTimes{ii});
end

mainscore
