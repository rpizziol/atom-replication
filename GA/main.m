addpath('./utility/');
addpath('./res/');
wm = 'b';

%% Model definition
% Input model template
model.name = 'sockshop';
model.path = './res/sockshop-template.lqnx';

model.N = 7;    % Number of tasks
model.M = 3;    % Number of classes (max entries)

% Default service times
model.st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
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
cons.Q = [1200, 1200, 1200, 1200]; % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
cons.s_lb = [0.001, 0.001, 0.001, 0.001];   % Lower bound
max_s = 5; % old value: 30
cons.s_ub = [max_s, max_s, max_s, max_s];   % Upper bound

runExperiment(wm, model, params, cons);
