    clear
    close('all');
    rng('default'); % For replication of the experiment 

    
%for j = 1:3
j = 3;
    wm_names = 'bso'; % browsing / shopping / ordering
    global wmname
    wmname = wm_names(j);

    workmixes = [0.63, 0.32, 0.05;
    0.54, 0.26, 0.20;
    0.33, 0.17, 0.50];

    workmix = workmixes(j, :);
    
    
    % Full model in xml
    sourcemodel = './res/atom-full_template6.lqnx'; % variable workload mix
    
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
    constraints.s_ub = [50, 50, 50, 50];      % Upper bound
    
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
%     global timeSlots

    global currNuser

    global start
    for i = 1:10
        
        disp(i);
        currNuser = readNuser('./res/atom-full_template6.lqnx');
        
        %% Genetic algorithm
        
        start = tic();
        
        f = @(x)fitness(x, sourcemodel, st, model, params, constraints, workmix, wmname);
        %ConstraintFunction = @SLAConstraint;
        
        options = optimoptions('ga'); % Load default settings
        options = optimoptions(options,'PopulationType', 'doubleVector');
        options = optimoptions(options,'PopulationSize', 50); % default: 50
        options = optimoptions(options,'MaxGenerations', 400); % default: 100*nvars
        options = optimoptions(options,'MaxTime', 600); % 1h40 = 6000 seconds
        options = optimoptions(options,'MaxStallGenerations', 100);
        options = optimoptions(options,'MutationFcn', { @mutationadaptfeasible 0.1 });
        options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @printState });
        %options = optimoptions(options, 'OutputFcn', @printState);
        %options = optimoptions(options,'Display', 'iter');
        
        [x, fval, exitflag, output, population, scores] = ga(f, model.N -3, [],...
        [], [], [], constraints.s_lb, constraints.s_ub, [], [], options); %ConstraintFunction

        toc(start);
        
        save(strcat('./out/mat/sintest-', wmname, '.mat'), 'bestIndividuals', ...
            'bestValues', 'bestTimeStamps', 'nusersInTime');

        constraints.s_ub = x*3;
    end

 %   clear
  %  close('all');
   % rng('default'); % For replication of the experiment 
    %clear bestValues bestIndividuals bestTimeStamps nusersInTime ...
    %    timeSlots times

    %bestThroughputs = getBestThroughputs(st, rv, nuser, sourcemodel, bestIndividuals);
%end

