function value = fitness(cpushare, wm, model, params)
    
    workmix = getProbMix(wm);
    nuser = getCurrentUsers(); % TODO obtain from Redis database

    rv = [nuser, nuser, nuser, nuser];
    
    tempName = strcat('fittmp', getDateString());
    tempPath = strcat('./out/', tempName, '.', model.extension);

    [np2, st2] = calculateByCPUShare(model.st, cpushare);

    updateModel(model.template_path, tempPath, 'nuser', nuser);
    updateModel(tempPath, tempPath, 'wm', workmix);
    updateModel(tempPath, tempPath, 'rv', rv);
    updateModel(tempPath, tempPath, 'st', st2);
    updateModel(tempPath, tempPath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(tempName, model, params, cpushare, nuser);
    value = -value;
end
