%%% beatvectorize.m
% Loads beat data text files from the mirex beat tracking dataset 
% into a binary vector of a given length
% path - path of .txt file containing beat times
% len - length of audio file in seconds
% Fs - sample rate of audio file
% frameAdvance - time in seconds to advance per frame
% of beat/nobeat
%2017 David Dolengeiwcz
%%%
function [ticks, times, oneperTrue] = beatvectorize(path, len, Fs, frameAdv)

if nargin < 1 path = 'open_001.txt'; end
if nargin < 2 len = 30; end
if nargin < 3 Fs = 44100; end

if nargin < 4 frameAdv = .01; end


file = fopen(path);
times = fscanf(file, '%f');
fclose(file);

sampleAdv = frameAdv*Fs;
tolerance = frameAdv/2;

frameTimes = frameAdv:frameAdv:len;

ticks = zeros(1, length(frameTimes));


for ii = 1:length(times)
    beatframes = find(abs(frameTimes - times(ii)) <= tolerance);
    ticks(beatframes) = 1;
end

oneperTrue = sum(ticks) == length(times);

end
