function value = fitness(cpushare, sourcemodel, st, model, params, ...
    constraints, workmix)
    
     global currNuser
     nuser = currNuser;

    rv = [nuser, nuser, nuser, nuser];
    

    c = clock;
    year = sprintf('%04d', c(1));
    month = sprintf('%02d', c(2));
    day = sprintf('%02d', c(3));
    hour = sprintf('%02d', c(4));
    minute = sprintf('%02d', c(5));
    seconds = sprintf('%02d', c(6));
    timestamp = strcat(year, month, day, '-', hour, minute, seconds);
    newModelName = strcat('fittmp', timestamp);
    temppath = strcat('./out/', newModelName, '.lqnx');

    [np2, st2] = calculateByCPUShare(st, cpushare);

    updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'wm', workmix);
    updateModel(temppath, temppath, 'rv', rv);
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(newModelName, model, params, constraints, rv, cpushare, nuser);
    value = -value;
end
