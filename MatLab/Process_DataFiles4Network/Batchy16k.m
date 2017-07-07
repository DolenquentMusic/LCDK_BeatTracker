%Latest version, doesn't need the files to be named the same.
% Takes .wav/.txt pairs from the input_path folder and processes
% them into frame data and binary beat vectors saved as .h5 files
% in the output_path folder

% 2017 David Dolengeiwcz

clear all
close all

input_path = 'Mixed_Datafiles';
output_path = 'Mixed_Processed_16k';

if ~isdir(output_path) mkdir(output_path); end

files = dir(input_path);

fileIndex = find(~[files.isdir]);

txtFileNames = {};
txtidx = 1;
wavFileNames = {};
wavidx = 1;

for ii = 1:length(fileIndex)

    fileName = files(fileIndex(ii)).name
    if strcmp(fileName(end-3:end), '.wav')
        wavFileNames{wavidx} = fileName;
        wavidx = wavidx + 1;
    elseif strcmp(fileName(end-3:end), '.txt')
        txtFileNames{txtidx} = fileName;
        txtidx = txtidx + 1;
    
    end

end

txt_count = txtidx - 1;
wav_count = wavidx - 1;

if txt_count ~= wav_count
    'uh-oh, check for matched sets of data!'
end

txtFileNames = sort(txtFileNames);
wavFileNames = sort(wavFileNames);

fileNames = {}
for ii = 1:length(txtFileNames)
    
    fname = txtFileNames{ii};
    if length(fname) > 4
        fileNames{ii} = fname(1:end-4);
    end
end



for ii = 1:length(fileNames)
    wavname = [input_path '\' fileNames{ii} '.wav'];
    textname = [input_path '\' fileNames{ii} '.txt'];
    h5name = [output_path '\song_' num2str(ii) '.h5'];
    
    [frames512, logframes512, diffs512, logdiffs512] = songDc16k(wavname, 1);
     
    [beats times] = beatvectorize(textname);
    
   frames = [logframes512; logdiffs512];
   
   frames = real(frames');
   beats = beats';
   %h5create(h5name, '/frames', size(frames), '/beats', size(beats));
   hdf5write(h5name, '/frames', single(frames), '/beats', single(beats),...
       'V71Dimensions', true);
   
   h5name
    
end
