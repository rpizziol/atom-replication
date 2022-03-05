function configs = generateConfig(currentCandidates, model, constraints, params, Cmax)
    % TODO add s to optimization variables
    f = @(x)fitnessATOM(x, currentCandidates.s(1,:), model, params, Cmax);
    
    options = optimoptions('ga'); % Load default settings
    options = optimoptions(options,'PopulationType', 'doubleVector');
    options = optimoptions(options,'PopulationSize', size(currentCandidates.r, 1));
    options = optimoptions(options,'MaxGenerations', 1);
    options = optimoptions(options,'MutationFcn', {  @mutationuniform 0.1 });
    options = optimoptions(options,'Display', 'off');
    options = optimoptions(options,'InitialPopulation', currentCandidates.r);
    % options = optimoptions(options,'FitnessLimit', -0.5);
    % options = optimoptions(options,'PlotFcn', { @gaplotbestfun });
    
    intcon = 1:model.N;      % All values are integers
    lb = ones(1,model.N);    % Lower bound
    ub = constraints.Q;

    %% Run genetic algorithm
    [~,~,~,~,newPopulation] = ga(f,model.N,[],[],[],[],lb,ub,[],intcon,options);
    configs.r = newPopulation;
    configs.s = currentCandidates.s;
end

