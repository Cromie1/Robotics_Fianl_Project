






function startwallfollowing(nb)
    % STARTWALLFOLLOWING Implements wall-following behavior using ultrasonic sensors
    %   Input: nb - Handle to the device interface (e.g., robot controller)
    
    % Initialize ultrasonic sensors
    nb.initUltrasonic1('D2','D3');
    nb.initUltrasonic2('D4','D5');
    
    % Calibration data
    dist = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]; % in cm
    val = [193 225, 341, 433, 600, 720, 860, 935, 1084, 1177, 1333, 1496, 1545, 1658,1794];
    
    % Calculate scale factor
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
            pause(0.1);
        end
        
        % Move forward
        nb.setMotor(1, 10);
        nb.setMotor(2, 10);
    end
    
    % Main wall-following loop
    while (true)
        leftcm = nb.ultrasonicRead2()/avgScaleFactor;
        fprintf("Last read: %0.1f cm\n", leftcm);
        
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
end