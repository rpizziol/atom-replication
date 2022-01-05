function newPopulation = generateConfig(currentCandidates, N, constraints) %, params)

    newPopulation = generateInitialConfig(constraints, N, size(currentCandidates.r, 1));

%     genSize = size(currentCandidates.r, 1);
% 
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
    
% 
%     
% 
% 
%     %f = @(x)fitnessATOM(x, st, N, M, psi, Cmax, tau1, tau2, modelName);
%     f = @(x)fitnessATOM(x, st, N, M, Cmax, modelName, params);
%     
%     options = optimoptions('ga'); % Load default settings
%     options = optimoptions(options,'PopulationType', 'doubleVector');
%     options = optimoptions(options,'PopulationSize', size(currentCandidates, 1));
%     options = optimoptions(options,'MaxGenerations', 1);
%     options = optimoptions(options,'MutationFcn', {  @mutationuniform 0.1 });
%     options = optimoptions(options,'Display', 'off');
%     options = optimoptions(options,'InitialPop',currentCandidates);
%     % options = optimoptions(options,'FitnessLimit', -0.5);
%     % options = optimoptions(options,'PlotFcn', { @gaplotbestfun });
%     
%     intcon = 1:N;      % All values are integers
%     lb = ones(1,N);    % Lower bound
%     ub = constraints.Q;
% 
%     %% Run genetic algorithm
%     [~,~,~,~,newPopulation] = ga(f,N,[],[],[],[],lb,ub,[],intcon,options);
end

