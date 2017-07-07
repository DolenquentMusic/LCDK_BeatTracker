% Returns A binary vector of beat Ticks and a time vector


function [beatTics time] = beatTicker(beats, len, Fs)

if nargin < 2 len = 30; end
if nargin < 3 Fs = 44100; end

time = 0:1/Fs:len - 1/Fs;

time = time';

beatTics = zeros(len.*Fs, 1);
ticHeight = 1;


jj = 2;
for ii = 1:length(beats)
    while jj < length(time) && time(jj) < beats(ii)
        jj = jj + 1;
    end
    beatTics(jj-1) = -ticHeight;
    beatTics(jj) = ticHeight;
end


end