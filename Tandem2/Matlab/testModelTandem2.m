clear

% --------------------------------------------
% --- PLOT THROUGHPUT BY NUMBER OF CLIENTS ---
% --------------------------------------------

% --- PARAMETERS DEFINITION ---
x_clients_max = 1000;   % Maximum clients' value plotted
n_steps = 10;           % Number of steps of the sampling
x_clients_step = x_clients_max/n_steps;
% Sampling clients array
x_clients = (x_clients_step:x_clients_step:x_clients_max)';
    
% --- MATLAB IMPLEMENTATION ---
% Array of throughputs wrt to varying number of clients
y_Matlab = zeros(n_steps,1);

% Vary the number of clients
parpool(2)
parfor i = 1:n_steps    
    dt = 10^-2;
    TF = 10;
    X = runModelTandem2(x_clients(i), dt, TF);
    Y = mean(X,3); % Mediate all repetitions (simulations)
    lastSteps = (0.1*TF/dt); % How many are the last 10% steps?
    y_Matlab(i) = mean(Y(1,end-lastSteps:end)); % Mediate the last 10% steps to obtain the steady state throughput
    fprintf("Step %i done\n", i);
end
disp("Matlab by number of clients done.");
    
    
% --- PLOT       ---
% Plot a comparison between DiffLQN and Matlab
h = figure;
plot(x_clients, y_Matlab);
legend('Matlab', 'Location', 'best');
grid on;
xlabel('nClients');
ylabel('throughput');
ylim([0, x_clients_max]);
title('Xtka')
print(h, './res/Matlab_XtkaThroughputByClients', '-dpng','-r400'); 
