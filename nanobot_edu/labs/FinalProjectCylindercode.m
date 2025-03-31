

%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM6', 115200, 'serial');

%% Start cylinder following
nb.initUltrasonic1('A2','A3')
nb.initUltrasonic2('A4','A5')

dist = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]; % in cm
% Replace the strings below with the appropriate value measured at the
% corresponding distance:
val = [193 225, 341, 433, 600, 720, 860, 935, 1084, 1177, 1333, 1496, 1545, 1658,1794 ];

arraySize = size(dist, 2); 
scaleFactorList = zeros(1, arraySize);
for i = 1:arraySize
    scaleFactorList(i) = val/dist; % In [units/cm]  (this is the slope)
end
avgScaleFactor = mean(scaleFactorList);
fprintf("The average scale factor is %.3f units/cm\n", avgScaleFactor);

resolution = .5;

minRange = 72;
maxRange = 1489;

pulseVal = nb.ultrasonicRead1();
cmVal = pulseVal / avgScaleFactor;

fprintf("Begin moving forward.")
nb.setMotor(1,12)
nb.setMotor(2,12)

while(cmVal > 15)
    pulseVal = nb.ultrasonicRead1();
    cmVal = pulseVal / avgScaleFactor;
    fprintf("%d",cmVal);
end
fprintf("Stop")
nb.setMotor(1,0)
nb.setMotor(2,0)


%% 5. DISCONNECT
%  Clears the workspace and command window, then
%  disconnects from the nanobot, freeing up the serial port.

clc
delete(nb);
clear('nb');
clear all