
%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM7', 115200, 'serial');

%% 2. Run program
maxReflectenceCalibrate(nb);
minReflectenceCalibrate(nb);

startwallfollowing(nb);



function startLineFollowing(nb)
    % STARTLINEFOLLOWING Implements line-following using reflectance sensors with PID control
    %   Input: nb - Handle to the device interface (e.g., robot controller)
    
    % Initialize reflectance array
    nb.initReflectance();
    
    % Motor offset factor
    mOffScale = 1.43;
    
    % PID tuning parameters
    kp = 0.005;    % Proportional gain
    ki = 0.0001;   % Integral gain
    kd = 0.0005;   % Derivative gain
    
    % Initialize variables
    prevError = 0;
    prevTime = 0;
    integral = 0;
    
    % Configuration parameters
    whiteThresh = 200;     % Threshold for detecting white
    motorBaseSpeed = 10;   % Base motor speed
    
    % Minimum and maximum sensor values (adjust based on your calibration)
    minVals = [0 0 0 0 0 0];  % Adjust these based on your sensor minimums
    maxVals = [1000 1000 1000 1000 1000 1000];  % Adjust based on your sensor maximums
    
    % Initial motor kick to overcome static friction
    nb.setMotor(1, 10);
    nb.setMotor(2, 10);
    pause(0.03);
    
    tic
    while (toc < 5)  % Runs for 5 seconds
        % Time step calculation
        dt = toc - prevTime;
        prevTime = toc;
        
        % Read reflectance sensors
        vals = nb.reflectanceRead();
        vals = [vals.one, vals.two, vals.three, vals.four, vals.five, vals.six];
        
        % Calibrate sensor readings
        calibratedVals = zeros(1,6);
        for i = 1:6
            calibratedVals(i) = (vals(i) - minVals(i))/(maxVals(i) - minVals(i));
            if vals(i) < minVals(i)
                calibratedVals(i) = 0;
            end
            if vals(i) > maxVals(i)
                calibratedVals(i) = maxVals(i);
            end
        end
        
        % Calculate error term
        error = (5*calibratedVals(1) + 2*calibratedVals(2) + 1*calibratedVals(3) - ...
                1*calibratedVals(4) - 2*calibratedVals(5) - 5*calibratedVals(6));
        
        % Calculate PID terms
        integral = integral + error * dt;
        derivative = (error - prevError) / dt;
        
        % Calculate control signal
        control = kp*error + ki*integral + kd*derivative;
        fprintf("control: %d\n", control);
        
        % Check if line is lost (all sensors detect white)
        if all(vals < whiteThresh)
            nb.setMotor(1, 0);
            nb.setMotor(2, 0);
            break;
        else
            % Calculate motor duties
            m1Duty = motorBaseSpeed + control;
            m2Duty = motorBaseSpeed - control;
            
            % Limit motor duties
            m1Duty = max(min(m1Duty, 18), 6);
            m2Duty = max(min(m2Duty, 18), 6);
            
            % Set motor speeds
            nb.setMotor(1, m1Duty);
            nb.setMotor(2, m2Duty);
        end
        
        prevError = error;
    end
    
    % Stop motors when done
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
end


function maxReflectenceCalibrate(nb)
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
maxReflectance = [679.1,750.10,561.2,593.9,700.4,654.3]; % Set me to max reflectance 
                                             % values for each sensor for
                                             % future reference
end


function minReflectenceCalibrate(nb)
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
minReflectance = [63,54.9,38.5,26.9,25.7,32.5]; % Set me to min reflectance 
                                             % values for each sensor for
                                             % future reference
end




function startwallfollowing(nb)
    % STARTWALLFOLLOWING Implements wall-following with ultrasonic sensors and reflectance-based stopping
    %   Input: nb - Handle to the device interface (e.g., robot controller)
    
    % Initialize sensors
    nb.initUltrasonic1('D2','D3');
    nb.initUltrasonic2('D4','D5');
    nb.initReflectance();  % Added reflectance sensor initialization
    
    % Ultrasonic calibration data
    dist = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]; % in cm
    val = [193 225, 341, 433, 600, 720, 860, 935, 1084, 1177, 1333, 1496, 1545, 1658,1794];
    
    % Calculate scale factor for ultrasonic sensors
    arraySize = size(dist, 2);
    scaleFactorList = zeros(1, arraySize);
    for i = 1:arraySize
        scaleFactorList(i) = val(i)/dist(i); % In [units/cm] (this is the slope)
    end
    avgScaleFactor = mean(scaleFactorList);
    fprintf("The average scale factor is %.3f units/cm\n", avgScaleFactor);
    
    % Sensor parameters
    resolution = 0.5;
    minRange = 72;
    maxRange = 1489;
    maxReflectanceThresh = 500;  % New threshold for stopping condition
    
    % Initial readings
    leftcm = nb.ultrasonicRead2() / avgScaleFactor;
    fprintf("Last read: %0.1f cm\n", leftcm);
    
    frontcm = nb.ultrasonicRead1() / avgScaleFactor;
    fprintf("Last read: %0.1f cm\n", frontcm);
    
    % Initial obstacle avoidance
    if (frontcm < 20)
        % Turn right 90 degrees
        nb.setMotor(1,-10);
        nb.setMotor(2,10);
        leftcm = nb.ultrasonicRead2() / avgScaleFactor;
        
        while leftcm >= 13
            leftcm = nb.ultrasonicRead2() / avgScaleFactor;
            pause(0.05);
        end
        
        % Move forward
        nb.setMotor(1, 10);
        nb.setMotor(2, 10);
    end
    
    % Main wall-following loop
    while (true)
        % Ultrasonic reading
        leftcm = nb.ultrasonicRead2()/avgScaleFactor;
        fprintf("Last read: %0.1f cm\n", leftcm);
        
        % Read reflectance sensors
        refVals = nb.reflectanceRead();
        refVals = [refVals.one, refVals.two, refVals.three, refVals.four, refVals.five, refVals.six];
        
        % Check stopping condition (all reflectance values > 500)
        if all(refVals > maxReflectanceThresh)
            nb.setMotor(1, 0);
            nb.setMotor(2, 0);
            fprintf("Stopping: All reflectance sensors exceeded %d\n", maxReflectanceThresh);
            break;
        end
        
        % Wall-following logic
        if leftcm > 8
            % Move closer to wall
            nb.setMotor(2, 6);
        else
            % Move away from wall
            nb.setMotor(1, 6);
        end
        
        pause(0.01);
        % Default forward motion
        nb.setMotor(1, 10);
        nb.setMotor(2, 9);
    end
    
    % Ensure motors are stopped
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
end

%%stop motor