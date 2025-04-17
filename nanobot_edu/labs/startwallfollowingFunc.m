function startwallfollowingFunc(nb)
    % STARTWALLFOLLOWING Implements wall-following with ultrasonic sensors and reflectance-based stopping
    %   Input: nb - Handle to the device interface (e.g., robot controller)
    
    % Initialize sensors
    nb.initUltrasonic1('D4','D5');
    nb.initUltrasonic2('D2','D3');
    nb.initReflectance();  % Added reflectance sensor initialization
    
    % Ultrasonic calibration data
    dist = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]; % in cm
    val = [193, 225, 341, 433, 600, 720, 860, 935, 1084, 1177, 1333, 1496, 1545, 1658,1794];
    
    % Calculate scale factor for ultrasonic sensors
    arraySize = size(dist, 2);
    scaleFactorList = zeros(1, arraySize);
    for i = 1:arraySize
        scaleFactorList(i) = val(i)/dist(i); % In [units/cm] (this is the slope)
    end
    avgScaleFactor = mean(scaleFactorList);
    %fprintf("The average scale factor is %.3f units/cm\n", avgScaleFactor);
    
    % Sensor parameters
    maxReflectanceThresh = 350;  % New threshold for stopping condition
    
    % Initial readings
    leftcm = nb.ultrasonicRead2() / avgScaleFactor;
    %fprintf("Last read: %0.1f cm\n", leftcm);
    
    frontcm = nb.ultrasonicRead1() / avgScaleFactor;
    %fprintf("Last read: %0.1f cm\n", frontcm);
    
    %turn right
    nb.setMotor(1, -11 - 1)
    nb.setMotor(2, 11)

    pause(.6)

    nb.setMotor(1, 0)
    nb.setMotor(2, 0)
    pause(.5)

    % % Initial obstacle avoidance
    % if (0 < frontcm && frontcm < 20)
    %     leftcm = nb.ultrasonicRead2() / avgScaleFactor;
    % 
    %     while (leftcm >= 15 || leftcm == 0)
    %         leftcm = nb.ultrasonicRead2() / avgScaleFactor;
    %         pause(0.05);
    %     end
    % 
    %     % Move forward
    %     nb.setMotor(1, 10);
    %     nb.setMotor(2, 10);
    % end
    
    % Main wall-following loop
    while (true)
        % Ultrasonic reading
        leftcm = nb.ultrasonicRead2()/avgScaleFactor;
        %fprintf("Last read: %0.1f cm\n", leftcm);
        
        % Read reflectance sensors
        refVals = nb.reflectanceRead();
        refVals = [refVals.one, refVals.two, refVals.three, refVals.four, refVals.five, refVals.six];
        
        % Check stopping condition (all reflectance values > 500)
        if all(refVals > maxReflectanceThresh)
            nb.setMotor(1, 0);
            nb.setMotor(2, 0);
            %fprintf("Stopping: All reflectance sensors exceeded %d\n", maxReflectanceThresh);
            return;
        end
        
        % Wall-following logic
        if (leftcm > 6 || isequal(leftcm, 0))
            % Move closer to wall
            nb.setMotor(2, 6);
            nb.setMotor(1, 11 + 2);
            
        elseif (leftcm > 30)
            nb.setMotor(2, 0)
            nb.setMotor(1, 0)

        else
            % Move away from wall
            nb.setMotor(1, 6 + 2);
            nb.setMotor(2, 6);
            
        end
        
        pause(0.05);
        nb.setMotor(1, 11 + 2)
        nb.setMotor(2, 11)
    end
    
    % Ensure motors are stopped
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
end