
%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM7', 115200, 'wifi');

%% Testing
startlinefollowingFunc(nb);
approachWallFunc(nb);
startwallfollowingFunc(nb);




%% Main loop for track
%Run course
if gesture == 1
    startlinefollowing(nb)
    startlinefollowing(nb)
    startwallfollowing(nb)
    %turn right
    startlinefollowing(nb) %stop when sees a color
    startrgb(nb)
    startlinefollowing(nb)
    %turn right
    startlinefollowing(nb)
else
    approachWall(nb)
    startwallfollowing(nb)
    startlinefollowing(nb)
    %turn right
    startlinefollowing(nb) %stop when sees a color
    startrgb(nb)
    startlinefollowing(nb)
    %turn left
    startlinefollowing(nb)

end
%% stop motor
nb.setMotor(1,0);
nb.setMotor(2,0);