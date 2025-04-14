%% Turn in direction of color
function RGBFunc(nb)
nb.initColor()
values = nb.colorRead();
red = values.red;
blue = values.blue;

nb.setMotor(1, 10);
nb.setMotor(2, 10);

pause(0.5);

nb.setMotor(1, 0);
nb.setMotor(2, 0);

if(red > blue) % Turn 45 degrees left

    nb.setMotor(1, 10);
    nb.setMotor(2, -10);
    
    pause(0.58);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);

    % Go Straight until it reaches square
    pause(1);
    nb.setMotor(1, 12);
    nb.setMotor(2, 11);
    
    pause(1.1);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Turn around
    pause(1);
    nb.setMotor(1, -10);
    nb.setMotor(2, 10);
    
    pause(1.65);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Go back to original square
    pause(1);
    nb.setMotor(1, 12);
    nb.setMotor(2, 11);
    
    pause(.9);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);

else % Turn 45 degrees right
    nb.setMotor(1, -10);
    nb.setMotor(2, 10);
    
    pause(0.55);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);

    % Go Straight until it reaches square
    pause(1);
    nb.setMotor(1, 12);
    nb.setMotor(2, 10);
    
    pause(1.1);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Turn around
    pause(1);
    nb.setMotor(1, -10);
    nb.setMotor(2, 10);
    
    pause(1.65);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
    
    % Go back to original square
    pause(1);
    nb.setMotor(1, 12);
    nb.setMotor(2, 11);
    
    pause(.8);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
end
end