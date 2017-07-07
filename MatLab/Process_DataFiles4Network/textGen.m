%take a folder full of training data .h5 files with variables
%/frames and /beats, not that this matters,
% and generates text files of training, validation and test datasets
% updated on 5-22-17 to sort outputs

% 2017 David Dolengeiwcz

train = .7; valid = .15; test = 1-(train+valid);

input_path = 'Mixed_Processed_16k';
output_path = 'Texts';
saveName = 'mix16k';

% path of datafiles during network training
savepath = 'Mixed_Processed_16k/';
% for generating multiple sets of .txt files
number_of_sets = 1;

if ~isdir(output_path) mkdir(output_path); end

files = dir(input_path);

fileIndex = find(~[files.isdir]);

h5fileNames = {};
h5idx = 1;

for ii = 1:length(fileIndex)

    fileName = files(fileIndex(ii)).name
    if strcmp(fileName(end-2:end), '.h5')
        h5fileNames{h5idx} = fileName;
        h5idx = h5idx + 1;
    end

end

data_count = h5idx - 1;

train_count = round(train*data_count);
valid_count = round(valid*data_count);
test_count = data_count - (train_count + valid_count);

for text_count = 1:number_of_sets
    train_savename = [output_path '/train_' saveName '_' num2str(text_count) '.txt'];
    valid_savename = [output_path '/valid_' saveName '_' num2str(text_count) '.txt'];
    test_savename = [output_path '/test_' saveName '_' num2str(text_count) '.txt'];
    
    randidx = randperm(data_count-test_count);
    
    train_idx = randidx(1:train_count);
    valid_idx = randidx(train_count+1:train_count+valid_count);
    test_idx = (data_count - test_count + 1):data_count
    
    train_idx = sort(train_idx);
    valid_idx = sort(valid_idx);
    test_idx = sort(test_idx);

    fileID = fopen(train_savename, 'wt');
    for idx = train_idx
        fprintf(fileID, '%s\n',[savepath h5fileNames{idx}]);
    end
    fclose(fileID);
    

    fileID = fopen(valid_savename, 'wt');
    for idx = valid_idx
        fprintf(fileID, '%s\n',[savepath h5fileNames{idx}]);
    end
    fclose(fileID);

    fileID = fopen(test_savename, 'wt');
    for idx = test_idx
        fprintf(fileID, '%s\n',[savepath h5fileNames{idx}]);
    end
    fclose(fileID);
    
    
end