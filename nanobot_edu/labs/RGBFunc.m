%% Turn in direction of color
function RGBFunc(nb)
nb.initColor()
values = nb.colorRead();
red = values.red;
blue = values.blue;

% nb.setMotor(1, 11 +2);
% nb.setMotor(2, 11);
% 
% pause(0.5);

nb.setMotor(1, 0);
nb.setMotor(2, 0);

if(red > blue) 
    % Turn 45 degrees left

    nb.setMotor(1, 11 + 1)
    nb.setMotor(2, -11)

    pause(.5)
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);

    % Go Straight until it reaches square
    pause(1);
    nb.setMotor(1, 11 + 3.5);
    nb.setMotor(2, 11);
    
    pause(1.7);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Turn around
    nb.setMotor(1, 11 + 1)
    nb.setMotor(2, -11)

    pause(1.6)
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Go back to original square
    pause(1);
    nb.setMotor(1, 11 + 3.5);
    nb.setMotor(2, 11);
    
    pause(1.2);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);

else % Turn 45 degrees right

    nb.setMotor(1, -11 - 1)
    nb.setMotor(2, 11)

    pause(.55)
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);

    % Go Straight until it reaches square
    pause(1);
    nb.setMotor(1, 11 + 2);
    nb.setMotor(2, 11);
    
    pause(1.7);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Turn around
    nb.setMotor(1, 11 + 1)
    nb.setMotor(2, -11)

    pause(1.5)
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Go back to original square
    pause(1);
    nb.setMotor(1, 11 + 3);
    nb.setMotor(2, 11);
    
    pause(1.2);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
end
end