%%%%%%%%%%%%%
% ECE 3610
% INTEL LAB 4 -- Intro to Convolutional Neural Networks & Network
% Architecture
%%%%%%%%%%%%%
% The goal of this lab is to train a convolutional neural network to 
% detect numbers gestured with an accelerometer. At a minimum you need to 
% be able to reliably distinguish between ZERO, ONE, TWO, THREE, FOUR, 
% FIVE, SIX, SEVEN, EIGHT, and NINE with at least 75% accuracy. You will 
% be responsible for modifying the neural network architecture to achieve 
% this goal.

%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE or port_detector.m. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

%clear; clc; close all; %initialization
nb = nanobot('COM7', 115200, 'serial'); 
nb.ledWrite(0);  % make sure the LED is off

%% Specify initial parameters:
trialCount = 12; % Specify how many times you will make each gesture.
                 % This needs to be fairly large because we will be
                 % splitting up the data into training and testing data.
                 % Must be divisible by 4 because 3/4 will be used for
                 % training and 1/4 will be used for testing.
if (mod(trialCount,4) ~= 0) % check that trialCount is divisible by 4.
    error("trialCount must be divisible by 4");
end
digits = [0:9]; % specify which digits you will be gesturing
numreads = 150; % about 2 seconds (on serial)
if (numreads ~= 150) % check that numreads is equal to 150
    error("numreads must be equal to 150 in this lab so we can take"+ ...
        " advatange of crowdsourcing later");
end
vals = zeros(3,numreads);

%% Collect Multiple Gestures
% For all of these intel labs, you can hold the dowel however you want.  
% However, you should try to be consistent in how you hold it from one lab 
% to the next.

gestureCount = length(digits); % determine the number of gestures
data = cell(gestureCount, trialCount+1); % preallocate cell array
for i = 1:gestureCount
    data{i,1} = digits(i);
end

countdown("Beginning in", 3); %display a countdown to prep user to move accelerometer 

for a = 1:gestureCount % iterate through all the gestures
    b = 1; %index for trials
    while b <= trialCount % iterate through all the trials
        % Displays the prompt in the command window
        fprintf("Draw a %d (%d of %d)",digits(a), b, trialCount); 
        % Turn on the LED to signify the start of recording data
        nb.ledWrite(1);                

        % Gesture is performed during the segement below
        for i = 1:numreads
            val = nb.accelRead();
            vals(1,i) = val.x;
            vals(2,i) = val.y;
            vals(3,i) = val.z;
        end

        nb.ledWrite(0);  %Turn off the LED to signify end of recording data 
        try
            % put the 3-axis (x,y,z) accel data of length numreads into 
            % the cell array at location a,b+1 (b=1 is reserved for 
            % recording which digit it is)
            data{a,b+1} = [vals(1,:);vals(2,:);vals(3,:)]; 
            b = b + 1;
        catch
            disp("Data capture failed. Trying again in 3 seconds")
            pause(3);
        end
        clc; % clear the command line
        pause(1); % wait one second
    end
end

pause(1); % wait one second
clc; % clear command line

% Save your data to a file so that you can reload it and reuse it 
% later if desired.  The file will probably be saved in the current folder.
if menu("Would you like to save the dataset you just recorded?", ...
        "Yes", "No") == 1
    % Add some parameters to the filename, so we know which is which
    t = clock;
    filename = sprintf("%d%d%d_%d%d%d_TrainingSet_%dGestures%dTrials", ...
        t(1),t(2),t(3),t(4),t(5),round(t(6)),height(data),width(data)-1);
    save(filename, "data");
end

%% (OPTIONAL, AS NEEDED) 
% Once you have a good set of training data for this lab, as needed you 
% can reload that data from the corresponding file here.  MATLAB will look 
% in the current directory for the file.
filename = "2025319_133733_TrainingSet_10Gestures12Trials.mat";  % add the directory before the filename 
                                 % if needed
data = importdata(filename);

%% Store Data as "Images" for Neural Network
%determine gestureCount and trialCount based on data size
gestureCount = height(data); %number of gestures is the number of rows (height)
trialCount = width(data)-1; %number of trials is the number of columns (width)
%features are stored as a stack of 3D images (4D array), initialize to zero
TrainingFeatures = zeros(3,150,1,gestureCount*trialCount); 
%labels are stored as a 1D array, initialize to zero
labels = zeros(1,gestureCount*trialCount); 

k=1; %simple counter
for a = 1:gestureCount %iterate through gestures
    for b = 1:trialCount %iterate through trials
        % For a CNN, the input is no longer features we define, but the 
        % data itself.  The CNN determines the features.
        TrainingFeatures(:,:,:,k) = data{a,b+1}; %put data into image stack
        labels(k) = data{a,1}; %put each label into label stack
        k = k + 1; %increment
    end
end
labels = categorical(labels); %convert labels into categorical

%% Split Training and Testing Data
%selection is an array that will hold the value of 1 when that data is 
%selected to be training data and a 0 when that data is selected to be 
%testing data
selection = ones(1,gestureCount*trialCount); %allocate logical array
                                             %initialize all to 1 at first
selectionIndices = []; %initialization
for b = 1:gestureCount %pick 1/4 of the data for testing
    selectionIndices = [selectionIndices,  ...
        round(linspace(1,trialCount,round(trialCount/4))) + ...
        (trialCount*(b-1))];
end
selection(selectionIndices) = 0; %set logical to zero to indicate testing 
                                 %data

%training data
xTrain = TrainingFeatures(:,:,:,logical(selection)); %get subset (3/4) of features to train on
yTrain = labels(logical(selection)); %get subset (3/4) of labels to train on
%testing data
xTest = TrainingFeatures(:,:,:,~logical(selection)); % get subset (1/4) of features to test on
yTest = labels(~logical(selection)); %get subset (1/4) of labels to test on

