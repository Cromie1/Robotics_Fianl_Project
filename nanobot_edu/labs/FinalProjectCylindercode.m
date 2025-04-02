

%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM7', 115200, 'serial');

%% Start cylinder following
nb.initUltrasonic1('D2','D3')
nb.initUltrasonic2('D4','D5')

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

leftcm = nb.ultrasonicRead2() / avgScaleFactor;
fprintf("Last read: %0.1f cm\n", leftcm);


frontcm = nb.ultrasonicRead1() / avgScaleFactor;
fprintf("Last read: %0.1f cm\n", frontcm);


frontcm = nb.ultrasonicRead1() / avgScaleFactor;
fprintf('Front dist = %i   Left dist = %i\n', frontcm, leftcm);

%pause(.1);
if (frontcm < 20)
    % set motors to turn right 90 degrees
    nb.setMotor(1,-10)
    nb.setMotor(2,10)
    leftcm = nb.ultrasonicRead2() / avgScaleFactor;
    %if left <= 10
    while leftcm >= 13
        leftcm = nb.ultrasonicRead2() / avgScaleFactor;
        pause(0.1);
    end

    nb.setMotor(1, 10);
    nb.setMotor(2, 10);
end


while (true)
    
    leftcm =  nb.ultrasonicRead2()/avgScaleFactor;
    fprintf("Last read: %0.1f cm\n", leftcm);
   

    % set motor 2 speed, this stays constant as it's closer to wall
    % set motor 1 speed, this will change as it will set the steering rate

    if leftcm > 8
        % set motor 1 speed to increase, this will bring it closer to the
        % wall
        nb.setMotor(2, 6);

    else
        % set motor 1 speed to decrease, this will bring it farther to the
        % wall
        nb.setMotor(1,6);
    end      

    pause(.01);
    nb.setMotor(1, 10);
    nb.setMotor(2, 9);

end
%% stop motor
nb.setMotor(1,0)
nb.setMotor(2,0)
%% 5. DISCONNECT
%  Clears the workspace and command window, then
%  disconnects from the nanobot, freeing up the serial port.

clc
delete(nb);
clear('nb');
clear all