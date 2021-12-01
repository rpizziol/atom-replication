clear

x_clients_max = 1200;   % Maximum clients' value plotted
n_steps = 10;            % Number of steps of the sampling
TF = 10;                % Time frame
dt = 10^-2;             % Step size

x_clients_step = x_clients_max/n_steps;
x_clients = (x_clients_step:x_clients_step:x_clients_max)';

% Array of throughputs wrt to varying number of clients
y_Xbro = zeros(n_steps,1);

% Vary the number of clients
parfor i = 1:n_steps
    X = runTandemModel(x_clients(i), TF, dt);
    % Obtain the steady-state average value of the Xbro queue (throughput)
    lastSteps = (0.1*TF/dt); % Number of 10% steps
    % Mediate the last 10% steps to obtain the steady state throughput
    y_Xbro(i) = mean(X(1,end-lastSteps:end)); 
    fprintf("Step %i: cli = %5.f, thr = %5.f\n", i, x_clients(i), y_Xbro(i));
end
disp("Throughput by number of clients done.");
    
% --- PLOT ---
h = figure;
plot(x_clients, y_Xbro);
legend('Matlab', 'Location', 'best');
grid on;
xlabel('nClients');
ylabel('throughput');
ylim([0, x_clients_max]);
title('Xbro')
print(h, strcat('./res/Matlab_XbroThroughputByClients', int2str(x_clients_max)), '-dpng','-r400'); 
