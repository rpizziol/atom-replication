clear
rng('shuffle')

%% Global parameters
% Total time limit (in seconds)
maxTimeLimit = 10*60; % default: 40 minutes

% Model parameters
N = 4; % Number of microservices (tasks)
M = 3; % Number of classes (max entries)

% Inputs of algorithm 1
modelName = 'atom';
timeLimit = 120; % Time limit (in seconds)
tolerance = 0.6; % TODO

% Algorithm 1 parameters
psi = rand(N, M); % Weights of transactions
tau1 = 0.5; % Objective function weight 1
tau2 = 0.5; % Objective function weight 2

% Constraints for r and s
Q = randi([2, 10], 1, N); % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
s_lb = randi([0, 200], 1, N); % Lower bound (0 - 0.2) * 1000
s_ub = randi([800, 1000], 1, N); % Upper bound (0.8 - 1.0) * 1000

beginning = tic();
while toc(beginning) <= maxTimeLimit
    % Algorithm 1 execution
    % Generate initial config set
    configs = generateInitialConfig(Q, s_lb, s_ub, N, 20);
    
    % Initialize set of solution candidates (G)
    G.r = ones(0,N);
    G.s = ones(0,N);
    G.f = ones(0,1);
    
    startLoop = tic();
    while toc(startLoop) <= timeLimit
        K = size(configs.r,1); % Size of the current loop
    
        % Initialize set of current loop solution candidates
        currentCandidates.r = ones(0,N);
        currentCandidates.s = ones(0,N);
        currentCandidates.f = ones(0,1);
    
        configs.f = zeros(1, K);
    
        for i = 1:K
            configuratedModel = strcat(modelName, '-', int2str(i));
            updateReplication(configs.r(i, :), configuratedModel);
            % updateCalls(configs.r(i), model); % TODO
            % updateHostDemand(configs.s(i), model); % TODO
            Cmax = sum(Q.*s_ub);
            [configs.f(i), c] = solveModel(configuratedModel, N, M, psi,...
                tau1, tau2, Cmax, configs.r(i, :), configs.s(i, :));
            if c <= tolerance
                % Add configuration to configuration candidates
                currentCandidates.r(end+1, :) = configs.r(i, :);
                currentCandidates.s(end+1, :) = configs.s(i, :);
                currentCandidates.f(end+1) = configs.f(i);
            end
        end
        configs = generateConfig(currentCandidates, N, Q, s_lb, s_ub);
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
                        [G.f(i), ~] = solveModel("test", N, M, psi, tau1,...
                            tau2, Cmax, G.r(i, :), G.s(i, :));
                    end
    
                end
            end
        end
    
    % Secondly, to increase the TPS, ATOM reduces the number of replicas while
    % increasing the CPU share of each replica, keeping the total CPU share
    % same. It then checks again whether the TPS is affected signiﬁcantly and
    % if not, it keeps the modiﬁed conﬁguration. This improves the TPS since
    % reducing the number of replicas also reduces the parallelization
    % overhead.
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
                        [G.f(i), ~] = solveModel("test", N, M, psi, tau1,...
                            tau2, Cmax, G.r(i, :), G.s(i, :));
                    end
                end
            end
        end
    end

    % After that, the planner creates the scaling conﬁgurations from the best
    % solution candidate, which are executed by the scaling executor.
    
    [~, maxIndex] = max(G.f);
    bestConf.r = G.r(maxIndex, :);
    bestConf.s = G.s(maxIndex, :);
    
    % Display the best configuration
    disp('+++ BEST CONFIGURATION +++');
    disp(' r = ');
    disp(bestConf.r);
    disp(' s = ');
    disp(bestConf.s);
end










