function [x,fval,exitflag,output,population,score] = evolutionaryGaSolution(st, N, M, psi, Cmax, tau1, tau2)
    % x is the vector rt
    f = @(x)fitnessATOM(x, st, N, M, psi, Cmax, tau1, tau2);
    
    % Load default settings
    options = optimoptions('ga');
    %% Modify options setting
    options = optimoptions(options,'PopulationType', 'doubleVector'); % 'doubleVector' is the default
    options = optimoptions(options,'PopulationSize', 20);
    options = optimoptions(options,'MaxGenerations', 20);
    %options = optimoptions(options,'FitnessLimit', -0.5);
    options = optimoptions(options,'MutationFcn', {  @mutationuniform 0.1 });
    options = optimoptions(options,'Display', 'off');
    options = optimoptions(options,'PlotFcn', { @gaplotbestfun });
    
    %% Run genetic algorithm
    [x,fval,exitflag,output,population,score] = ...
        ga(f,N,[],[],[],[],[],[],[],[],options);
    
    fprintf("Generations:%d\n", output.generations);
end