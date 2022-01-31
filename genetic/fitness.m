function value = fitness(cpushare, sourcemodel, st, rv, model, params, Cmax, nuser)
      newModelName = 'fittmp';

%       temppath = './out/fittmp.lqn';
      temppath = './out/fittmp.lqnx';
      updateModel(sourcemodel, temppath, 'nuser', nuser);
      updateModel(temppath, temppath, 'rv', rv);
      [np2, st2] = calculateByCPUShare(st, cpushare);

      updateModel(temppath, temppath, 'st', st2);
      updateModel(temppath, temppath, 'np', np2);
      %% Check if st2 violates the SLA
      % SLA is 110% of the nominal service time
      SLA = st*1.1;
      if sum(st2 > SLA) > 0 % At least one value violates the SLA
          value = Inf;
      else
          %% Calculate the Theta
          value = solveModel(newModelName, model, params, Cmax, rv, cpushare);
          value = -value; % This is just for optimtool (minimize)
      end
end
