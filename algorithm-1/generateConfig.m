function configs = generateConfig(currentCandidates, model, constraints, params, Cmax)

    %newPopulation = generateInitialConfig(constraints, N, size(currentCandidates.r, 1));

%     genSize = size(currentCandidates.r, 1);

%     % Sort current candidates by fitness value
%     [sortedCandidates.f, I] = sort(currentCandidates.f, 'descend');
%     sortedCandidates.r = currentCandidates.r(I, :);
%     sortedCandidates.s = currentCandidates.s(I, :);
% 
%     eliteIndex = fix(genSize * 0.8);
% 
%     % Pick the best elite candidates
%     elitePopulation.r = sortedCandidates.r(1:eliteIndex, :);
%     elitePopulation.s = sortedCandidates.s(1:eliteIndex, :);
%     elitePopulation.f = sortedCandidates.f(1:eliteIndex);
% 
%     % Generate children through crossover
    

    


    %f = @(x)fitnessATOM(x, st, N, M, psi, Cmax, tau1, tau2, modelName);
    % TODO add s to optimization variables
    f = @(x)fitnessATOM(x, currentCandidates.s(1,:), model, params, Cmax);
    
    options = optimoptions('ga'); % Load default settings
    options = optimoptions(options,'PopulationType', 'doubleVector');
    options = optimoptions(options,'PopulationSize', size(currentCandidates.r, 1));
    options = optimoptions(options,'MaxGenerations', 2);
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

