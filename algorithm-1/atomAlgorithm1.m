clear
rng('shuffle')

%% Global parameters
% Total experiment time limit (in seconds)
maxTimeLimit = 40*60; % default: 40 minutes

% Inputs of algorithm 1
% Model parameters
nuser = 500; % Total number of users
nc = [10, 3, 3]; % Number of cores for each task (without first one)
model.N = 4; % Number of microservices (tasks)
model.M = 3; % Number of classes (max entries)
sourcename = 'atom';
% Create .lqn file with nuser and nc
model.name = configureModel(sourcename, nuser, nc);

timeLimit = 120; % Time limit (in seconds)
tolerance = 0.95; % TODO

% Algorithm 1 parameters
params.psi = rand(model.N, model.M); % Weights of transactions
params.tau1 = 0.5; % Objective function weight 1
params.tau2 = 0.5; % Objective function weight 2
popSize = 10; % Starting population size of the genetic algorithm

% Constraints for r and s
constraints.Q = randi([2, 10], 1, model.N); % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
constraints.s_lb = randi([0, 200], 1, model.N); % Lower bound (0 - 0.2) * 1000
constraints.s_ub = randi([800, 1000], 1, model.N); % Upper bound (0.8 - 1.0) * 1000

% Steps' counters
stepCounter = 0;
window = 1;

% Arrays for final plot
TPSs = [];
times = [];

disp('Parameters set.');

% Initial best configuration (TODO obtain somehow)
bestConf.r = [3, 3, 1, 1];
bestConf.s = [0.21, 0.96, 0.94, 0.65];
bestConf.tps = calculateTPS(model.name, bestConf.r);


beginning = tic();
while toc(beginning) <= maxTimeLimit
    if window == 1 && toc(beginning)/60 > 5
        % Change N = 3000 concurrent users
        nuser = 3000;
        model.name = configureModel(sourcename, nuser, nc);
        window = 2;
    end

    if window == 2 && toc(beginning)/60 > 25
        % Change N = 500 concurrent users
        nuser = 500;
        model.name = configureModel(sourcename, nuser, nc);
    end

    stepCounter = stepCounter + 1;
    % Algorithm 1 execution
    % Generate initial config set
    configs = generateInitialConfig(constraints, model.N, popSize);
    
    % Initialize set of solution candidates (G)
    G.r = ones(0,model.N);
    G.s = ones(0,model.N);
    G.f = ones(0,1);
    
    startLoop = tic();
    fprintf('\n--- LOOP nr. %d ---\n', stepCounter);
    while toc(startLoop) <= timeLimit && ~isempty(configs.r)
        K = size(configs.r, 1); % Size of the current loop
        fprintf("K = %d\n", K);
    
        % Initialize set of current loop solution candidates
        currentCandidates.r = ones(0,model.N);
        currentCandidates.s = ones(0,model.N);
        currentCandidates.f = ones(0,1);
    
        configs.f = zeros(1, K);
    
        for i = 1:K
            fprintf('%d ', i); % TODO remove this
            configuratedModel = strcat(model.name, '-', int2str(i));
            updateReplication(model.name, configuratedModel, configs.r(i, :));
            % updateCalls(configs.r(i), model); % TODO
            % updateHostDemand(configs.s(i), model); % TODO
            Cmax = sum(constraints.Q.*constraints.s_ub);
            [configs.f(i), c] = solveModel(configuratedModel, model.N,...
                model.M, params, Cmax, configs.r(i, :), configs.s(i, :));
            if c <= tolerance
                % Add configuration to configuration candidates
                currentCandidates.r(end+1, :) = configs.r(i, :);
                currentCandidates.s(end+1, :) = configs.s(i, :);
                currentCandidates.f(end+1) = configs.f(i);
            end
        end
        fprintf('\n'); % TODO remove this
        configs = generateConfig(currentCandidates, model, constraints, params, Cmax);
        % Update the set of solution candidates
        G.r = [G.r; currentCandidates.r];
        G.s = [G.s; currentCandidates.s];
        G.f = [G.f, currentCandidates.f];
    end
    
    %% Scaling planner
    sigRate = 0.1; % Significance rate
    
    % First update: CPU share minimization
    fprintf('CPU share minimization. Updating G...\n');
    for i = 1:size(G.r,1)
        fprintf('%d ', i);
        % Copy the new configuration
        tempConf.s = G.s(i, :);
        tempConf.r = G.r(i, :);
        % Calculate new TPS (without first update)
        newTPS = calculateTPS(model.name, G.r(i, :));
        for j = 1:size(tempConf.r)
            % Check if a microservice was allocated less CPU share in
            % the previous monitoring window
            if bestConf.s(j) < tempConf.s(j)
                % Temporarily update the new configuration (with old
                % values)
                tempConf.s(j) = bestConf.s(j);
                tempConf.r(j) = bestConf.r(j);
                % Calculate temp TPS
                tempTPS = calculateTPS(model.name, tempConf.r);
                if (tempTPS - newTPS > - tempTPS * sigRate)
                    % Update the configuration with the old value
                    G.s(i, :) = tempConf.s;
                    G.r(i, :) = tempConf.r;
                    % Create temp lqn file
                    updateReplication(model.name, 'test', G.r(i, :));
                    [G.f(i), ~] = solveModel("test", model.N, model.M,...
                        params, Cmax, G.r(i, :), G.s(i, :));
                end
            end
        end
    end
    fprintf('\n');

    % Second update: replicas reduction
    fprintf('Replicas reduction. Updating G...\n');
    for i = 1:size(G.r,1)
        fprintf('%d ', i);
        % Copy the new configuration
        tempConf.s = G.s(i, :);
        tempConf.r = G.r(i, :);
        % Calculate new TPS (without second update)
        newTPS = calculateTPS(model.name, G.r(i, :));
        for j = 1:size(G.r(i,:))
            % Reduce replicas and increase CPU share (leaving total
            % CPU share the same).
            while tempConf.r(j) > 1
                CPUshare = tempConf.r(j) * tempConf.s(j);
                tempConf.r(j) = tempConf.r(j) - 1;
                tempConf.s(j) = CPUshare / tempConf.r(j);
                tempTPS = calculateTPS(model.name, tempConf.r);
                if (tempTPS - newTPS > - tempTPS * sigRate)
                    % Update the configuration with the new values
                    G.s(i, :) = tempConf.s;
                    G.r(i, :) = tempConf.r;
                    updateReplication(model.name, 'test', G.r(i, :));
                    [G.f(i), ~] = solveModel('test', model.N, model.M,...
                        params, Cmax, G.r(i, :), G.s(i, :));
                end
            end
        end
    end
    fprintf('\n');
    

    % After that, the planner creates the scaling conﬁgurations from the
    % best solution candidate, which are executed by the scaling executor.
    [~, maxIndex] = max(G.f);
    bestConf.r = G.r(maxIndex, :);
    bestConf.s = G.s(maxIndex, :);
    bestConf.tps = calculateTPS(model.name, bestConf.r);
    
    % Display the best configuration
    fprintf('Best Configuration of Loop %d is:\n', stepCounter);
    fprintf(' r = [%i, %i, %i, %i]\n', bestConf.r.');
    fprintf(' s = [%4.2f, %4.2f, %4.2f, %4.2f]\n', bestConf.s.');
    fprintf(' TPS =  %4.2f\n', bestConf.tps);
    TPSs = [TPSs; bestConf.tps];
    times = [times; toc(beginning)];
end
plot(times/60, TPSs);


% Genetic alg
% Model ATOM
% plots (N = 500 -> 1000)










