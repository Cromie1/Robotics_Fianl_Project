function turnFunc(direction)
if direction.equals('right')
    nb.setMotor(1, 20);
    nb.setMotor(2, -10);
    
    pause(0.58);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
elseif direction.equals('left')
    nb.setMotor(1, -10);
    nb.setMotor(2, 20);
    
    pause(0.58);
    
    nb.setMotor(1, 0);
    nb.setMotor(2, 0);
else
    return
end