%%% matExp.m
%{
Generates a text file of path filename using the values of x.
The text file is formatted to be copied into a C readable file
for variable initialization. 

We used this function to load our weight matrices, filter coefficients
and test data

2017 David Dolengeiwcz

%}
%%%
function matExp(x, filename)
    
    if nargin < 2 filename = 'test.txt'; end
    
    
    fileID = fopen(filename, 'wt');
    fprintf(fileID, '{');
    for row = 1:size(x,1)
        fprintf(fileID, '{');
        for col = 1:size(x,2)
           fprintf(fileID, '%.6f', x(row, col));
           if col < size(x,2)
               fprintf(fileID, ', ');
           end
        end
        fprintf(fileID, '}');
        if row < size(x, 1)
            fprintf(fileID, ',');
        end
       
    end
    fprintf(fileID, '}');
    fclose(fileID);


end






