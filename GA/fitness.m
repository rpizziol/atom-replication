function value = fitness(cpushare, model, params, ...
    constraints, workmix)
    
    %global currNuser
    nuser = getCurrentUsers();

    rv = [nuser, nuser, nuser, nuser];
    
    timestamp = getDateString();
    newModelName = strcat('fittmp', timestamp);
    temppath = strcat('./out/', newModelName, '.lqnx');

    [np2, st2] = calculateByCPUShare(model.st, cpushare);

    updateModel(model.path, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'wm', workmix);
    updateModel(temppath, temppath, 'rv', rv);
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(newModelName, model, params, constraints, rv, cpushare, nuser);
    value = -value;
end
