%%
%   clickMixer takes a stereo audio vector and a vector of beat times and
%   adds a 'hihat' sound to the audio at each of the provided beat times
%   
%   INPUT ARUGMENTS
%       audioFile - mono sound file
%       beats - vector of beat times
%       mixCount - number of mixes to return, min 2
%
%   OUTPUT ARGUMENTS [clickSong, clickTrack]
%       mixedSongs - combinations of clickTracks and beats in 5% mix
%       intervals
%       clickTrack - clickTrack of beats
%%
% David Dolengewicz 2017

function [mixedSongs, impulse] = clickMixer(wavFile, beats, mixCount)
    if nargin < 3 mixCount = 11; end

    
    [audioFile, Fs] = audioread(wavFile);

    len = length(audioFile)/Fs; 
    click = load('click.mat');
    click = click.click;

    sampleOffset = 1116;
    timeOffset = sampleOffset./Fs;

    time = 0:1/Fs:len-1/Fs;
    impulse = zeros(1, length(time));
    
    trackLen = length(time);
    
    jj = 1;
    
    beats = beats - timeOffset;
    
    beats = beats( beats > 0);
    
    for ii = jj:length(beats)
        while jj < length(time) && time(jj) < (beats(ii))
            jj = jj + 1;
        end
        impulse(jj) = 1;
    end

    impulse = impulse';
    
    clickTrack = conv(impulse, click, 'same');
    %clickTrack = clickTrack(1:trackLen);
    clickTrack = clickTrack./(max(abs(clickTrack))+.001);

    trackLevels = 0:1/(mixCount-1):1;
    mixedSongs = zeros(trackLen, mixCount);
    for jj = 1:mixCount
        mixedSongs(:, jj) = trackLevels(jj)*audioFile+(1-trackLevels(jj))*clickTrack;
        mixedSongs(:,jj) = mixedSongs(:,jj)./(.0001+max(mixedSongs(:,jj)));
    end
    
    
end