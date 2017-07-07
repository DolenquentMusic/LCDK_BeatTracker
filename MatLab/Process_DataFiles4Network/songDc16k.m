%%% songDc16k.m
% This function generates the feature vectors of an audio file for 
% our nerual network training.
%
% filename - string of sound filename
% hanTrue - boolean to use han window or not
% frameAdvacne - double, time in seconds between frames
% each returned variable is a [24; X; 1] matrix 
%   representing [filters, time frames; filter length (512, 1024, 2048)]

%2017 David Dolengeiwcz

function [frames, logframes, diffs, logdiffs] = songDc16k(filename, filterIndex, hanTrue, frameAdvance)

    if nargin < 1 filename = 'train2.wav'; end
    if nargin < 2 filterIndex = 1; end
    if nargin < 3 hanTrue = true; end
    if nargin < 4 frameAdvance = 0.01; end

    filterSizes = [512 1024 2048];
    
    fsize = filterSizes(filterIndex);

    if fsize == 512
        load('barkFilters_16k_512.mat');
    elseif fsize == 1024
        load('barkFilters1024.mat');
    elseif fsize == 2048
        load('barkFilters2048.mat');
    end

    
    [b, Fs] = audioread(filename);
    
    a = resample(b, 16000, Fs);
    Fs = 16000;

    trackLen = max(size(a));
    
    sampleAdv = fix(frameAdvance * Fs);
    
    frontPadding = filterSizes(filterIndex) - sampleAdv;
    a = [zeros(frontPadding, 1); a];
    
    len = max(size(a));
    
    i = 0;
    
    fstart = 1:sampleAdv:(len - fsize + 1);
    
    
        frames = zeros(21, max(size(fstart)));
        logframes = zeros(21, max(size(fstart)));
        diffs = zeros(21, length(frames)-1);
        logdiffs = zeros(21, length(frames)-1);
    


        han = hann(fsize);
        han = han./sum(han);
       % T = fstart.*(1/Fs);
        i = 1;



        for frameIndex = fstart

           frame = a(frameIndex:(frameIndex + fsize - 1));

           if hanTrue
            frame = frame.*han;
           end

           frames(:, i) = filterSumFrame(frame, triFilters, false);
           logframes(:, i) = filterSumFrame(frame, triFilters, true);
           i = i + 1; 
        end

        for i = 2:length(frames)
           diffs(:, i-1) = frames(:, i) - frames(:, i-1);
           logdiffs(:, i-1) = log(diffs(:, i-1) + .000001);
        end
    

    
    diffs = [frames(:, 1) diffs];    
    logdiffs = [logframes(:, 1) logdiffs];
    
    %diffs = diffs.*(diffs > 0);
    %logdiffs = logdiffs.*(logdiffs > 0);
    
end

