%generates a frequency domain bark scale triangular filter bank of length 512
%for audio data sampled at 16k.

% David Dolengewicz 2017

load('Bark.mat');

Fs = 16000;
lengths = [512];


centers = Bark(1:21);
bandwidths = BarkBandwidths(1:21);

fnum = max(size(centers));

for length = lengths
    triFilters = zeros(fnum, length/2+1);
    for (i = 1:fnum)
        [f, Fv] = triangleFilter(centers(i), bandwidths(i), length, Fs);
        triFilters(i, :) = f;
    end
    filename = char(['barkFilters_16k_' num2str(length) '.mat']);
    save(filename, 'triFilters');
    
end

figure
hold on;

for i = 1:fnum
    %figure(i)
    stem(Fv, triFilters(i, :));
    xlabel('Frequency in Hz');
    title('Bark Scale Triangular Filter Bank');
end
hold off;