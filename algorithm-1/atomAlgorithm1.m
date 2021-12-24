clear
rng('shuffle')

modelName = 'atom-4';

%% Define parameters
N = 4; % Number of microservices (tasks)
M = 3;  % Number of classes (max entries)

% Weights of transactions
psi = rand(N, M);

% Objective function weights
tau1 = 0.5;
tau2 = 0.5;

%% Generate a random initial set of configurations (r and s)
% Number of replicas for each microservice for the time interval t
Q = randi([2, 10], 1, N); % max number of replicas for each microservice
% rt = zeros(1, N);
% for i = 1:N
%     rt(i) = randi([1 Q(i)]);
% end

% CPU share for each replica of each microservice for the time interval t
s_lb = randi([0, 200], 1, N); % Lower bound (0 - 0.2) * 1000
s_ub = randi([800, 1000], 1, N); % Upper bound (0.8 - 1.0) * 1000

% Populate s between lower and upper bound
st = zeros(1, N);
for i = 1:N
    st(i) = randi([s_lb(i) s_ub(i)])/1000;
end

%% Calculate value of the objective function
Cmax = sum(Q.*s_ub);

tic
bestValues = evolutionaryGaSolution(st, N, M, psi, Cmax, tau1, tau2, Q, modelName);
toc