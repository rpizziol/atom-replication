clear
rng('shuffle')

%% Input of algorithm 1
modelName = 'atom';
timeLimit = 120; % Time limit in seconds
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

K = 20; % Number of solution candidates in the initial configuration

configs = generateInitialConfig(Q, s_lb, s_ub, N, K);

%% Calculate value of the objective function
Cmax = sum(Q.*s_ub);

% Set of solution candidates
G.r = ones(0,N);
G.s = ones(0,N);
G.f = ones(0,1);

tic
while toc < timeLimit
    fvals = zeros(1, size(configs.r, 1));
    currentCandidates.r = ones(0,N);
    currentCandidates.s = ones(0,N);
    currentCandidates.f = ones(0,1);

    for i = 1:size(configs.r, 1)
        model = strcat(modelName, '-', int2str(i));
        updateReplication(configs.r(i, :), model);
        % updateCalls(configs.r(i), model); % TODO implement this method
        % updateHostDemand(configs.s(i), model); % TODO implement this method
        [fvals(i), c] = solveModel(model, N, M, psi, tau1, tau2, Cmax,...
            configs.r(i, :), configs.s(i, :));
        if c <= tolerance
            % Add configuration to configuration candidates
            currentCandidates.r(end+1, :) = configs.r(i, :);
            currentCandidates.s(end+1, :) = configs.s(i, :);
            currentCandidates.f(end+1) = fvals(i);
        end
    end
    configs = generateConfig(currentCandidates, N, Q, s_lb, s_ub);
    % Update the set of solution candidates
    G.r = [G.r; currentCandidates.r];
    G.s = [G.s; currentCandidates.s];
    G.f = [G.f, currentCandidates.f];
end

% tic
% bestValues = evolutionaryGaSolution(configs.s(1,:), N, M, psi, Cmax, tau1, tau2, Q, modelName);
% toc