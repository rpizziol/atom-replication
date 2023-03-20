function [model, params] = initializeAcmeAir()
%INITIALIZEACMEAIR Summary of this function goes here
%   Detailed explanation goes here
%% Model definition
% Input model template
model.name = 'acmeair';
model.extension = 'lqn';
model.template_path = './res/acmeair-template.lqn';
model.N = 10;   % Number of tasks
model.Nk = 1;   % Number of tasks with known values
model.M = 1;    % Number of classes (max entries)

% Default service times
model.thinkTime = 0.2631;

model.st = [0.10367, 0.052292, 0.092846, 0.12455, 0.027508, 0.10152, ...
    0.072616, 0.056759, 0.031846];

model.RTmax=[1.2538;0.1548;0.0520;0.0923;0.1239;0.0274;0.2180;0.1307;0.0565;0.0316]*1.50;

model.ms=["MSauth","MSvalidateid","MSviewprofile","MSupdateprofile"...
    ,"MSupdateMiles","MSbookflights","MScancelbooking"...
    ,"MSqueryflights","MSgetrewardmiles"];

model.redisConn = Redis("localhost",6379);

repFac = [1, 1, 2, 1, 4, 1, 2, 1, 4];

model.totalTime = model.thinkTime + sum(model.st .* repFac);

%% Objective function's parameters
params.psi = zeros(model.N, model.M); % Weights of transactions
params.psi(1,1) = 1;

params.tau1 = 0.5; % Objective function weight 1
params.tau2 = 0.5; % Objective function weight 2

%% Constraints for r and s
Qmax = 1200; % Max number of replicas for each microservice
params.Q = [Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax];
% CPUshare for each replica of each ms for the time interval t
min_s = 0.1;  % Lower bound
params.s_lb = [min_s, min_s, min_s, min_s, min_s, min_s, min_s, ...
    min_s, min_s];

W = getCurrentUsers(model.redisConn);
max_s =15;      % Upper bound
params.s_ub = [max_s, max_s, max_s, max_s, max_s, max_s, max_s, ...
    max_s, max_s];
end

