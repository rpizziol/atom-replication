function value = fitness(cpushare, sourcemodel, st, model, params, ...
    Cmax, workmix, wmname)
    
    global currNuser

    nuser = currNuser;

    rv = [nuser, nuser, nuser, nuser];
    newModelName = 'fittmp';

    temppath = './out/fittmp.lqnx';

    [np2, st2] = calculateByCPUShare(st, cpushare);

    %updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(sourcemodel, temppath, 'wm', workmix);
    updateModel(temppath, temppath, 'rv', rv);
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(newModelName, model, params, Cmax, rv, cpushare);
    value = -value;

%     save(strcat('./out/mat/sintest-', wmname, '.mat'), 'bestIndividuals', ...
%         'bestValues', 'bestTimeStamps', 'nusersInTime', 'timeSlots', ...
%         'times');
end
