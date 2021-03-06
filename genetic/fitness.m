function value = fitness(cpushare, sourcemodel, st, model, params, ...
    constraints, workmix)
    
     global currNuser
     nuser = currNuser;

    rv = [nuser, nuser, nuser, nuser];
    newModelName = 'fittmp';

    temppath = './out/fittmp.lqnx';

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
