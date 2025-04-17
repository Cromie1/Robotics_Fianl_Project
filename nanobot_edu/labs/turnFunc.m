function turnFunc(direction, nb)
if isequal(direction, 'right')
    nb.setMotor(2, 11);
    
    pause(1.3);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
elseif isequal(direction, 'left')
    nb.setMotor(1, 13);
    
    pause(1.5);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
elseif isequal(direction, 180)
        nb.setMotor(1, 13 + 2);
        nb.setMotor(2, -13)
    pause(1.2);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
else
    return
end