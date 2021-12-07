clear

x_clients_max = 1000;   % Maximum clients' value plotted
n_steps = 5;            % Number of steps of the sampling
TF = 100;               % Time frame
dt = 10^-2;             % Step size

x_clients_step = x_clients_max/n_steps;
x_clients = (x_clients_step:x_clients_step:x_clients_max)';

% Array of throughputs wrt to varying number of clients
y_Xbro = zeros(n_steps,1);

% Vary the number of clients
parfor i = 1:n_steps % Parallel implementation
%for i = n_steps:-1:1   % Sequential implementation
    X = runTritaskModel(x_clients(i), TF, dt);
    % Obtain the steady-state average value of the Xbro queue (throughput)
    lastSteps = (0.1*TF/dt); % Number of 10% steps
    % Mediate the last 10% steps to obtain the steady state throughput
    y_Xbro(i) = mean(X(1,end-lastSteps:end));
    fprintf("Step %i: cli = %5.f, thr = %5.f\n", i, x_clients(i), y_Xbro(i));
end                     
disp("Throughput by number of clients done.");


% --- DiffLQN IMPLEMENTATION ---
% (Run DiffLQN separately, retreive data from csvs here)
filename = strcat('../DiffLQN/csvs/max', int2str(x_clients_max), 'steps',...
    int2str(n_steps), '.csv');
csvMatrix = readmatrix(filename);
y_DiffLQN = csvMatrix(:, 2);


% TODO add plot in case DiffLQN version is not available
% --- PLOT ---
h = figure;
plot(x_clients, y_Xbro, x_clients, y_DiffLQN, '--');
%plot(x_clients, y_Xbro);
legend('Matlab', 'DiffLQN', 'Location', 'best');
%legend('Matlab', 'Location', 'best');
grid on;
xlabel('nClients');
ylabel('throughput');
ylim([0, x_clients_max]);
title('Xbro')
print(h, strcat('./res/max', int2str(x_clients_max), 'steps', int2str(n_steps)), '-dpng','-r400'); 
