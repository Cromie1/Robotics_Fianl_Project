clc
clear all

% First, scan the current USB devices
initialPorts = serialportlist;

% Prompt the user
disp('Plug in your Arduino then press enter to confirm.');
pause; % Wait for user to press Enter

% Scan again after the user has plugged in the Arduino
newPorts = serialportlist;

% Find the new port by comparing the two lists
newPort = setdiff(newPorts, initialPorts);

% Display the new port name
if isempty(newPort)
    disp('No new Arduino detected.');
else
    disp(['New Arduino detected at port: ''', newPort{1}, '''']);
    disp('Copy and paste that port name into your class constructor!')
end