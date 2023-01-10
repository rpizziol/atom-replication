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
global currNuser 

% Default service times
model.thinkTime = 0.27538;

model.st = [0.15673, 0.085154, 0.15428, 0.20552, 0.044829, 0.14698, ...
    0.0991, 0.095022, 0.052992];

model.ms=["MSauth","MSvalidateid","MSviewprofile","MSupdateprofile"...
    ,"MSupdateMiles","MSbookflights","MScancelbooking"...
    ,"MSqueryflights","MSgetrewardmiles"];

model.redisConn = Redis("localhost",6379);

repFac = [1, 1, 2, 1, 4, 1, 2, 1, 4];

model.totalTime = model.thinkTime + sum(model.st .* repFac);

%% Objective function's parameters
params.psi = zeros(model.N, model.M); % Weights of transactions
params.psi(1,1) = 1;

currNuser = getCurrentUsers(model.redisConn);

% [1, 0, 0, 0, 0]
% [0, 0, 0, 0, 0]
% [0, 0, 0, 0, 0]
% [0, 0, 0, 0, 0]
% [0, 0, 0, 0, 0]

params.tau1 = 0.5; % Objective function weight 1
params.tau2 = 0.5; % Objective function weight 2

%% Constraints for r and s
Qmax = 1200; % Max number of replicas for each microservice
params.Q = [Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax];
% CPUshare for each replica of each ms for the time interval t
min_s = 1.0;  % Lower bound
params.s_lb = [min_s, min_s, min_s, min_s, min_s, min_s, min_s, ...
    min_s, min_s];
% max_s = 35*1.5*(currNuser/200);      % Upper bound
max_s=200;
params.s_ub = [max_s, max_s, max_s, max_s, max_s, max_s, max_s, ...
    max_s, max_s];
end

