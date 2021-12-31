clear
rng('shuffle')

%% Global parameters
% Total time limit (in seconds)
maxTimeLimit = 5*60; % default: 40 minutes

% Model parameters
model.N = 4; % Number of microservices (tasks)
model.M = 3; % Number of classes (max entries)

% Inputs of algorithm 1
modelName = 'atom';
timeLimit = 120; % Time limit (in seconds)
tolerance = 0.6; % TODO

% Algorithm 1 parameters
psi = rand(model.N, model.M); % Weights of transactions
tau1 = 0.5; % Objective function weight 1
tau2 = 0.5; % Objective function weight 2

% Constraints for r and s
Q = randi([2, 10], 1, model.N); % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
s_lb = randi([0, 200], 1, model.N); % Lower bound (0 - 0.2) * 1000
s_ub = randi([800, 1000], 1, model.N); % Upper bound (0.8 - 1.0) * 1000

disp('Global parameters set.');
beginning = tic();
stepCounter = 0;

TPSs = [];
times = [];

while toc(beginning) <= maxTimeLimit
    stepCounter = stepCounter + 1;
    % Algorithm 1 execution
    % Generate initial config set
    configs = generateInitialConfig(Q, s_lb, s_ub, model.N, 20);
    
    % Initialize set of solution candidates (G)
    G.r = ones(0,model.N);
    G.s = ones(0,model.N);
    G.f = ones(0,1);
    
    startLoop = tic();
    fprintf('Loop nr. %d\n', stepCounter);
    while toc(startLoop) <= timeLimit
        K = size(configs.r,1); % Size of the current loop
    
        % Initialize set of current loop solution candidates
        currentCandidates.r = ones(0,model.N);
        currentCandidates.s = ones(0,model.N);
        currentCandidates.f = ones(0,1);
    
        configs.f = zeros(1, K);
    
        for i = 1:K
            fprintf('.'); % TODO remove this
            configuratedModel = strcat(modelName, '-', int2str(i));
            updateReplication(configs.r(i, :), configuratedModel);
            % updateCalls(configs.r(i), model); % TODO
            % updateHostDemand(configs.s(i), model); % TODO
            Cmax = sum(Q.*s_ub);
            [configs.f(i), c] = solveModel(configuratedModel, model.N, model.M, psi,...
                tau1, tau2, Cmax, configs.r(i, :), configs.s(i, :));
            if c <= tolerance
                % Add configuration to configuration candidates
                currentCandidates.r(end+1, :) = configs.r(i, :);
                currentCandidates.s(end+1, :) = configs.s(i, :);
                currentCandidates.f(end+1) = configs.f(i);
            end
        end
        fprintf('\n'); % TODO remove this
        configs = generateConfig(currentCandidates, model.N, Q, s_lb, s_ub);
        % Update the set of solution candidates
        G.r = [G.r; currentCandidates.r];
        G.s = [G.s; currentCandidates.s];
        G.f = [G.f, currentCandidates.f];
    end
    
    %% Scaling planner
    
    sigRate = 0.1; % Significance rate

    % Since in the first loop bestConf is unknown, skip these steps
    if exist('bestConf', 'var')
        % First update: CPU share minimization
        for i = 1:size(G.r,1)
            % Copy the new configuration
            tempConf.s = G.s(i, :);
            tempConf.r = G.r(i, :);
            % Calculate new TPS (without first update)
            newTPS = calculateTPS(G.r(i, :));
            for j = 1:size(tempConf.r)
                % Check if a microservice was allocated less CPU share in
                % the previous monitoring window
                if bestConf.s(j) < tempConf.s(j)
                    % Temporarily update the new configuration (with old
                    % values)
                    tempConf.s(j) = bestConf.s(j);
                    tempConf.r(j) = bestConf.r(j);
                    % Calculate temp TPS
                    tempTPS = calculateTPS(tempConf.r);
                    if (tempTPS - newTPS > - tempTPS * sigRate)
                        % Update the configuration with the old value
                        G.s(i, :) = tempConf.s;
                        G.r(i, :) = tempConf.r;
                        % Create temp lqn file
                        updateReplication(G.r(i, :), "test");
                        [G.f(i), ~] = solveModel("test", model.N, model.M, psi, tau1,...
                            tau2, Cmax, G.r(i, :), G.s(i, :));
                    end
                end
            end
        end
    
        % Second update: replicas reduction
        for i = 1:size(G.r,1)
            % Copy the new configuration
            tempConf.s = G.s(i, :);
            tempConf.r = G.r(i, :);
            % Calculate new TPS (without second update)
            newTPS = calculateTPS(G.r(i, :));
            for j = 1:size(G.r(i,:))
                % Reduce replicas and increase CPU share (leaving total
                % CPU share the same).
                while tempConf.r(j) > 1
                    CPUshare = tempConf.r(j) * tempConf.s(j);
                    tempConf.r(j) = tempConf.r(j) - 1;
                    tempConf.s(j) = CPUshare / tempConf.r(j);
                    tempTPS = calculateTPS(tempConf.r);
                    if (tempTPS - newTPS > - tempTPS * sigRate)
                        % Update the configuration with the new values
                        G.s(i, :) = tempConf.s;
                        G.r(i, :) = tempConf.r;
                        updateReplication(G.r(i, :), "test");
                        [G.f(i), ~] = solveModel("test", model.N, model.M, psi, tau1,...
                            tau2, Cmax, G.r(i, :), G.s(i, :));
                    end
                end
            end
        end
    end

    % After that, the planner creates the scaling conﬁgurations from the
    % best solution candidate, which are executed by the scaling executor.
    [~, maxIndex] = max(G.f);
    bestConf.r = G.r(maxIndex, :);
    bestConf.s = G.s(maxIndex, :);
    bestConf.tps = calculateTPS(bestConf.r);
    
    % Display the best configuration
    disp('+++ BEST CONFIGURATION +++');
    fprintf(' r = [%i, %i, %i, %i]\n', bestConf.r.');
    fprintf(' s = [%4.2f, %4.2f, %4.2f, %4.2f]\n', bestConf.s.');
    fprintf(' TPS =  %4.2f\n', bestConf.tps);
    TPSs = [TPSs; bestConf.tps];
    times = [times; toc(beginning)];
end
plot(times, TPSs);

% TODO plot TPS variation

% Genetic alg
% Model ATOM
% Add bestConf iniziale (per N = 500 browsing workload)
% plots (N = 500 -> 1000)










