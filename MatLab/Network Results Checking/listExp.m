

function listExp(x, filename)
    
    if nargin < 2 filename = 'test.txt'; end
    
    
    
    fileID = fopen(filename, 'wt');
    
        fprintf(fileID, '{');
        for col = 1:length(x)
           fprintf(fileID, '%.6f', x(col));
           if col < length(x)
               fprintf(fileID, ', ');
           end
        end
        fprintf(fileID, '}');
       
   
    fclose(fileID);


end






