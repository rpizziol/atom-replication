clear

x1 = (3:3:30)';       % x axis (sampling threads array)
x2 = (100:100:1000)'; % x axis (sampling clients array)

z1 = zeros(10,1); % Array of throughputs wrt to varying number of threads
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
    filename = strcat('../DiffLQN/tandem-qn-c', int2str(index), '-t10.csv');
    csvMatrix = readmatrix(filename);
    s2(i) = csvMatrix(4);
end

% Througputs obtained by means of DiffLQN
s1 = zeros(10,1);
for i = 1:10
    index = i * 3;
    filename = strcat('../DiffLQN/tandem-qn-c1000-t', int2str(index), '.csv');
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

% Number of processor cores for each task
NC_router = 1;

S = [NT_router, NC_router];

% State vector (the queue length of each entry and task)
%           Xbro, Aadd, Xadd
X0 = [  nClients,    0,   0];

% Service rates
mu_bro = 1; %/7.0e-3;
mu_add = 1/1.2e-3;

MU = [mu_bro, mu_add];

TF = 10;       % Tempo fine
rep = 1000;    % Number of repetitions
dt = 10^-2;    % Sampling step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run the simulation
X = AtomSimpleCRN(X0, S, MU, TF, rep, dt);
Y = mean(X,3); % Mediate all simulations
%plot(Y(1,:)) % Plot throughput of the tandem network
T = mean(Y(1,end-100:end)); % Mediate the last 100 steps to obtain the steady state throughput
end