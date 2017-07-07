%softmax function

function y = softmax(x)

    expX = exp(x);
    expSum = sum(expX);
    
    y = expX/expSum;



end