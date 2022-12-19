function value = fitness(cpushare, wm, model, params)
    global nusersInTime    
    
    workmix = getProbMix(wm);
    
    W = getCurrentUsers(); % TODO obtain from Redis database

    nusersInTime = W;

    %% Generate temporary lqn file
    rv = [W, W, W, W];
    
    tempName = strcat('fittmp', getDateString());
    tempPath = strcat('./out/', tempName, '.', model.extension);

    [np2, st2] = calculateByCPUShare(model.st, cpushare);

    updateModel(model.template_path, tempPath, 'W', W);
    updateModel(tempPath, tempPath, 'wm', workmix);
    updateModel(tempPath, tempPath, 'rv', rv);
    updateModel(tempPath, tempPath, 'st', st2);
    updateModel(tempPath, tempPath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(tempName, model, params, cpushare, W);
    value = -value;
end
