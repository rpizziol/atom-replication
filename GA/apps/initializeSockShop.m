function [model, params] = initializeSockShop(wm)
%INITIALIZESOCKSHOP Summary of this function goes here
%   Detailed explanation goes here
%% Model definition
% Input model template
model.name = 'sockshop';
model.extension = 'lqnx';
model.template_path = './res/sockshop-template.lqnx';
model.N = 7;    % Number of tasks
model.M = 3;    % Number of classes (max entries)

model.wm = wm; % Workload mix

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
params.Q = [1200, 1200, 1200, 1200]; % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
params.s_lb = [0.001, 0.001, 0.001, 0.001];   % Lower bound
max_s = 5; % old value: 30
params.s_ub = [max_s, max_s, max_s, max_s];   % Upper bound

end
