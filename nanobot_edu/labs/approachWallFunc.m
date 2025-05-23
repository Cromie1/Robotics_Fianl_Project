function approachWallFunc(nb)

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
    fprintf("The average scale factor is %.3f units/cm\n", avgScaleFactor); 
    frontcm = nb.ultrasonicRead1() / avgScaleFactor;
    fprintf("Last read: %0.1f cm\n", frontcm);
   


nb.initReflectance();
    % Globals
min_reflectance = [142,106,94,82,94,142];
kp = 0.001;
kd = 0.0007;
prev_error = 0;
prev_time = 0;
run_time = 40;
integral = 0;
max_speed = 13;
motor_speed_offset = 0.1 * max_speed;
all_white_threshold = 300;

tic
% To help overcome static friction
nb.setMotor(1, motor_speed_offset);
nb.setMotor(2, motor_speed_offset);
pause(0.03);

counter = 0;
% In cycles
back_up_time = 3000;

% Loop
while (toc < run_time)
    frontcm = nb.ultrasonicRead1() / avgScaleFactor;
    if (0 < frontcm && frontcm < 8)
        nb.setMotor(1,0);
        nb.setMotor(2,0);
        fprintf('approached Wall \n')

        return
    end
    % TIME STEP
    current_time = toc;
    dt = current_time - prev_time;
    prev_time = current_time;

    if counter ~= 0
        if counter == back_up_time
            counter = 0;
        else
            counter = counter + 1;
        end
    else

    

    % Read sensor values
    valss = nb.reflectanceRead();
    
    vals = [valss.one, valss.two, valss.three, valss.four, valss.five, valss.six];
    calibratedVals = zeros(1,6);
    
    % Calibrate sensor readings, min is 0
    for i = 1:6
        calibratedVals(i) = max(vals(i) - min_reflectance(i), 0);
    end 
   
    % Calculate error, will range from -2500 to 2500
    weighted_sum = dot(calibratedVals, [0, 1000, 2000, 3000, 4000, 5000]);
    error = weighted_sum / sum(calibratedVals) - 2500;

    % Print values of sensors after adjusting
    %fprintf('one: %.2f, two: %.2f, three: %.2f four: %.2f five: %.2f six: %.2f\n',calibratedVals.one, calibratedVals.two, calibratedVals.three, calibratedVals.four, calibratedVals.five, calibratedVals.six);
    %fprintf('error: %.2f\n', error);
    
    % if(all(vals>=all_black_threshold))
    % nb.setMotor(1,0);
    % nb.setMotor(2,0);
    % fprintf('Black Line\n')
    % return
    % end
    % Calculate position error
    if sum(calibratedVals) <= all_white_threshold
        fprintf('All sensors on white\n');
        if error <= 0 
            nb.setMotor(2, -11);
            
        else
            nb.setMotor(1, -11);
        end

        counter = 1;
        continue;
        
    end
    
    % Calculate PID stuff
    integral = integral + error * dt;
    derivative = (error - prev_error) / dt;
    control = kp * error + kd * derivative;
    %fprintf('control: %.2f\n', control);

    motor1_current_speed = max(min(max_speed - control, max_speed), 0);
    motor2_current_speed = max(min(max_speed + control, max_speed), 0);

    nb.setMotor(2, motor2_current_speed - 2);
    nb.setMotor(1, motor1_current_speed);

    prev_error = error;
    end

end
nb.setMotor(1, 0);
nb.setMotor(2, 0);
end