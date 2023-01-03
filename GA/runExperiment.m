function runExperiment(model, params)
    %% Generate random seed    
    c = clock;
    rng(c(6));

    %% Values to save
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global start

    global testname 
        
    testname = getDateString();
    
    %% Genetic algorithm
    
    start = tic();
    
    f = @(x)fitness(x, model, params);
    
    options = optimoptions('ga'); % Load default settings
    options = optimoptions(options,'PopulationType', 'doubleVector');
    options = optimoptions(options,'PopulationSize', 50); % default: 50
    options = optimoptions(options,'MaxGenerations', 400); % default: 100*nvars
    options = optimoptions(options,'MaxTime', 2400); % 40m = 2400 seconds
    options = optimoptions(options,'MaxStallGenerations', 20);
    options = optimoptions(options,'MutationFcn', { @mutationadaptfeasible 0.1 });
    options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @printState });
    %options = optimoptions(options, 'OutputFcn', @printState);
    %options = optimoptions(options,'Display', 'iter');
    
    [x, fval, exitflag, output, population, scores] = ga(f, model.N - model.Nk, [],...
    [], [], [], params.s_lb, params.s_ub, [], [], options); %ConstraintFunction

    disp(exitflag);

    toc(start);
    
    % Save final output
    save(strcat('./out/mat/', testname, '.mat'), 'bestIndividuals', ...
        'bestValues', 'bestTimeStamps', 'nusersInTime', 'testname');
end

