function [x,fval,exitflag,output,population,score] = evolutionaryGaSolution(st, N, M, psi, Cmax, tau1, tau2, Q, modelName)
    % x is the vector rt
    f = @(x)fitnessATOM(x, st, N, M, psi, Cmax, tau1, tau2, modelName);
    
    % Load default settings
    options = optimoptions('ga');
    %% Modify options setting
    options = optimoptions(options,'PopulationType', 'doubleVector'); % 'doubleVector' is the default
    options = optimoptions(options,'PopulationSize', 20);
    options = optimoptions(options,'MaxGenerations', 10);
    %options = optimoptions(options,'FitnessLimit', -0.5);
    % TODO time limit 2.5 minutes
    options = optimoptions(options,'MutationFcn', {  @mutationuniform 0.1 });
    options = optimoptions(options,'Display', 'off');
    options = optimoptions(options,'PlotFcn', { @gaplotbestfun });
    
    intcon = 1:N;       % All values are integers
    lb = ones(1,4);    % Lower bound
    ub = Q;

    %% Run genetic algorithm
    [x,fval,exitflag,output,population,score] = ...
        ga(f,N,[],[],[],[],lb,ub,[],intcon,options);
    
    fprintf("Generations:%d\n", output.generations);
end