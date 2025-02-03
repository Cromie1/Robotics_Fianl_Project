%%%%%%%%%%%%%
% ECE 3610
% LAB 5 -- Inertial Measurement Lab
%%%%%%%%%%%%%

%%%%%%%%%%%%%
% Tilt detection using an IMU (inertial measurement unit) is critical to a 
% huge number of products - the Wii-mote, quadrotors, and commercial 
% aircraft, to name a few. The three-axis MEMS accelerometer is a critical 
% component of the IMU. In this lab, we will show how the measurements 
% from your IMU can be used to calculate and visualize tilt angle in real 
% time.
% 
% Deliverables:
% - Show a 3D block which successfully tracks your breadboard tilt in an
% intuitive way
% - Demonstrate the 3D tilt matching game
%
% Extensions:
% - Change the color of the 3d block being displayed every time you press a
% pushbutton.
% - Change the color of the 3d block being displayed every time you tap 
% the accelerometer.

%%%%%%%%%%%%%%

%% 1. CONNECT TO YOUR NANOBOT
%  Remember to replace the first input argument with text corresponding to
%  the correct serial port you found through the Arduino IDE. Note that the
%  clc and clear all will clear your command window and all saved
%  variables!

clc
clear all
nb = nanobot('COM6', 115200, 'serial');

%% 2. Testing the onboard IMU
% Your Arduino board has a built-in accelerometer that allows tilt
% orientation to be determined. Turn on and connect to your board, and test
% your IMU using some of the nanobot_demo.m code.  You can try writing
% (single or averaged) accelerometer values to the screen and/or also 
% creating a live plot.  What are the x, y, and z values when the board 
% is flat vs. other angles?  
%
% HINT; 'accel' stands for accelerometer or IMU
nb.livePlot('accel');


%% 3. Visualizing IMU tilt
% This section of code will set up a 3D block that we will plot (in the 
% next section of code) and use to visualize the Arduino board and its 
% orientation.  This section only needs to be run.  In the next section 
% of code, the plot will be created.

% Initialize the cube (RUN ME to set up the cube display)
xc=0; yc=0; zc=0;    % cube center coordinates
L=2;                 % cube size (length of an edge)
alpha=0.8;           % transparency (max=1=opaque)

% define the X, Y, and Z coordinates of each corner of the box; used to 
% plot each face of the box
X = [0 0 0 0 0 1; 1 0 1 1 1 1; 1 0 1 1 1 1; 0 0 0 0 0 1];
Y = [0 0 0 0 1 0; 0 1 0 0 1 1; 0 1 1 1 1 1; 0 0 1 1 1 0];
Z = [0 0 1 0 0 0; 0 0 1 0 0 0; 1 1 1 0 1 1; 1 1 1 0 1 1];

C= [0.1 0.5 0.9 0.9 0.1 0.5];   % each face of the box will have a 
                                % different color

X = L/1.5.*(X-0.5) + xc; %define the board length in the X-direction
Y = L*(Y-0.5) + yc;  %this is the long dimension of the board
Z = L/3*(Z-0.5) + zc; %this is the smallest dimension of the board
V=[reshape(X,1,24); reshape(Y,1,24); reshape(Z,1,24)]; %reshape takes all 
% of the elements of the 3D X matrix (and Y and Z matrices) and puts them 
% all into one column.  Sol the first column of V is all of the X elements,
% the second column of V is all of the Y elements, and the third column of
% V is all of the Z elements.

%% Track IMU pose (plot and track the tilt of the board)
% In this section, once you figure out all of the '?' areas, the 
% 3D block you defined in the last section will be plotted and will 
% rotate as you physically change the tilt of your board (i.e. it will 
% replicate the movements of your board). In addition, a game has been 
% set up in which you must match a random orientation (when playing the 
% game, make sure you uncomment both of the game-related parts of the 
% code).

% Note:  If you get an error when trying to run "angle2dcm," then you
% likely need to install the Aerospace Toolbox (available for free through
% the University Matlab license).

% Offset Calibration:
calib1 = input('Press Enter once the Arduino is lying flat (IMU chip parallel to horizon)');
% Now calibrate x and y
% Here is an example of taking 10 accelerometer readings, then averaging
% each axis:
numreads = 10;
vals = zeros(3,numreads);
for i = 1:numreads
    val = nb.accelRead();
    vals(1,i) = val.x;
    vals(2,i) = val.y;
    vals(3,i) = val.z;
