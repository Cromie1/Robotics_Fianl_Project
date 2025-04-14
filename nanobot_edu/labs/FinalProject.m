
%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM7', 115200, 'wifi');

%% 2. Run program
startlinefollowingFunc(nb);
approachWallFunc(nb);
startwallfollowingFunc(nb);





%% stop motor
nb.setMotor(1,0);
nb.setMotor(2,0);