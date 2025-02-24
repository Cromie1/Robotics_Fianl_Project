%%%%%%%%%%%%%
% ECE 3610
% LAB 12 -- PID-Based Line Following
%%%%%%%%%%%%%

%%%%%%%%%%%%%
% In this lab, you will be working in teams to create a PID feedback loop
% and use it to tune a robot to smoothly follow a black line on a white
% background. Line following will be a core part of your final project, so
% it's good to get some experience with it early!
%
% Deliverables:
%   - Demonstrate that your robot accurately and smoothly follows a 
%     provided line without losing tracking.
%%%%%%%%%%%%%%

%% WIRING
% This lab has lots of wiring! Be sure to check out the wiring diagram on
% Canvas to map all of the wires where they need to go. Double check this
% before connecting the Arduino to power.

%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM47', 115200, 'serial');

%% 2. RECORD WHICH ROBOT YOU'RE USING 
% From now on (for the final project), your group will use the same robot 
% for consistency.  Record here which robot you are using for future 
% reference.

% ROBOT = '?'

%% 3.  TEST IF ROBOT GOES STRAIGHT (NO LINE FOLLOWING YET)
% First, make sure the battery pack is plugged in and is on.  If the
% battery has sufficient charge, the red lights under the sensing array
% should be on.
%
% Note that there is an emergency shutoff section at the end of the code 
% that you can use if needed.
%
% Your motors may not turn at the same rate when fed the same duty
% cycle, meaning your robot will constantly drift to one side, which can
% make tuning difficult. To combat this, find a factor mOffScale that 
% roughly makes your robot go in a straight line. Apply this value later 
% to the control signal of the stronger/weaker motor to even out the speed 
% difference.

mOffScale = '?'; % Start with 1 so both motors have same duty cycle.

% The base duty cycle "speed" you wish to travel 
% (recommended values are 9 or 10)
motorBaseSpeed = '?';

% Set the duty cycle of each motor
m1Duty = mOffScale * motorBaseSpeed;
m1Duty = motorBaseSpeed;

tic
% It can be helpful to initialize your motors to a fixed higher duty cycle
% for a very brief moment, just to overcome the gearbox force of static
% friction so that lower duty cycles don't stall out at the start.
% (recommendation: ~10, with mOffScale if needed)
nb.setMotor(1, mOffScale * 10);
nb.setMotor(2, 10);
pause(0.03);
while (toc < 3) % adjust the time to test if robot goes in straight line
                % (shorter time saves battery; or longer tests longer path)
    nb.setMotor(1, m1Duty);
    nb.setMotor(2, m2Duty);
end
% Turn off the motors
nb.setMotor(1, 0);
nb.setMotor(2, 0);

%% 4.  CALIBRATE THE SENSOR VALUES 
% The values provided by the sensor array at the front of the robot will 
% vary depending on lighting conditions even though it uses IR and each
% sensor has its own source.  For example, if the projector is on, it could
% change the performance of your line sensing.  As a result, its a good
% idea to use calibrated sensor values to account for the current 
% conditions.  In the next two sections, we will record the max and min
% values.

%% MIN REFLECTANCE VALUE CALIBRATION (white background)
% First initialize the reflectance array.
nb.initReflectance();

%Average a few values 
avgVals = zeros(10, 6);
for i = 1:10
    read = nb.reflectanceRead();
    avgVals(i, 1) = read.one;
    avgVals(i, 2) = read.two;
    avgVals(i, 3) = read.three;
    avgVals(i, 4) = read.four;
    avgVals(i, 5) = read.five;
    avgVals(i, 6) = read.six;
end
minVals = [mean(avgVals(:,1)), mean(avgVals(:,2)), mean(avgVals(:,3)), ...
    mean(avgVals(:,4)), mean(avgVals(:,5)), mean(avgVals(:,6))];

fprintf('Min Reflectance - one: %.2f, two: %.2f, three: %.2f four: %.2f five: %.2f six: %.2f\n', minVals(1), minVals(2), minVals(3), minVals(4), minVals(5), minVals(6));
%minReflectance = ['?','?','?','?','?','?']; % Set me to min reflectance 
                                             % values for each sensor for
                                             % future reference

%% MAX REFLECTANCE VALUE CALIBRATION (all sensors over black tape)
% First initialize the reflectance array.
nb.initReflectance();

%Average a few values
avgVals = zeros(10, 6);
for i = 1:10
    read = nb.reflectanceRead();
    avgVals(i, 1) = read.one;
    avgVals(i, 2) = read.two;
    avgVals(i, 3) = read.three;
    avgVals(i, 4) = read.four;
    avgVals(i, 5) = read.five;
    avgVals(i, 6) = read.six;
end
maxVals = [mean(avgVals(:,1)), mean(avgVals(:,2)), mean(avgVals(:,3)), ...
    mean(avgVals(:,4)), mean(avgVals(:,5)), mean(avgVals(:,6))];
