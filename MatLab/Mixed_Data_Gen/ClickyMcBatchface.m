%%% ClickyMcBatchface.m
%{
Takes a folder of song data as .wav files and associated 
beat annotations in .txt files and generates mixes between
clicktracks synthesized based on the .txt files and the 
song itself.

Used for expanding our dataset

%}

%Latest version, doesn't need the files to be named the same.
% David Dolengewicz 2017

clear all
close all
Fs  = 44100;
mixCount = 21;
input_path = 'Master_Raw_Datafiles';
output_path = 'Mixed_datafiles'

if ~isdir(output_path) mkdir(output_path); end

files = dir(input_path);

fileIndex = find(~[files.isdir]);

txtFileNames = {};
txtidx = 1;
wavFileNames = {};
wavidx = 1;

for fileIdx = 1:length(fileIndex)

    fileName = files(fileIndex(fileIdx)).name;
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
for fileIdx = 1:length(txtFileNames)
    
    fname = txtFileNames{fileIdx};
    if length(fname) > 4
        fileNames{fileIdx} = fname(1:end-4);
    end
end


songNum = 1;
for fileIdx = 1:length(fileNames)
    ['processing files fileNames{fileIdx}' fileNames{fileIdx}]
    wavname = [input_path '\' fileNames{fileIdx} '.wav'];
    textname = [input_path '\' fileNames{fileIdx} '.txt'];
     
    [beats times] = beatvectorize(textname);
    [mixes, imp] = clickMixer(wavname, times, mixCount);

    
    
    %savename = [output_path filenums{ii} '.mat'];
    for ii = 1:mixCount
       saveWav = [output_path '\song_' num2str(songNum) '.wav'];
       saveText = [output_path '\song_' num2str(songNum) '.txt'];
       
       audiowrite(saveWav, mixes(:, ii), Fs);
       
       fid=fopen(saveText,'wt');
       fprintf(fid,'%f\n',times);
       fclose(fid);
       songNum = songNum + 1;
    end
    
end
