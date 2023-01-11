% Run an experiment with the GA and save the results in a .mat file.
% INPUTS
%   model       : A structure containing information about the model.
%   params      : A structure containing parameters of the optimization.
function runExperiment(model, params)
    %% Generate random seed    
%     c = clock;
%     rng(c(6));

    %% Values to save
    global bestIndividuals
    global bestThroughputs
    global bestValues
    
    global bestTimeStamps
    global nusersInTime
    

    global testname 

    global countIndividual

    countIndividual = 0;


        
    uuid = char(matlab.lang.internal.uuid()); 
    testname = sprintf("%s#%s", getDateString(), uuid);
    
    global currNuser
    currNuser = getCurrentUsers(model.redisConn);

    %% Genetic algorithm
    
    f = @(x)fitness(x, model, params);
    
    options = optimoptions('ga'); % Load default settings
    options = optimoptions(options,'PopulationType', 'doubleVector');
    options = optimoptions(options,'PopulationSize', 10); % default: 50
    options = optimoptions(options,'MaxGenerations', 400); % default: 100*nvars
    options = optimoptions(options,'MaxTime', 5400); % 90m = 5400 seconds
    options = optimoptions(options,'MaxStallGenerations', 10); % old value: 20
    options = optimoptions(options,'MutationFcn', { @mutationadaptfeasible 1.0 });
    options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv});
    options = optimoptions(options, 'OutputFcn', @(options, state, flag)printState(options, state, flag,model));
    %options = optimoptions(options, 'OutputFcn', @printState);
    %options = optimoptions(options,'Display', 'iter');
    
    [x, fval, exitflag, output, population, scores] = ga(f, model.N - model.Nk, [],...
    [], [], [], params.s_lb, params.s_ub, [], [], options); %ConstraintFunction

    disp(exitflag);
    
    % Save final output ('#' stands for final)
    save(strcat('./out/mat/', testname, '#.mat'), 'bestIndividuals', ...
        'bestValues', 'bestTimeStamps', 'nusersInTime', 'testname', ...
        'bestThroughputs');
    delete(strcat('./out/mat/', testname, '.mat'));

    %% Print final throughput (it works only for stable input)
    %disp('The final output is: ')
    %disp(x);
    %disp('The calculated relative throughput is: ')
    %disp(getThroughputByCPUShare(x, model));
    %disp('The theorietical maximum throughput is: ')
    %disp(getCurrentUsers() / model.totalTime);
end

