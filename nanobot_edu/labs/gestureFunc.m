
function gesture(nb)

filename = "202549_14823_TrainingSet_2Gestures10Trials.mat";                            
data = importdata(filename);
digits = [data{:,1}];
gestureCount = height(data); %number of gestures is the number of rows (height)
trialCount = width(data)-1; %number of trials is the number of columns (width)
% Create the matrix that will store the features of the data
Features = zeros(gestureCount, trialCount, 3);
for a = 1:gestureCount %iterate through all gestures
    for b = 1:trialCount %iterate through all trials
        singleLetter = data{a,b+1}; % get the individual gesture data for 
                                    % each gesture of each trial

        Features(a,b,1) = mean(singleLetter(1,:)); % Delete rand(1,1) and replace it with 
                                     % your feature for the x-axis data
        Features(a,b,2) = rms(singleLetter(2,:)); % feature for the y-axis data
        Features(a,b,3) = std(singleLetter(3,:)); % feature for the z-axis data

    end
end
%reshape data so that it's #observations by #features
TrainingFeatures = reshape(Features,[trialCount*gestureCount,3]); 
%assign appropriate label to each observation (i.e., 0 or 1)
TrainingLabels = repmat(digits, [1, trialCount]); 
%perform LDA
LDA = fitcdiscr(TrainingFeatures,TrainingLabels); 
% make sure NN exists
if(~exist('LDA'))
    error("You have not yet performed a LDA! Be sure you run this" + ...
        " section AFTER you have performed the LDA.");
end

% clear the old singleLetter and nb
clear nb singleLetter

% ADD YOUR PORT BELOW (SAME AS AT THE BEGINNING OF THE CODE)
nb = nanobot('COM4', 115200, 'serial'); %connect
nb.ledWrite(0); % Turn on the LED to signify the start of recording data
numreads = 150; % about 2 seconds (on serial); adjust as needed, but we 
                % will be using a value of 150 for Labs 4 and 5
pause(.5);
countdown("Beginning in", 3);
disp("Make A Gesture!");


% Gesture is performed during the segement below
for i = 1:numreads
    val = nb.accelRead();
    vals(1,i) = val.x;
    vals(2,i) = val.y;
    vals(3,i) = val.z;
end

singleLetter = [vals(1,:);vals(2,:);vals(3,:)];

% put accelerometer data into LDA input form
LDAinput = zeros(1,3);

LDAinput(1,1) = mean(singleLetter(1,:)); % REPLACE THE RIGHT SIDE OF THESE EQUATIONS WITH
LDAinput(1,2) = rms(singleLetter(2,:)); % WHAT YOU ENDED UP USING ABOVE FOR THE
LDAinput(1,3) = std(singleLetter(3,:)); % TRAINING (SO THAT THE TRAINING AND TESTING USE
                           % THE SAME APPROACH).
                           
% Prediction based on NN
LDAprediction = predict(LDA,LDAinput);

clc
delete(nb);
clear('nb');
gesture = LDAprediction -1;
if gesture == -1
    gesture = 1;
end
end