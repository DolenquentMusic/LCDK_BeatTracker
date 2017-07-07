from __future__ import print_function


import warnings

import os,sys,getopt
import yaml
import cPickle

import numpy as np
np.random.seed(314159)  # for reproducibility

import h5py

import keras.callbacks
from keras.models import Sequential
from keras.layers import Dense, Activation,LSTM,TimeDistributed,Masking
from keras.layers import SimpleRNN
from keras.initializers import normal, identity
from keras.optimizers import RMSprop
from keras.utils import np_utils
from keras import losses

#from custom_layers import uRNN,complex_RNN_wrapper
#from custom_optimizers import RMSprop_and_natGrad



class LossHistory(keras.callbacks.Callback):
    def __init__(self, histfile):
        self.histfile=histfile
    
    def on_train_begin(self, logs={}):
        self.train_loss = []
        #self.train_acc  = []
        self.val_loss   = []
        #self.val_acc    = []

    def on_batch_end(self, batch, logs={}):
        self.train_loss.append(logs.get('loss'))
        #self.train_acc.append(logs.get('acc'))

    def on_epoch_end(self, epoch, logs={}):
        self.val_loss.append(logs.get('val_loss'))
        #self.val_acc.append(logs.get('val_acc'))
        cPickle.dump({
            'train_loss' : self.train_loss, 
            #'train_acc' : self.train_acc, 
            'val_loss': self.val_loss, 
            #'val_acc' : self.val_acc
            }, open(self.histfile, 'wb')) 


def build_model(maxseq, ninput, config):
    print("Building model with implementation LSTM")
    
    hidden_units = config['hidden_units']
    noutput = config['noutput']
    #model
    model = Sequential()
    model.add(Masking(mask_value=config['mask_value'],input_shape=(maxseq,ninput)))
    model.add(LSTM(hidden_units,
                    return_sequences=True,
                    input_shape=(maxseq,ninput)))
    	
    #stacked layers               
    model.add(LSTM(hidden_units,
                    return_sequences=True))
    model.add(LSTM(hidden_units,
                    return_sequences=True))
    				   
    model.add(TimeDistributed(Dense(noutput)))
     
     
    #output layer    
    model.add(TimeDistributed(Activation('softmax')))		
    
    model.compile(loss=losses.categorical_crossentropy,
              optimizer='Adam',
              sample_weight_mode="temporal",
              metrics=['accuracy'])
			  
    return model
    
			
def load_from_h5(h5_file):
    print(h5_file)
    h5File = h5py.File(h5_file,'r')
    X = np.asarray(h5File['/frames']).astype(np.float32)
    #X = X.reshape(10, 300, 144)
    Y = np.asarray(h5File['/beats']).astype(np.float32)
    #Y = Y.reshape(10, 300, 1)
    return (X,Y)

def load_from_txt(txt_file,load_function=load_from_h5):
    data=[]
    with open(txt_file) as f:
        for line in f:
            data.append(load_function(line.rstrip()))
    return data


def data_to_XY(data,config):
    nexamples=len(data)
    newdata = []
    
    for XYpair in data:
        Xcur = XYpair[0]
        Ycur = XYpair[1]
        for ii in range(10):
            newX = Xcur[ii*10:ii*10+299]
            
            newY = Ycur[ii*10:ii*10+299]
            newdata.append((newX, newY))

    #data = newdata
    
    nexamples = len(data)
    
    # find length of longest sequence
    maxlen=0
    for XYpair in data:
        if XYpair[0].shape[0]>maxlen:
            maxlen=XYpair[0].shape[0]
            
            
    print("size 0 of X %d" % data[0][0].shape[0])
    print("size 1 of X %d" % data[0][0].shape[1])

    print("size 0 of Y %d" % data[0][1].shape[0])
    #print("size 1 of Y %d" % data[0][1].shape[1])
	
    ninput=data[0][0].shape[1]  #X is shape (ninput,time_steps)
    noutput=1 #Y is shape (noutput,time_steps)
    #allocate X and 
    print("examples %d " % nexamples)
    print("maxlen %d " % maxlen)
    print("ninput %d " % ninput)
    print("noutput %d " % noutput)
    X = ( config['mask_value']*np.ones((nexamples,maxlen,ninput)) ).astype(np.float32)
    Y = ( np.zeros((nexamples,maxlen)) ).astype(np.float32)
    mask = ( np.zeros((nexamples,maxlen)) ).astype(np.float32)
    for i,XYpair in enumerate(data):
        Xcur = XYpair[0]
        Ycur = XYpair[1]
        print(Xcur.shape[0])
        print(Xcur.shape[1])
        print(Ycur.shape[0])
        
        #print(Ycur.shape[1])
        X[i,:Xcur.shape[0],:]=Xcur
        Y[i,:Ycur.shape[0]]=Ycur
        mask[i,:Ycur.shape[0]]=1.
    return X,Y,mask
	