end
%Note the index, getting every column in a specific row for each axis:
meanOffx = mean(vals(1,:));
meanOffy = mean(vals(2,:));
meanOffz = mean(vals(3,:));
% If we tilt the board, we want to know the change in position relative to
% it being flat:
xOff = 0 - meanOffx; % What is the expected x value when the chip is flat?
                       % You can use the results from Part 2 of this lab.
yOff = 0 - meanOffy; % What is the expected y value when the chip is flat?
zOff = 1 - meanOffz; % What is the expected z value when the chip is flat?

% % IF PLAYING GAME, UNCOMMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 pitchT = randi([-60, 60]);
 pitchT = pitchT * pi/180;
 rollT = randi([-60, 60]);
 rollT = rollT * pi/180;
 
 dcm_targ = angle2dcm(0, pitchT, rollT);
 V_targ = dcm_targ*V;
 X_targ=reshape(V_targ(1,:),4,6);
 Y_targ=reshape(V_targ(2,:),4,6);
 Z_targ=reshape(V_targ(3,:),4,6);
 
 figure(1)
 
 fill3(X_targ,Y_targ,Z_targ,C,'FaceAlpha',alpha);
 xlim([-2 2]);
 ylim([-2 2]);
 zlim([-2 2]);
 xlabel('X');
 ylabel('Y');
 zlabel('Z');
 box on;
 drawnow
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic; %to count the seconds


while(toc<20) % stop after this many seconds

    numreads = 3;
    IMUvals = zeros(3,numreads);
    for i = 1:numreads
        val = nb.accelRead();
        IMUvals(1,i) = val.x;
        IMUvals(2,i) = val.y;
        IMUvals(3,i) = val.z;
    end
    %Note the index, getting every column in a specific row for each axis:
    meanx = mean(IMUvals(1,:));
    meany = mean(IMUvals(2,:));
    meanz = mean(IMUvals(3,:));
    ax = meanx + xOff; 
    ay = meany + yOff;
    az = meanz + zOff;

    % We will determine the angles individually for each axis of the 
    % 3-axis accelerometer.
    theta = atan((ax)/(sqrt(ay^2+az^2))); % Find this in the readings!
    psi = atan((ay)/(sqrt(ay^2+az^2))); % ^
    phi = atan((sqrt(ay^2+az^2))/az); % ^
    
    % To help you figure out what to fill in below for the '?', look at the
    % rest of the code in this section just under the commented 
    % "IF PLAYING GAME" section below.  Also, look at the information
    % provided in MATLAB "help angle2dcm" and look at the image in Canvas.
    dcm_acc = angle2dcm(0, psi, theta); % creates the rotation matrix;
                                    % one of the parameters will be 0 
                                    % because we are only interested in the
                                    % tilt angle, which is pitch and roll
                                    % (not yaw)
                      

    % % IF PLAYING GAME, UNCOMMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%
     pitchCheck = psi * 180/pi;
     rollCheck = theta * 180/pi;
     if((pitchCheck > (rad2deg(pitchT) - 5)) & ...
             (pitchCheck < (rad2deg(pitchT) + 5)) & ...
             (rollCheck > (rad2deg(rollT) - 5)) & ...
             (rollCheck < (rad2deg(rollT) + 5)))
         fprintf('Matching desired orientation!\n');
     else
         fprintf('Not matching desired orientation...\n');
     end
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    V_rot=dcm_acc*V;
    % extract the X, Y, and Z vectors for plotting
    X_rot=reshape(V_rot(1,:),4,6);
    Y_rot=reshape(V_rot(2,:),4,6);
    Z_rot=reshape(V_rot(3,:),4,6);


    figure(2)

    fill3(X_rot,Y_rot,Z_rot,C,'FaceAlpha',alpha);
    xlim([-2 2]); % make the limits in all directions the same so the box
    ylim([-2 2]); % is plotted on the same scale in all directions
    zlim([-2 2]);
    xlabel('X'); 
    ylabel('Y');
    zlabel('Z');
    box on;
    drawnow

    pause(0.1);
  
end

%% 4. EXTENSION (optional)
% - Change the color of the 3d block being displayed every time you press a
% pushbutton.
% - Change the color of the 3d block being displayed every time you tap 
% the accelerometer.

%% 5. DISCONNECT
%  Clears the workspace and command window, then
%  disconnects from the nanobot, freeing up the serial port.

clc
delete(nb);
clear('nb');
clear all