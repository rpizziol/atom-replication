clear
close('all');
rng('default'); % For replication of the experiment 

sourcemodel = './res/model1.lqn';
temppath = './out/temp1.lqn';

%sourcemodel = './res/model2.lqn';
%temppath = './out/temp2.lqn';

model.N = 3; % Number of microservices (tasks)
model.M = 3; % Number of classes (max entries)

%params.psi = rand(model.N, model.M); % Weights of transactions
params.psi = zeros(model.N, model.M); % Weights of transactions
params.psi(1,1) = 1;

% [1, 0, 0]
% [0, 0, 0]
% [0, 0, 0]

params.tau1 = 0.5; % Objective function weight 1
params.tau2 = 0.5; % Objective function weight 2

% Constraints for r and s
constraints.Q = [1200, 1200]; %randi([2, 10000], 1, model.N-1); % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
constraints.s_lb = [0.001, 0.001]; %randi([0, 200], 1, model.N-1) / 1000; % Lower bound (0 - 0.2)
constraints.s_ub = [100, 100]; %randi([800, 100000], 1, model.N-1) / 1000; % Upper bound (0.8 - 100.0)

% Arrays defined for functions testing
rv = [1000, 1000];

st = [0.0012, 0.0021, 0.0037, 0.0051]; % Starting service time for each entry

%cpushare = [0.5, 1];

%[np2, st2] = calculateByCPUShare(st, cpushare);

% Generate a correct lqn file
%updateModel(sourcemodel, temppath, 'rv', rv);
%updateModel(temppath, temppath, 'st', st2);
%updateModel(temppath, temppath, 'np', np2);

updateModel(sourcemodel, temppath, 'nuser', 3000);


Cmax = sum(constraints.s_ub); %constraints.Q.*constraints.s_ub);

% fval = fitness(cpushare, sourcemodel, st, rv, model, params, Cmax);

tic()
f = @(x)fitness(x, sourcemodel, st, rv, model, params, Cmax);

options = optimoptions('ga'); % Load default settings
options = optimoptions(options,'PopulationType', 'doubleVector');
options = optimoptions(options,'PopulationSize', 50); % 50 is default
options = optimoptions(options,'MaxGenerations', 200); % 100*nvars is default (200)
options = optimoptions(options,'MaxStallGenerations', 50);
options = optimoptions(options,'MutationFcn', {  @mutationadaptfeasible 0.1 });
options = optimoptions(options,'PlotFcn', {@gaplotbestf, @gaplotbestindiv }); %@printState
options = optimoptions(options,'Display', 'iter');
[x, fval, exitflag, output, population, scores] = ga(f, model.N -1, [], [], [], [], constraints.s_lb, constraints.s_ub, [], [], options);
toc()