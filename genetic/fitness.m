function value = fitness(cpushare, sourcemodel, st, rv, model, params, Cmax, nuser)
    newModelName = 'fittmp';
    
    % Best response times possible (calculated with lqsim)
    rt_best = [0.00568904, 0.00210005, 0.00732427, 0.0165358, 0.00378144, ...
    0.00348144, 0.00710729, 0.0197073, 0.00790729];

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
    SLA = rt_best*1.1;
    if sum(rt > SLA) > 0 % At least one value violates the SLA
        value = 10;
        disp('SLA violation');
    else
        value = -value; % This is just for optimtool (minimize)
    end
end
