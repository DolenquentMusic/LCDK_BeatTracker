function [filenames, filecount] = getFilenames(path)


files = dir(path);

fileIndex = find(~[files.isdir]);
filecount = length(fileIndex);
filenames = {};
idx = 1;

for ii = 1:filecount

    filenames{ii} = files(fileIndex(ii)).name;
    
end


end