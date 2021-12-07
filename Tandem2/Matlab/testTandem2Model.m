clear

x_clients_max = 1000;   % Maximum clients' value plotted
n_steps = 5;            % Number of steps of the sampling
TF = 10;                % Time frame
dt = 10^-2;             % Step size

x_clients_step = x_clients_max/n_steps;
x_clients = (x_clients_step:x_clients_step:x_clients_max)';

% Array of throughputs wrt to varying number of clients
y_Xtka = zeros(n_steps,1);
y_Xtb1 = zeros(n_steps,1);
y_Xtb2 = zeros(n_steps,1);

% Vary the number of clients
parfor i = 1:n_steps % Parallel implementation
%for i = n_steps:-1:1   % Sequential implementation
    X = runTandem2Model(x_clients(i), TF, dt);
    % Obtain the steady-state average value of the Xbro queue (throughput)
    lastSteps = (0.1*TF/dt); % Number of 10% steps
    % Mediate the last 10% steps to obtain the steady state throughput
    y_Xtka(i) = mean(X(1,end-lastSteps:end));
    y_Xtb1(i) = mean(X(4,end-lastSteps:end));
    y_Xtb2(i) = mean(X(5,end-lastSteps:end));
    fprintf("Step %i: cli = %5.f, thr = %5.f, Xtb1 = %5.f, Xtb2 = %5.f,\n",...
        i, x_clients(i), y_Xtka(i), y_Xtb1(i), y_Xtb2(i));
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
plot(x_clients, y_Xtka, x_clients, y_DiffLQN, '--');
%plot(x_clients, y_Xtka);
legend('Matlab', 'DiffLQN', 'Location', 'best');
grid on;
xlabel('nClients');
ylabel('throughput');
ylim([0, x_clients_max]);
title('Xtka')
print(h, strcat('./res/max', int2str(x_clients_max), 'steps', int2str(n_steps)), '-dpng','-r400'); 
