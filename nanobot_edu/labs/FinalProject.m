
%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM7', 115200, 'serial');

%% Testing
%startlinefollowingFunc(nb);
%approachWallFunc(nb);
startwallfollowingFunc(nb);




%% Main loop for track
%Run course
clc
clear all

gesture = gestureFunc;
% nb = nanobot('COM7', 115200, 'wifi');
nb = nanobot('COM4', 115200, 'serial');

if isequal(gesture, 0) %does wall following part first
    fprintf('path 0')
    startlinefollowingFunc(nb) %starting point
    approachWallFunc(nb) %starts at line before wall
    startwallfollowingFunc(nb) %follows wall
    turnFunc('right', nb) %turn back onto main track
    startlinefollowingFunc(nb) %goes back to line before wall
    startlinefollowingFunc(nb) %goes to middle line
    startlinefollowingFunc(nb) %goes to the right line
    turnFunc('right', nb) %turns 180
    turnFunc('right', nb) %turns 180
    startlinefollowingFunc(nb) %goes to middle
    turnFunc('left', nb) %turn onto middle path
    startlinefollowingFunc(nb) %gets to color square
    RGBFunc(nb) %determine which square to go to and get back to black line
    startlinefollowingFunc(nb) %go back to main track
    turnFunc('left', nb) %turn back to start direction

else %does color detecting path first
    fprintf('path 1')
    turnFunc('left', nb) %turn onto middle path
    startlinefollowingFunc(nb) %gets to color square
    RGBFunc(nb) %determine which square to go to and get back to black line
    startlinefollowingFunc(nb) %go back to main track
    turnFunc('left', nb) %turn back to start direction
    startlinefollowingFunc(nb) %go to line before wall
    approachWallFunc(nb) %starts at line before wall
    startwallfollowingFunc(nb) %follows wall
    turnFunc('right', nb) %turn back onto main track
    startlinefollowingFunc(nb) %goes back to line before wall
    startlinefollowingFunc(nb) %goes to middle line
    startlinefollowingFunc(nb) %goes to the right line
    turnFunc('right', nb) %turns 180
    turnFunc('right', nb) %turns 180
    startlinefollowingFunc(nb) %goes to middle


end
%% stop motor
nb.setMotor(1,0);
nb.setMotor(2,0);