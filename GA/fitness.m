% The fitness function minimized by the GA autoscaler.
% INPUTS
%   cpushare    : The CPU-share array (x of the fitness function)
%   model       : A structure containing information about the model.
%   params      : A structure containing parameters of the optimization.
% OUTPUTS
%   value       :
function value = fitness(cpushare, model, params)
    global currNuser 
     
    W = getCurrentUsers();

    currNuser = W;

    %% Generate temporary lqn file
    
    
    tempName = strcat('fittmp', getDateString());
    tempPath = strcat('./out/', tempName, '.', model.extension);

    [np2, st2] = calculateByCPUShare(cpushare, model);

    updateModel(model.template_path, tempPath, 'W', W);
    if (strcmp(model.name, 'sockshop'))
        workmix = getProbMix(model.wm);
        updateModel(tempPath, tempPath, 'wm', workmix);
        rv = [W, W, W, W];
        updateModel(tempPath, tempPath, 'rv', rv); % TODO add to acmeair too
    end
    
    updateModel(tempPath, tempPath, 'st', st2);
    updateModel(tempPath, tempPath, 'np', np2);
    
    %% Calculate the Theta
    value = solveModel(tempName, model, params, cpushare, W);
    value = -value;
end
