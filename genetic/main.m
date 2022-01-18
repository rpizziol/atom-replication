clear

sourcemodel = './res/model1.lqn';
temppath = './out/temp1.lqn';

model.N = 3; % Number of microservices (tasks)
model.M = 3; % Number of classes (max entries)

%params.psi = rand(model.N, model.M); % Weights of transactions
params.psi = zeros(model.N, model.M); % Weights of transactions
params.psi(1,1) = 1;
params.tau1 = 0.5; % Objective function weight 1
params.tau2 = 0.5; % Objective function weight 2
%popSize = 20; % Starting population size of the genetic algorithm

% Constraints for r and s
constraints.Q = randi([2, 10], 1, model.N); % Max number of replicas for each microservice
% CPU share for each replica of each microservice for the time interval t
constraints.s_lb = randi([0, 200], 1, model.N); % Lower bound (0 - 0.2) * 1000
constraints.s_ub = randi([800, 1000], 1, model.N); % Upper bound (0.8 - 1.0) * 1000

% Arrays defined for functions testing
rv = [1000, 1000];
%np = [5, 3];
st = [0.0012, 0.0051, 0.0032, 0.0018];

cpushare = [0.5, 1];

[np2, st2] = calculateByCPUShare(st, cpushare);

% Generate a correct lqn file
updateModel(sourcemodel, temppath, 'rv', rv);
updateModel(temppath, temppath, 'st', st2);
updateModel(temppath, temppath, 'np', np2);

Cmax = sum(constraints.Q.*constraints.s_ub);

fval = solveModel('temp1', model, params, Cmax, rv, cpushare);
