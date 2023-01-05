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
    model.thinkTime = 0.27538;

    model.st = [0.15673, 0.085154, 0.15428, 0.20552, 0.044829, 0.14698, ...
        0.0991, 0.095022, 0.052992];

    repFac = [1, 1, 2, 1, 4, 1, 2, 1, 4];

    model.totalTime = model.thinkTime + sum(model.st .* repFac);
    
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
    min_s = 0.1;  % Lower bound
    params.s_lb = [min_s, min_s, min_s, min_s, min_s, min_s, min_s, ...
        min_s, min_s];
    max_s = 20;      % Upper bound
    params.s_ub = [max_s, max_s, max_s, max_s, max_s, max_s, max_s, ...
        max_s, max_s]; 
end

