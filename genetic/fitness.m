function value = fitness(cpushare, sourcemodel, st, model, params, Cmax, workmix, wmname)
    global bestValues
    global bestIndividuals
    global bestTimeStamps    
    global start
    
    N = @(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
    %plot(N([0:60:6000],1500,6000,1510));

    disp(toc(start));
    nuser = N(toc(start), 1500, 6000, 1510);
    disp(nuser);

    rv = [nuser, nuser, nuser, nuser];
    newModelName = 'fittmp';

    %       temppath = './out/fittmp.lqn';
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
    %% Check if st2 violates the SLA
    % SLA is 110% of the nominal service time
    
%     if sum(rt > SLA) > 0 % At least one value violates the SLA
%         value = 1000;
%         disp('SLA violation');
%     else
%         value = -value; % This is just for optimtool (minimize)
%     end
    %disp(rt);
    %disp(SLA);
    value = -value;
    
    save(strcat('allbest-', int2str(nuser), wmname, '.mat'), 'bestIndividuals', 'bestValues', 'bestTimeStamps');
end
