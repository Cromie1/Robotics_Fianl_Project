%%%%%%%%%%%%%
% ECE 3610
% INTEL LAB 3 -- Perceptron Classification
%%%%%%%%%%%%%
% We will use a perceptron to classify between gesturing a zero or one.

%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE or port_detector.m. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!
clear; clc; close all; %initialization
nb = nanobot('COM7', 115200, 'serial'); %connect to MKR
nb.ledWrite(0);

%% Specify initial parameters:
trialCount = 20; % Specify how many times you will make each gesture.
                 % This needs to be fairly large because we will be
                 % splitting up the data into training and testing data.
                 % Must be divisible by 4 because 3/4 will be used for
                 % training and 1/4 will be used for testing.
if (mod(trialCount,4) ~= 0) % check that trialCount is divisible by 4.
    error("trialCount must be divisible by 4");
end
digits = 0:1; % Specify which digits you will be gesturing.
              % Start with 0 and 1, but you can add more after trying 
              % these!
numreads = 150; % about 2 seconds (on serial); adjust as needed, but we 
                % will be using a value of 150 for Labs 4 and 5
vals = zeros(3,numreads);

%% Collect Multiple Gestures
% For all of these intel labs, you can hold the dowel however you want.  
% However, you should try to be consistent in how you hold it from one lab 
% to the next.
gestureCount = length(digits); % determine the number of gestures
data = cell(gestureCount, trialCount+1); % preallocate cell array
for i = 1:gestureCount
    data{i,1} = digits(i);  % create a cell matrix to store the results
                            % for each trialCount of each digit
end

%display a countdown to prep user to move accelerometer 
countdown("Beginning in", 3); 

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

        nb.ledWrite(0);   %Turn off the LED to signify end of recording data      
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
if menu("Would you like to save the dataset you just recorded?", "Yes", "No") == 1
    t = clock;
    filename = sprintf("%d%d%d_%d%d%d_TrainingSet_%dGestures%dTrials", ...
        t(1),t(2),t(3),t(4),t(5),round(t(6)),height(data),width(data)-1);
    save(filename, "data");
end

%% (OPTIONAL, AS NEEDED) 
% Once you have a good set of training data for this lab, as needed you 
% can reload that data from the corresponding file here.  It will look in 
% the current directory for the file.
filename = "2025317_141138_TrainingSet_2Gestures20Trials.mat";  % add the directory before the filename 
                                 % if needed
data = importdata(filename);

%% Calculate features for each image
%determine gestureCount and trialCount based on data size
gestureCount = height(data); %number of gestures is the number of rows (height)
trialCount = width(data)-1; %number of trials is the number of columns (width)
Features = zeros(gestureCount, trialCount, 3); % 3 because the accelerometer sends 3 axes of data
for a = 1:gestureCount %iterate through all gestures
    for b = 1:trialCount %iterate through all trials
        singleLetter = data{a,b+1}; %get the individual gesture data   
        
        Features(a,b,1) = mean(singleLetter(1,:)); % YOU SHOULD MODIFY THIS LINE
        Features(a,b,2) = rms(singleLetter(2,:)); % YOU SHOULD MODIFY THIS LINE
        Features(a,b,3) = std(singleLetter(3,:)) % YOU SHOULD MODIFY THIS LINE

    end
end

%% Plot features
figure(); hold on; grid on; % create plot
for a = 1:gestureCount
    scatter3(Features(a,:,1), Features(a,:,2), Features(a,:,3), 'filled');
end
% rotate so we can see that the plot is 3-D and not 2-D
view(-60,60)

%% Store Data as at Stack for Input to Neural Network
% Features are stored as a stack in a 4D array (b/c the MATLAB function 
% requries a 4D array as input; we are only using the 1st and 4 dimensions)
% Initialize to zero.
TrainingFeatures = zeros(3,1,1,gestureCount*trialCount); 
%labels are stored as a 1D array, initialize to zero
labels = zeros(1,gestureCount*trialCount); 

