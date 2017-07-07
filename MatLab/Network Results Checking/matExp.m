% Exports a matrix of values to a .txt file formatted for C

% David Dolengewicz 2017

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






