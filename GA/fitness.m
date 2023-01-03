function value = fitness(cpushare, model, params)
    global currNuser 
     
    W = getCurrentUsers(); % TODO obtain from Redis database

    currNuser = W;

    %% Generate temporary lqn file
    rv = [W, W, W, W];
    
    tempName = strcat('fittmp', getDateString());
    tempPath = strcat('./out/', tempName, '.', model.extension);

    [np2, st2] = calculateByCPUShare(cpushare, model);

    updateModel(model.template_path, tempPath, 'W', W);
    if (strcmp(model.name, 'sockshop'))
        workmix = getProbMix(model.wm);
        updateModel(tempPath, tempPath, 'wm', workmix);
    end
    updateModel(tempPath, tempPath, 'rv', rv);
    updateModel(tempPath, tempPath, 'st', st2);
    updateModel(tempPath, tempPath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(tempName, model, params, cpushare, W);
    value = -value;
end
