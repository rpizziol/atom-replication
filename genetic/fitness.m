function value = fitness(cpushare, sourcemodel, st, rv, model, params, Cmax, nuser)
    newModelName = 'fittmp';
    
    %       temppath = './out/fittmp.lqn';
    temppath = './out/fittmp.lqnx';
    updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'rv', rv);
    [np2, st2] = calculateByCPUShare(st, cpushare);
    
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);
    
    %% Calculate the Theta
    % Obtain response time (service-time from xml)
    [value, rt] = solveModel(newModelName, model, params, Cmax, rv, cpushare);
    %% Check if st2 violates the SLA
    % SLA is 110% of the nominal service time
    SLA = st*1.1;
    if sum(rt > SLA) > 0 % At least one value violates the SLA
        value = 10;
    else
        value = -value; % This is just for optimtool (minimize)
    end
end
