function value = fitnessATOM(r, s, model, params, Cmax)  
      newModelName = 'fitness-model';
      updateReplication(model.name, newModelName, r)
      updateHostDemand(newModelName, newModelName, s)
      [value, ~] = solveModel(newModelName, model, params, Cmax, r, s);
      value = -value; % This is just for optimtool (minimize)
end