def pad_axis_toN_with_constant(x,axis,N,constant):
    # build the spec and consts tuples, with elements (0,0)
    # except at index 'axis'
    spec=[]
    consts=[]
    ndim=len(x.shape)
    for i in range(ndim):
        if (i==axis):
            spec.append((0,N-x.shape[axis]))
            consts.append((0,constant))
        else:
            spec.append((0,0))
            consts.append((0,0))
    spec=tuple(spec)
    consts=tuple(consts)
    #necessary to avoid "'tuple' object has no attribute 'tolist'" error
    # https://github.com/numpy/numpy/issues/7353
    consts=np.array(consts)
    # do the padding the return the result
    return np.pad( x,spec,mode='constant',constant_values=consts)
	
def countdown_vectorize(Y_vect, noutput):
# Y_vect has dims (#examples, Timesteps, 1)
    maxCount = noutput - 1
    bounceMax = 10
    new_Y = []
    Y_shapeSize = len(Y_vect.shape)
    if Y_shapeSize == 3:
        Y_vect = np.squeeze(Y_vect, axis=(2,))
    for exIdx in range(Y_vect.shape[0]):
        thisEx = Y_vect[exIdx, :]
        
        #thisEx = thisEx - Y_vect[exIdx, :]
        #print(thisEx)	
        cdsum = maxCount
        ii = thisEx.shape[0] - 1       
        isBounce = 0
        #print("i starts at:", thisEx.shape[0]-1)
        for ii in range(thisEx.shape[0]-1, -1, -1):
            
            if(isBounce):
                thisEx[ii] = cdsum
                if(cdsum < bounceMax):
                    cdsum += 1
                else:
                    cdsum = maxCount
                    isBounce = 0					
            elif(thisEx[ii] == 1):
                cdsum = 1
                if(ii+bounceMax+1 < thisEx.shape[0]):
                    thisEx[ii:ii+bounceMax+1] = range(bounceMax+1)
                else:
                    bmTemp = thisEx.shape[0] - ii 
                    thisEx[ii:] = range(bmTemp)
                    isBounce = 1				
            else:
                thisEx[ii] = cdsum
                if(cdsum < maxCount):
                    cdsum += 1          
				
        new_Y.append(thisEx.astype(np.int32))
	
    if Y_shapeSize == 3:
        new_Y = np.expand_dims(new_Y, axis=2)
    
	
	return np.asarray(new_Y)


	
def one_hot(Y_vect, noutput):    
    new_Y = np.zeros((Y_vect.shape[0], Y_vect.shape[1], noutput))
    for exIdx in range(Y_vect.shape[0]):
        thisEx = Y_vect[exIdx, :]
        
        #print(thisEx)	
        cdsum = 0        

        #print("i starts at:", thisEx.shape[0]-1)
        for ii in range(thisEx.shape[0]):
            new_Y[exIdx, ii, thisEx[ii]] = 1
	
    return np.asarray(new_Y)
	
	
	
