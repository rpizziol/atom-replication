function value = fitness(cpushare, sourcemodel, st, rv, model, params, Cmax)
      newModelName = 'fittmp';

      temppath = './out/fittmp.lqn';
      updateModel(sourcemodel, temppath, 'rv', rv);
      [np2, st2] = calculateByCPUShare(st, cpushare);
      updateModel(temppath, temppath, 'st', st2);
      updateModel(temppath, temppath, 'np', np2);

      value = solveModel(newModelName, model, params, Cmax, rv, cpushare);
      value = -value; % This is just for optimtool (minimize)
end
