function runExperiment(workmix, nuser)
    %% Generate random seed    
    c = clock;
    rng(c(6));

    global currNuser
    currNuser = nuser;
    %% Model definition
    % Full model in xml
    sourcemodel = './res/atom-full_template6.lqnx'; % variable workload mix
    
    model.N = 7;    % Number of tasks
    model.M = 3;    % Number of classes (max entries)

    % Default service times
    st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
    0.0056];
    
    %% Objective function's parameters
    params.psi = zeros(model.N, model.M); % Weights of transactions
    params.psi(1,1) = 1;
    
    % [1, 0, 0, 0, 0]
    % [0, 0, 0, 0, 0]
    % [0, 0, 0, 0, 0]
    % [0, 0, 0, 0, 0]
    % [0, 0, 0, 0, 0]
    
    params.tau1 = 0.5; % Objective function weight 1
    params.tau2 = 0.5; % Objective function weight 2
    
    %% Constraints for r and s
    constraints.Q = [1200, 1200, 1200, 1200]; % Max number of replicas for each microservice
    % CPU share for each replica of each microservice for the time interval t
    constraints.s_lb = [0.001, 0.001, 0.001, 0.001];  % Lower bound
    max_s = 30;
    constraints.s_ub = [max_s, max_s, max_s, max_s];      % Upper bound
    

    %% Values to save
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global start

    global testname 
        
    
    %% Genetic algorithm
    
    start = tic();
    
    f = @(x)fitness(x, sourcemodel, st, model, params, constraints, workmix);
    
    options = optimoptions('ga'); % Load default settings
    options = optimoptions(options,'PopulationType', 'doubleVector');
    options = optimoptions(options,'PopulationSize', 50); % default: 50
    options = optimoptions(options,'MaxGenerations', 400); % default: 100*nvars
    %options = optimoptions(options,'MaxTime', 1000); % 1h40 = 6000 seconds NB printState should kill it at 600 seconds
    options = optimoptions(options,'MaxStallGenerations', 20);
    options = optimoptions(options,'MutationFcn', { @mutationadaptfeasible 0.1 });
    options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @printState });
    %options = optimoptions(options, 'OutputFcn', @printState);
    %options = optimoptions(options,'Display', 'iter');
    
    [x, fval, exitflag, output, population, scores] = ga(f, model.N -3, [],...
    [], [], [], constraints.s_lb, constraints.s_ub, [], [], options); %ConstraintFunction

    disp(exitflag);

    toc(start);
    
    save(strcat('./out/mat/', testname, '.mat'), 'bestIndividuals', ...
        'bestValues', 'bestTimeStamps', 'nusersInTime', 'testname');
end

