    clear
    close('all');
    rng('default'); % For replication of the experiment 

for j = 1:3
    wm_names = 'bso'; % browsing / shopping / ordering
    wmname = wm_names(j);

    workmixes = [0.63, 0.32, 0.05;
    0.54, 0.26, 0.20;
    0.33, 0.17, 0.50];

    workmix = workmixes(j, :);
    
    
    % Full model in xml
    sourcemodel = './res/atom-full_template5.lqnx'; % variable workload mix
    
    model.N = 7;
    model.M = 3;    % Number of classes (max entries)
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
    constraints.s_ub = [100, 100, 100, 100];      % Upper bound
    Cmax = sum(constraints.s_ub); %constraints.Q.*constraints.s_ub);
    
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global timeSlots
    global times
    
    %% Genetic algorithm
    global start 
    start = tic();
    
    f = @(x)fitness(x, sourcemodel, st, model, params, Cmax, workmix, wmname);
    %ConstraintFunction = @SLAConstraint;
    
    options = optimoptions('ga'); % Load default settings
    options = optimoptions(options,'PopulationType', 'doubleVector');
    options = optimoptions(options,'PopulationSize', 50); % default: 50
    options = optimoptions(options,'MaxGenerations', 400); % default: 100*nvars
    options = optimoptions(options,'MaxTime', 300);
    options = optimoptions(options,'MaxStallGenerations', 10);
    options = optimoptions(options,'MutationFcn', { @mutationadaptfeasible 0.1 });
    options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @printState });
    %options = optimoptions(options, 'OutputFcn', @printState);
    %options = optimoptions(options,'Display', 'iter');
    
    [x, fval, exitflag, output, population, scores] = ga(f, model.N -3, [],...
    [], [], [], constraints.s_lb, constraints.s_ub, [], [], options); %ConstraintFunction
    toc(start);
    
    save(strcat('sintest-', wmname, '.mat'), 'bestIndividuals', ...
        'bestValues', 'bestTimeStamps', 'nusersInTime', 'timeSlots', ...
        'times');

    clear
    close('all');
    rng('default'); % For replication of the experiment 
    %clear bestValues bestIndividuals bestTimeStamps nusersInTime ...
    %    timeSlots times

    %bestThroughputs = getBestThroughputs(st, rv, nuser, sourcemodel, bestIndividuals);
end
