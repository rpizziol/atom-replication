clear

x1 = (3:3:30)';       % x axis (sampling threads array)
x2 = (100:100:1000)'; % x axis (sampling clients array)

z1 = zeros(10,1);  % Array of throughputs wrt to varying number of threads
z2 = zeros(10,1);  % Array of throughputs wrt to varying number of clients

% Vary the number of threads
for i = 1:length(x1)
    z1(i) = getThroughput(1000, x1(i));
end

% Vary the number of clients
for i = 1:length(x2)
    z2(i) = getThroughput(x2(i), 10);
end

% Througputs obtained by means of DiffLQN
s2 = zeros(10,1);
for i = 1:10
    index = i * 100;
    filename = strcat('../DiffLQN/csvs/tritask-qn-c', int2str(index), '-t10.csv');
    csvMatrix = readmatrix(filename);
    s2(i) = csvMatrix(4);
end

% Througputs obtained by means of DiffLQN
s1 = zeros(10,1);
for i = 1:10
    index = i * 3;
    filename = strcat('../DiffLQN/csvs/tritask-qn-c1000-t', int2str(index), '.csv');
    csvMatrix = readmatrix(filename);
    s1(i) = csvMatrix(4);
end


% Plot a comparison between DiffLQN and Matlab
h = figure;
plot(x2,s2,x2,z2); legend('DiffLQN', 'Matlab'); grid on; xlabel('nClients'); ...
    ylabel('throughput'); title('Comparison');
print(h, './res/DiffLQNvsMatlab_ThroughputByClients', '-dpng','-r400'); 

h = figure;
plot(x1,s1,x1,z1); legend('DiffLQN', 'Matlab'); grid on; xlabel('nThreads'); ...
    ylabel('throughput'); title('Comparison'); ylim([0, 1000]);
print(h, './res/DiffLQNvsMatlab_ThroughputByThreads', '-dpng','-r400'); 


function T = getThroughput(nClients, NT_router)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of parameters

% Number of threads for each task
NT_froend = 10;
NT_catsvc = 7;

% Number of processor cores for each task
NC_router = 1;
NC_froend = 2;
NC_catsvc = 3;

% Number of initial free threads
NTF_router = NT_router;
NTF_froend = NT_froend;
NTF_catsvc = NT_catsvc;

S = [NT_router, NT_froend, NC_router, NC_froend, NT_catsvc, NC_catsvc];

% State vector (the queue length of each entry and task)
%           Xbro, Aadd,Ahom,  Acat, Acar, Xhom, Xcat, Xcar, Xadd (1:9)
X0 = [  nClients,    0,    0,    0,    0,    0,    0,    0,    0];
%        Alis, Aite, Xlis, Xite (10:13)
X0 = [X0,   0,    0,    0,    0];
%  (14:16)
X0 = [X0, NTF_router, NTF_froend, NTF_catsvc];
% Probabilities of routing to home/catalog/carts entries
P = [1/3, 1/3, 1/3];
% Probabilities of routing of list/item entries
P = [P, 1/2, 1/2];

% Service rates
mu_bro = 1; %/7.0e-3;
mu_add = 1/1.2e-3;
mu_hom = 1/2.1e-3;
mu_cat = 1/3.7e-3;
mu_car = 1/5.1e-3;
mu_lis = 1/2.2e-3;
mu_ite = 1/1.9e-3;

MU = [mu_bro, mu_add, mu_hom, mu_cat, mu_car, mu_lis, mu_ite];

TF = 0.1;       % Tempo fine
rep = 1000;      % Number of repetitions
dt = 10^-2; % Sampling step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run the simulation
X = AtomSimpleCRNTritask(X0, S, P, MU, TF, rep, dt);
Y = mean(X,9); % Mediate all simulations
T = mean(Y(1,end-100:end)); % Mediate the last 100 steps to obtain the steady state throughput
end