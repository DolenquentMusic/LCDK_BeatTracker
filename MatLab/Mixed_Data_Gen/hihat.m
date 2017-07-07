% hihat.m
% generates a synthesized stereo hihat sound
% David Dolengewicz 2016

function a = hihat(len, Fs, Fpass)

if nargin < 3; Fpass = 1000; end
if nargin < 2;   Fs = 44100; end
if nargin < 1;   len = .06; end


Fstop = Fpass - 50;
Astop = 65;
Apass = 0.5;

d = designfilt('highpassfir','StopbandFrequency',Fstop, ...
  'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
  'PassbandRipple',Apass,'SampleRate',Fs,'DesignMethod','equiripple');
    
atkTime = .01;
decayTime = 1 - atkTime;

wn = wgn(len*Fs, 2, 1);
a = filter(d, wn);



env = [linspace(0, 1, len*Fs*atkTime), linspace(1, 0, len*Fs*decayTime)];
env = [env, zeros(1, length(a) - length(env))];

env = [env; env];
env = env';


a = a .* env;

a = a./max(max(a));



end