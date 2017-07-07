function y = sig(x)
    y = zeros(size(x, 1),size(x,2));
    y(find(x > 30)) = 1;
    y(find(x<-30)) = 0;
    
    idx = find(x>=-30 & x <= 30);
    y(idx) = 1./(1+exp(-x(idx)));

    %sigmf(x, [1, 0]);
end