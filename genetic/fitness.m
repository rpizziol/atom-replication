function value = fitness(cpushare, sourcemodel, st, model, params, ...
    Cmax, workmix, wmname, start)

    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global timeSlots
    global times
    
    %global start
    global currNuser
    global currTimeSlot
    global currTime  

    N = @(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
    %plot(N([0:600:6000],1500,6000,1510));

    window = 30; % change nusers every 10 minutes
    currTime = toc(start);
    timeSlot = floor(currTime / window); % Time sampled every 10 minutes
    nuser = floor(N(timeSlot*window, 1500, 6000, 1510));
    currNuser = nuser;
    currTimeSlot = timeSlot*window;

    rv = [nuser, nuser, nuser, nuser];
    newModelName = 'fittmp';

    temppath = './out/fittmp.lqnx';
    updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'wm', workmix);
    updateModel(temppath, temppath, 'rv', rv);
    [np2, st2] = calculateByCPUShare(st, cpushare);
    
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);
    
    %% Calculate the Theta
    % Obtain response time (service-time from xml)
    [value, rt] = solveModel(newModelName, model, params, Cmax, rv, cpushare);

    value = -value;
    save(strcat('sintest-', wmname, '.mat'), 'bestIndividuals', ...
        'bestValues', 'bestTimeStamps', 'nusersInTime', 'timeSlots', ...
        'times');
end
