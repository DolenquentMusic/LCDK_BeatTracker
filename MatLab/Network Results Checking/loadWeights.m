function [W1 W2 W3 U1 U2 U3 b1 b2 b3 Vo Vb] = loadWeights(path)
W1 = h5read(path, '/model_weights/lstm_1/lstm_1/kernel');
U1 = h5read(path, '/model_weights/lstm_1/lstm_1/recurrent_kernel');
b1 = h5read(path, '/model_weights/lstm_1/lstm_1/bias');

W2 = h5read(path, '/model_weights/lstm_2/lstm_2/kernel');
U2 = h5read(path, '/model_weights/lstm_2/lstm_2/recurrent_kernel');
b2 = h5read(path, '/model_weights/lstm_2/lstm_2/bias');

W3 = h5read(path, '/model_weights/lstm_3/lstm_3/kernel');
U3 = h5read(path, '/model_weights/lstm_3/lstm_3/recurrent_kernel');
b3 = h5read(path, '/model_weights/lstm_3/lstm_3/bias');

Vo = h5read(path, '/model_weights/time_distributed_1/time_distributed_1/kernel');
Vb = h5read(path, '/model_weights/time_distributed_1/time_distributed_1/bias');



end