def main(argv):
    warnings.filterwarnings("error")
    config={'command' : 'train',
            'learning_rate' : 1e-5,
            'learning_rate_natGrad' : None,
            'loss' : 'categorical_crossentropy',
            'clipnorm' : 1.0,
            'mask_value' : -1.0,
            'batch_size' : 32,
            'nb_epochs' : 200,
            'patience' : 20,
            'hidden_units' : 20,
            'model_impl' : 'LSTM',
            'nb_batch_predict' : 200,
            'unitary_impl' : 'ASB2016',
            'unitary_init' : 'ASB2016',
            'histfile' : 'exp/bt3_history_mixed16k_20',
            'savefile' : 'exp/bt3_model_mixed16k_20.hdf5',
            'weightsfile' : 'exp/bt3_weights_mixed16k_20.h5',
            'savefile_init' : None,
            'path_txt_train' : 'train_mix16k_1.txt',
            'path_txt_valid' : 'valid_mix16k_1.txt',
            'path_txt_test' : 'test_mix16k_1.txt',
            'path_predictions' : 'test/bt3_predictions_mixed16k_20.h5',
            'noutput' : 26}
    
    
    print("Printing Configuration:")
    for key, value in config.iteritems():
        print(" ", key, ": ", value)
    
    
    #learning rate setup	
    learning_rate = config['learning_rate']
    if ('learning_rate_natGrad' in config) and (config['learning_rate_natGrad'] is not None):
        learning_rate_natGrad = config['learning_rate_natGrad']
    else:
        learning_rate_natGrad = learning_rate
    
	
    #load config variables	
    clipnorm = config['clipnorm']
    batch_size = config['batch_size']
    nb_epochs = config['nb_epochs']
    hidden_units = config['hidden_units']
    model_impl = config['model_impl']
    		
    histfile = config['histfile']
    savefile = config['savefile']
    weightsfile = config['weightsfile']
	
	
    #load data from text files
    data_train = load_from_txt(config['path_txt_train'])
    data_valid = load_from_txt(config['path_txt_valid'])    
    data_test = load_from_txt(config['path_txt_test'])
    X_train, Y_train, mask_train = data_to_XY(data_train, config)
    X_valid,Y_valid,mask_valid=data_to_XY(data_valid,config)
    X_test,Y_test,mask_test=data_to_XY(data_test,config)
    
	  #Ensure all tensors are 3-dimensional
    if len(Y_train.shape)==2:
        Y_train=np.expand_dims(Y_train,axis=2)
        Y_valid=np.expand_dims(Y_valid,axis=2)
        Y_test=np.expand_dims(Y_test, axis=2)
        
    #Pad all tensors with mask_value to a length divisable by 300
    maxseq = max(X_train.shape[1], X_valid.shape[1])
    if(maxseq % 300 != 0):
        maxseq = 300 * (int(maxseq / 300)+1)
    X_train=pad_axis_toN_with_constant(X_train,1,maxseq,config['mask_value'])
    Y_train=pad_axis_toN_with_constant(Y_train,1,maxseq,config['mask_value'])
    
    X_valid=pad_axis_toN_with_constant(X_valid,1,maxseq,config['mask_value'])
    Y_valid=pad_axis_toN_with_constant(Y_valid,1,maxseq,config['mask_value'])
    
    X_test=pad_axis_toN_with_constant(X_test,1,X_test.shape[1],config['mask_value'])
    Y_test=pad_axis_toN_with_constant(Y_test,1,Y_test.shape[1],config['mask_value'])
   
	
		
    print('X_train shape:', X_train.shape)
    print('X_valid shape:', X_valid.shape)
     
    ntrain=X_train.shape[0]
    maxseq=X_train.shape[1]
    ninput=X_train.shape[-1]
    nvalid=X_valid.shape[0]
    
	
    noutput = config['noutput']
    Y_train = countdown_vectorize(Y_train, noutput)
    Y_valid = countdown_vectorize(Y_valid, noutput)
    Y_test = countdown_vectorize(Y_test, noutput)
    	
	
    print("Before one_hot")
    print("Ytrain shape", Y_train.shape)
    print("Yvalid shape", Y_valid.shape)
    print("Ytest shape", Y_test.shape)
   
    # convert to one_hot	
    Y_train = one_hot(Y_train, noutput)
    Y_valid = one_hot(Y_valid, noutput)
    Y_test = one_hot(Y_test, noutput)
	
    print("After one_hot")
    print("Ytrain shape", Y_train.shape)
    print("Yvalid shape", Y_valid.shape)
    print("Ytest shape", Y_test.shape)	
	
	
	  #Reshape training and valid data into 3 second chunks
    X_train = X_train.reshape(ntrain*maxseq/300, 300, ninput)
    Y_train =  Y_train.reshape(ntrain*maxseq/300, 300, noutput)
    
    X_valid = X_valid.reshape(nvalid*maxseq/300, 300, ninput)
    Y_valid =  Y_valid.reshape(nvalid*maxseq/300, 300, noutput)

    #mask_train = mask_train.reshape(ntrain*maxseq/300, 300, noutput)
    #mask_valid = mask_valid.reshape(nvalid*maxseq/300, 300, noutput)
     
    ntrain = ntrain * 10
    nvalid = nvalid * 10
    maxseq = 300
    
    """
    mask_train=pad_axis_toN_with_constant(mask_train,1,maxseq,0.)
    mask_valid=pad_axis_toN_with_constant(mask_valid,1,maxseq,0.)
    mask_test=pad_axis_toN_with_constant(mask_test,1,X_test.shape[1],0.)
    #mask_train = mask_train.reshape(ntrain*maxseq/300, 300, noutput)
    #mask_valid = mask_valid.reshape(nvalid*maxseq/300, 300, noutput)
    """

    
    print('X_train shape:', X_train.shape)
    print('X_valid shape:', X_valid.shape)
    
    print('Y_train shape:', Y_train.shape)
    print('Y_valid shape:', Y_valid.shape)
    

    ntrain=X_train.shape[0]
    maxseq=X_train.shape[1]
    ninput=X_train.shape[-1]
    nvalid=X_valid.shape[0]
    
    mask_train = np.ones((ntrain*maxseq/300, 300))
    mask_valid = np.ones((nvalid*maxseq/300, 300))
    
    
    #make sure the experiment directory to hold results exists
    if not os.path.exists('exp'):
        os.makedirs('exp')
    	
 
    # build model 
    model = build_model(maxseq, ninput, config)
    
    #add callbacks
    history=LossHistory(histfile)
    checkpointer = keras.callbacks.ModelCheckpoint(filepath=savefile, 
                                            verbose=1, 
                                            save_best_only=True)
    checkpointer2 = keras.callbacks.ModelCheckpoint(filepath=weightsfile, 
                                            verbose=1, 
                                            save_best_only=True)
    
	
    earlystopping=keras.callbacks.EarlyStopping(monitor='val_loss',
                                            patience=config['patience'], verbose=1, 
                                            mode='auto') 
    	
    model.fit(X_train, Y_train,
              callbacks=[history, checkpointer, earlystopping],
              batch_size=batch_size,
              epochs= nb_epochs,
              verbose=1,
              validation_data=(X_valid, Y_valid, mask_valid),
              sample_weight=mask_train)

    
    #test the model
	
	
    model.summary()
    model_weights = model.get_weights()
    #print("Model shape: ", model_weights.shape)
    print("Saving model to %s" % config['weightsfile'])
    f = h5py.File(config['weightsfile'], 'w')
    for i in range(len(model_weights)):
        layerName = 'layer' + str(i+1)
        f[layerName] = model_weights[i]
    
    
    f.close() 	
    	
	
    print('X_test shape:', X_test.shape)
    
	
    train_loss = model.evaluate(X_train, Y_train, 
                        sample_weight=mask_train,
                        verbose=0)
    valid_loss = model.evaluate(X_valid, Y_valid, 
                        sample_weight=mask_valid,
                        verbose=0)
    
    print('Train loss:', train_loss)
    print('Valid loss:', valid_loss)

    model = build_model(X_test.shape[1], ninput, config)
    model.set_weights(model_weights)
    test_loss = model.evaluate(X_test, Y_test, 
                        sample_weight=mask_test,
                        verbose=0)
	
    print('Test loss:', test_loss)
    

    # add test scores to history
    history_load=cPickle.load(open(histfile,'rb'))
    history_load.update({'test_loss' : test_loss})
    cPickle.dump(history_load, open(histfile, 'wb'))  

    print("Predicting...")
    est = model.predict_on_batch(X_test)
    print("est shape", est.shape)
    print("Prediction done!")
    print("Saving predictions to %s" % config['path_predictions'])
    f = h5py.File(config['path_predictions'], 'w')
    f['res'] = est
    f['data'] = Y_test
    f['frames'] = X_test
    f.close() 	
    		
if __name__ == "__main__":
    main(sys.argv[1:])		
    		