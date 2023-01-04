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
    % think time = 0.2738
    model.st = [0.151, 0.0812, 0.1505, 0.2013, 0.0403, 0.1008, ...
        0.0876, 0.0908, 0.0504];
    
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
    Qmax = 1200; % Max number of replicas for each microservice
    params.Q = [Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax, Qmax];
    % CPUshare for each replica of each ms for the time interval t
    min_s = 0.001;  % Lower bound
    params.s_lb = [min_s, min_s, min_s, min_s, min_s, min_s, min_s, ...
        min_s, min_s];
    max_s = 5;      % Upper bound
    params.s_ub = [max_s, max_s, max_s, max_s, max_s, max_s, max_s, ...
        max_s, max_s]; 
end

