clear
rng('shuffle')

%% Input of algorithm 1
modelName = 'atom';
timeLimit = 10; % Time limit in seconds
tolerance = 0.6; % TODO

%% Define parameters
N = 4; % Number of microservices (tasks)
M = 3;  % Number of classes (max entries)

% Weights of transactions
psi = rand(N, M);

% Objective function weights
tau1 = 0.5;
tau2 = 0.5;

%% Generate a random initial set of configurations (r and s)
Q = randi([2, 10], 1, N); % max number of replicas for each microservice

% CPU share for each replica of each microservice for the time interval t
s_lb = randi([0, 200], 1, N); % Lower bound (0 - 0.2) * 1000
s_ub = randi([800, 1000], 1, N); % Upper bound (0.8 - 1.0) * 1000

K = 5; % Number of solution candidates in the initial configuration

[rConfigs, sConfigs] = generateInitialConfig(Q, s_lb, s_ub, N, K);

%% Calculate value of the objective function
Cmax = sum(Q.*s_ub);


tic
while toc < timeLimit
    fvals = zeros(1, size(rConfigs, 1));
    currentCandidates.r = ones(0,N);
    currentCandidates.s = ones(0,N);
    currentCandidates.f = ones(0,1);
    
    for i = 1:size(rConfigs, 1)
        model = strcat(modelName, '-', int2str(i));
        updateReplication(rConfigs(i), model);
        % updateCalls(rConfigs(i), model); % TODO implement this method
        % updateHostDemand(sConfigs(i), model); % TODO implement this method
        [fvals(i), c] = solveModel(model, N, M, psi, tau1, tau2, Cmax,...
            rConfigs(i), sConfigs(i));
        if c <= tolerance
            % Add configuration to configuration candidates
            currentCandidates.r(end+1, :) = rConfigs(i, :);
            currentCandidates.s(end+1, :) = sConfigs(i, :);
            currentCandidates.f(end+1) = fvals(i);
        end
    end
    % [rConfigs, sConfigs] = generateConfig() % TODO
    % TODO add G
    %G 
end

% tic
% bestValues = evolutionaryGaSolution(sConfigs(1,:), N, M, psi, Cmax, tau1, tau2, Q, modelName);
% toc