k=1; %simple counter
for a = 1:gestureCount %iterate through gestures
    for b = 1:trialCount %iterate through trials
        TrainingFeatures(:,:,:,k) = Features(a,b,:); %put each feature into image stack
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
    selectionIndices = [selectionIndices,  round(linspace(1,trialCount,...
        round(trialCount/4))) + (trialCount*(b-1))];
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

%%%%%%%%%%%%%%%%%%%%% YOU SHOULD MODIFY THESE PARAMETERS %%%%%%%%%%%%%%%%%%%

learnRate = 1; %how quickly network makes changes and learns
maxEpoch = 400; %how long the network learns

%%%%%%%%%%%%%%%%%%%%%%% END OF YOUR MODIFICATIONS %%%%%%%%%%%%%%%%%%%%%%

layers= [ ... %NN architecture for a simple perceptron
    imageInputLayer([inputsize1,inputsize2,1])
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];

options = trainingOptions('sgdm','InitialLearnRate', learnRate, ...
    'MaxEpochs', maxEpoch, 'Shuffle','every-epoch','Plots', ...
    'training-progress', 'ValidationData',{xTest,yTest}); %options for NN

%% Train Neural Network

[myNeuralNetwork,info] = trainNetwork(xTrain,yTrain,layers,options); %output is the trained NN

%% Test Neural Network

t = 1:length(info.TrainingAccuracy);
figure();
subplot(2,2,1);
plot(info.TrainingAccuracy,'LineWidth',2,'Color',"#0072BD");
hold on;
plot(t(~isnan(info.ValidationAccuracy)), ...
    info.ValidationAccuracy(~isnan(info.ValidationAccuracy)),'--k', ...
    'LineWidth',2,'Marker','o');
title("Training Accuracy")
legend("Training Accuracy","Validation Accuracy");
xlabel("Iterations");
ylabel("Accuracy (%)");

subplot(2,2,3);
plot(info.TrainingLoss,'LineWidth',2,'Color',"#D95319");
hold on;
plot(t(~isnan(info.ValidationLoss)), ...
    info.ValidationLoss(~isnan(info.ValidationLoss)),'--k', ...
    'LineWidth',2,'Marker','o');
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
disp(myNeuralNetwork.Layers); % view layers
disp(myNeuralNetwork.Layers(2)); % view fully connect layer
disp(myNeuralNetwork.Layers(2).Weights); % view weights for each layer
disp(myNeuralNetwork.Layers(2).Bias); % view offset for each layer

%% Run-Time Predictions 
% (copy of lab 1 code with determiation replaced with NN code)

% make sure NN exists
if(~exist('myNeuralNetwork'))
    error("You have not yet created your neural network! Be sure you" + ...
        " run this section AFTER your neural network is created.");
end

% clear the old singleLetter and nb
clear nb singleLetter;

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

singleLetter = [vals(1,:);vals(2,:);vals(3,:)];

% put accelerometer data into NN input form
xTestLive = zeros(3,1,1,1); %allocate the size

%xTestLive(:,:,:,1) = rand(3,1); % YOU SHOULD MODIFY THIS LINE TO MATCH 
xTestLive(1,1,1,1) = mean(singleLetter(1,:)); % YOU SHOULD MODIFY THIS LINE
xTestLive(2,1,1,1) = rms(singleLetter(2,:)); % YOU SHOULD MODIFY THIS LINE
xTestLive(3,1,1,1) = std(singleLetter(3,:)) % YOU SHOULD MODIFY THIS LINE

% THE TYPE OF TRAINING DATA ABOVE

% Prediction based on NN
prediction = classify(myNeuralNetwork,xTestLive);

% Plot with label
figure(); plot(singleLetter', 'LineWidth', 1.5); %plot accelerometer traces
legend('X','Y','Z'); ylabel('Acceleration'); xlabel('Time') %label axes
title("Classification:", string(prediction)); %title plot with the label