clear
close('all');
rng('default'); % For replication of the experiment 

%% Model definition
% % Model with 3 tasks
% sourcemodel = './res/model1.lqn';
% %temppath = './out/temp1.lqn';
% model.N = 3; % Number of microservices (tasks)
% model.M = 3; % Number of classes (max entries)
% % Starting service time for each entry
% st = [0.0012, 0.0021, 0.0037, 0.0051];
% rv = [1000, 1000];
% nuser = 3000;

% Complete model
%sourcemodel = './res/model2.lqn';
%temppath = './out/temp2.lqn';
%model.N = 7; % Number of microservices (tasks)
%model.M = 3; % Number of classes (max entries)
% Starting service time for each entry
%st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174, 0.0056];
%nuser = 3000;

% Full model in xml
sourcemodel = './res/atom-full_template3.lqnx';
model.N = 7;
model.M = 3;    % Number of classes (max entries)
nuser = 3000;
st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
    0.0056];
rv = [nuser, nuser, nuser, nuser];

%% Objective function's parameters
%params.psi = rand(model.N, model.M); % Weights of transactions
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
constraints.Q = [1200, 1200, 1200, 1200]; % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
constraints.s_lb = [0.001, 0.001, 0.001, 0.001];  % Lower bound
constraints.s_ub = [100, 100, 100, 100];      % Upper bound
Cmax = sum(constraints.s_ub); %constraints.Q.*constraints.s_ub);

global allBest 

%% Genetic algorithm
global start 
start = tic();

f = @(x)fitness(x, sourcemodel, st, rv, model, params, Cmax, nuser);
options = optimoptions('ga'); % Load default settings
options = optimoptions(options,'PopulationType', 'doubleVector');
options = optimoptions(options,'PopulationSize', 50); % default: 50
options = optimoptions(options,'MaxGenerations', 400); % default: 100*nvars
options = optimoptions(options,'MaxStallGenerations', 10);
options = optimoptions(options,'MutationFcn', { @mutationadaptfeasible 0.1 });
options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @printState });
%options = optimoptions(options, 'OutputFcn', @printState);
%options = optimoptions(options,'Display', 'iter');
[x, fval, exitflag, output, population, scores] = ga(f, model.N -3, [],...
    [], [], [], constraints.s_lb, constraints.s_ub, [], [], options);
toc()

save('allBest.mat', 'allBest');