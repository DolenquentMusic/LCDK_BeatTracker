function [f, Fv] = triangleFilter(center, bandwidth, length, Fs)

if nargin < 3 length = 1024; end
if nargin < 4 Fs = 44100; end

Ts = 1/Fs;                                % Sampling Interval (sec)
Fn = Fs/2;                                % Nyquist Frequency (Hz)                                    % Signal Length (samples)
lowf = center - .5*bandwidth;             % Low frequency
highf = center + .5*bandwidth;            % High frequency

flen = fix(length/2)+1;                   % length of Frequency Vector
Fv = linspace(0, 1, flen)*Fn;             %frequency vector

%write formula for triange of given bandwidth and center.
m = 1/fix(.5*bandwidth);

f = zeros(1, flen);

for(i = 1:flen)
   if Fv(i) >= lowf && Fv(i) < center
       f(i) = (Fv(i)-lowf)*m;
   elseif Fv(i) >= center && Fv(i) < highf
       f(i) = 1 - (Fv(i)-center)*m;
   end
end

f = f./(sum(f));

end