fprintf('Max Reflectance - one: %.2f, two: %.2f, three: %.2f four: %.2f five: %.2f six: %.2f\n', maxVals(1), maxVals(2), maxVals(3), maxVals(4), maxVals(5), maxVals(6));
%maxReflectance = ['?','?','?','?','?','?']; % Set me to max reflectance 
                                             % values for each sensor for
                                             % future reference

%% 5.  LINE FOLLOWING PID LOOP
% Though PID tuning can be tedious and frustrating at times, the payoff is
% often worth it! A well-tuned PID system can be surprisingly robust.
% Good luck, and don't hesitate to ask for help if you're stuck.

% IMPORTANT NOTE: When your battery is getting low, the red LEDs on the 
% underside of the reflectance array will turn off and you won't be able 
% to read any reflectance values. If you suspect that your battery is dead, 
% grab an instructor's attention and they will swap your battery for a 
% fully charged one.

% First initialize the reflectance array.
nb.initReflectance();
% Get a reading
vals = nb.reflectanceRead();

% Set the motor offset factor (use the value you found earlier)
mOffScale = '?';

% TUNING:
% Start small (ESPECIALLY with the reflectance values, error can range 
% from zero to several thousand!).
% Tip: when tuning kd, it must be the opposite sign of kp to damp
kp = '?';
ki = '?';
kd = '?';

% Basic initialization
vals = 0;
prevError = 0;
prevTime = 0;
integral = 0;
derivative = 0;

% Determine a threshold to detect when white is detected 
% (will be used as a threshold for all sensors to know if the robot has 
% lost the line)
whiteThresh = '?'; % Max value detected for all white

% The base duty cycle "speed" you wish to travel down the line with
% (recommended values are 9 or 10)
motorBaseSpeed = '?';

tic
% It can be helpful to initialize your motors to a fixed higher duty cycle
% for a very brief moment, just to overcome the gearbox force of static
% friction so that lower duty cycles don't stall out at the start.
% (recommendation: 10, with mOffScale if needed)
nb.setMotor(1, '?');
nb.setMotor(2, '?');
pause(0.03);
while (toc < 5)  % Adjust me if you want to stop your line following 
                 % earlier, or let it run longer.

    % TIME STEP
    dt = toc - prevTime;
    prevTime = toc;

    vals = nb.reflectanceRead();
    vals = [vals.one, vals.two, vals.three, vals.four, vals.five, vals.six];

    calibratedVals = zeros(6);
    % Calibrate sensor readings
    for i = 1:6
        calibratedVals(i) = (vals(i) - minVals(i))/(maxVals(i) - minVals(i));
        % overwrite the calculated calibrated values if get a reading 
        % below or above minVals or maxVals, respectively
        if vals(i) < minVals(i)
            calibratedVals(i) = 0;
        end
        if vals(i) > maxVals(i)
            calibratedVals(i) = maxVals(i);
        end
    end

    % Designing your error term can sometimes be just as important as the
    % tuning of the feedback loop. In this case, how you define your error
    % term will control how sharp the feedback response is depending on
    % where the line is detected. This is similar to the error term we used
    % in the Sensors Line Detection Milestone. (Use the calibrated values 
    % to determine the error.)
    error = '?';

    % Calculate I and D terms
    integral = '?';

    derivative = '?';

    % Set PID
    control = '?';

    % STATE CHECKING - stops robot if all sensors read white (lost tracking):
    if (vals(1) < whiteThresh && ...
            vals(2) < whiteThresh && ...
            vals(3) < whiteThresh && ...
            vals(4) < whiteThresh && ...
            vals(5) < whiteThresh && ...
            vals(6) < whiteThresh)
        % Stop the motors and exit the while loop
        nb.setMotor(1, 0);
        nb.setMotor(2, 0);
        break;
    else
        % LINE DETECTED:
        
        % Remember, we want to travel around a fixed speed down the line,
        % and the control should make minor adjustments that allow the
        % robot to stay centered on the line as it moves.
        m1Duty = '?';
        m2Duty = '?';
       
        % If you're doing something with encoders to derive control, you
        % may want to make sure the duty cycles of the motors don't exceed
        % the maximum speed so that your counts stay accurate.

        nb.setMotor(1, m1Duty);
        nb.setMotor(2, m2Duty);
    end

    prevError = error;
end
nb.setMotor(1, 0);
nb.setMotor(2, 0);

%% EMERGENCY MOTOR SHUT OFF
% If this section doesn't turn off the motors, turn off the power switch 
% on your motor carrier board.

% Clear motors
nb.setMotor(1, 0);
nb.setMotor(2, 0);

%% X. DISCONNECT
%  Clears the workspace and command window, then
%  disconnects from the nanobot, freeing up the serial port.

clc
delete(nb);
clear('nb');
clear all