%% Define Neural Network

[inputsize1,inputsize2,~] = size(TrainingFeatures); %input size is defined by features
numClasses = length(unique(labels)); %output size (classes) is defined by number of unique labels

%%%%%%%%%%%%%%%%%%%%%% YOUR MODIFICATIONS GO HERE %%%%%%%%%%%%%%%%%%%%%%%%%%

learnRate = .01; %how quickly network makes changes and learns
maxEpoch = 100; %how long the network learns

layers= [ ... %NN architecture for a conv net
    imageInputLayer([inputsize1,inputsize2,1])
    convolution2dLayer([2,5],20) % [1,1] is the size of the convolution 
                                 % (e.g., 3x10 means across all x,y,z 
                                 % accelerometers and 10 time steps).  
                                 % Change [1,1] to be your desired size for 
                                 % the convolution.
                                 % The second value (initially 20) is the
                                 % number of filters (i.e. features) you
                                 % want the CNN to use.
    batchNormalizationLayer  % normalize the inputs to the next layer
    reluLayer % activation layer
    convolution2dLayer([1,1],20) % [1,1] is the size of the convolution 
                                 % (e.g., 3x10 means across all x,y,z 
                                 % accelerometers and 10 time steps).  
                                 % Change [1,1] to be your desired size for 
                                 % the convolution.
                                 % The second value (initially 20) is the
                                 % number of filters (i.e. features) you
                                 % want the CNN to use.
    batchNormalizationLayer % normalize the inputs to the next layer
    reluLayer  % activation layer
    fullyConnectedLayer(20)
    dropoutLayer(0.01) % Rate of dropout (e.g., 0.01 = 1%). This value is 
                       % reasonable, but feel free to change it!
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];

%%%%%%%%%%%%%%%%%%%%%%%%% END OF YOUR MODIFICATIONS %%%%%%%%%%%%%%%%%%%%%

options = trainingOptions('sgdm','InitialLearnRate', learnRate, 'MaxEpochs', maxEpoch,...
    'Shuffle','every-epoch','Plots','training-progress', 'ValidationData',{xTest,yTest}); %options for NN

%% Train Neural Network

[myNeuralNetwork, info] = trainNetwork(xTrain,yTrain,layers,options); %output is the trained NN

%% Test Neural Network

t = 1:length(info.TrainingAccuracy);
figure();
subplot(2,2,1);
plot(info.TrainingAccuracy,'LineWidth',2,'Color',"#0072BD");
hold on;
plot(t(~isnan(info.ValidationAccuracy)),info.ValidationAccuracy(~isnan(info.ValidationAccuracy)),'--k','LineWidth',2,'Marker','o');
title("Training Accuracy")
legend("Training Accuracy","Validation Accuracy");
xlabel("Iterations");
ylabel("Accuracy (%)");

subplot(2,2,3);
plot(info.TrainingLoss,'LineWidth',2,'Color',"#D95319");
hold on;
plot(t(~isnan(info.ValidationLoss)),info.ValidationLoss(~isnan(info.ValidationLoss)),'--k','LineWidth',2,'Marker','o');
title("Training Loss")
legend("Training Loss","Validation Loss");
xlabel("Iterations");
ylabel("Root Mean Square Error (RMSE)");

predictions = classify(myNeuralNetwork, xTest)'; %classify testing data using NN
disp("The Neural Network Predicted:"); disp(predictions); %display predictions
disp("Correct Answers"); disp(yTest); % display correct answers
subplot(2,2,[2,4]); confusionchart(yTest,predictions); % plot a confusion matrix
title("Confusion Matrix")

%% View Neural Network

figure(); plot(myNeuralNetwork); % visualize network connections

%% Run-Time Predictions 
% (copy of lab 1 code with determiation replaced with NN code)

% make sure NN exists
if(~exist('myNeuralNetwork'))
    error("You have not yet created your neural network! Be " + ...
        "sure you run this section AFTER your neural network is created.");
end

% clear nb
clear nb;

% ADD YOUR PORT BELOW (SAME AS AT THE BEGINNING OF THE CODE)
nb = nanobot('COM7', 115200, 'serial'); 
nb.ledWrite(0); % turn off the LED

numreads = 150; % about 2 seconds (on serial); adjust as needed, but we 
                % will be using a value of 150 for Labs 4 and 5
pause(.5);
countdown("Beginning in", 3);
disp("Make A Gesture!");
nb.ledWrite(1);  % Turn on the LED to signify the start of recording data

% Gesture is performed during the segement below
for i = 1:numreads
    val = nb.accelRead();
    vals(1,i) = val.x;
    vals(2,i) = val.y;
    vals(3,i) = val.z;
end

nb.ledWrite(0); % Turn the LED off to signify end of recording data

rtdata = [vals(1,:);vals(2,:);vals(3,:)];

% put accelerometer data into NN input form
xTestLive = zeros(3,150,1,1);
xTestLive(:,:,1,1) = rtdata;

% Prediction based on NN
prediction = classify(myNeuralNetwork,xTestLive);

% Plot with label
figure(); plot(rtdata', 'LineWidth', 1.5); %plot accelerometer traces
legend('X','Y','Z'); ylabel('Acceleration'); xlabel('Time') %label axes
title("Classification:", string(prediction)); %title plot with the label

%% Save Data for Next Lab
% Upload your data in Canvas so that we can crowdsource in the next lab.

CompID = getenv('UploadThis'); % adjust to what you want in the filename
t = clock;
filename = sprintf("data_%s_%d%d_%d%d.mat",CompID,t(2),t(3),t(4),t(5));
save(filename,'data')