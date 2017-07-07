%%% filterSumFrame.m
%{
Returns the outputs of a frequency domain filterbank given a frame
of audio data

2017 David Dolengeiwcz
%}

function [sums framefft] = filterSumFrame(frame, filters, logTrue)

    if nargin < 3 
        logTrue = false;
    end
        
    framefft = fft(frame);
    framefft = framefft(1:length(framefft)/2+1);
    
    framefft = abs(framefft);
    
    if logTrue 
        framefft = log(framefft + 0.00001); 
    end
    
    sums = filters*framefft;

end
