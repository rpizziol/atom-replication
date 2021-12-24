clear
rng('shuffle')

%% Input of algorithm 1
modelName = 'atom-4';
% timeLimit = 2 minutes; % TODO
% tolerance = 0.8; % TODO

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

[rConfigs, sConfigs] = generateInitialConfig(Q, s_lb, s_ub, N, K);

%% Calculate value of the objective function
Cmax = sum(Q.*s_ub);

tic
bestValues = evolutionaryGaSolution(sConfigs(1,:), N, M, psi, Cmax, tau1, tau2, Q, modelName);
toc