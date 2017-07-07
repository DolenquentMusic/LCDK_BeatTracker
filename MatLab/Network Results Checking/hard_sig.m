function y = hard_sig(x)
    slope = 0.2;
    shift = 0.5;
    y = (x * slope) + shift;
    y(y<0) = 0;
    y(y>1) = 1;
    


end