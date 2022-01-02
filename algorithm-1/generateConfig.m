function configs = generateConfig(currentCandidates, N, constraints)

    configs = generateInitialConfig(constraints, N, size(currentCandidates.r, 1));

    % f = @(x)fitnessATOM(x, st, N, M, psi, Cmax, tau1, tau2, modelName);
%     % Load default settings
%     options = optimoptions('ga');
%     options = optimoptions(options,'PopulationType', 'doubleVector');
%     options = optimoptions(options,'PopulationSize', size(currentCandidates, 1));
%     options = optimoptions(options,'MaxGenerations', 2);
%     options = optimoptions(options,'MutationFcn', {  @mutationuniform 0.1 });
%     options = optimoptions(options,'Display', 'off');
%     % options = optimoptions(options,'FitnessLimit', -0.5);
%     % options = optimoptions(options,'PlotFcn', { @gaplotbestfun });
%     
%     intcon = 1:N;       % All values are integers
%     lb = ones(1,N);    % Lower bound
%     ub = Q;
% 
% 
%     %% Run genetic algorithm
%     [x,~,~,~,~,~] = ...
%         ga(f,N,[],[],[],[],lb,ub,[],intcon,options);
%     
%     fprintf("Generations:%d\n", output.generations);
end

