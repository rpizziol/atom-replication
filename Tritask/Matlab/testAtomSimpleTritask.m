clear

plotByThreads(30, 10);
plotByClients(1000, 10);

% !!! Keep n_steps to 10 (DiffLQN scripts are fixed at 10)
function plotByThreads(x_threads_max, n_steps)
    % Prepare required arrays
    x_threads_step = x_threads_max/n_steps;
    % Sampling threads array
    x_threads = (x_threads_step:x_threads_step:x_threads_max)';
    % Array of throughputs wrt to varying number of threads
    y_Matlab = zeros(n_steps,1);
    
    % Vary the number of threads
    for i = 1:n_steps
        y_Matlab(i) = getThroughputTritask(1000, x_threads(i));
        fprintf("Step %i done\n", i)
    end
    disp("Matlab by number of threads done.");
    
    % Througputs obtained by means of DiffLQN
    y_DiffLQN = zeros(n_steps,1);
    for i = 1:n_steps
        index = i * x_threads_step;
        filename = strcat('../DiffLQN/csvs/',...
            'tritask-qn-c1000-t', int2str(index), '.csv');
        csvMatrix = readmatrix(filename);
        y_DiffLQN(i) = csvMatrix(4);
    end
    
    % Plot a comparison between DiffLQN and Matlab
    createPlot(x_threads, y_DiffLQN, y_Matlab, 'nThreads',...
        'DiffLQNvsMatlab_ThroughputByThreads')
end

% !!! Keep n_steps to 10 (DiffLQN scripts are fixed at 10)
function plotByClients(x_clients_max, n_steps)
    % Prepare required arrays
    x_clients_step = x_clients_max/n_steps;
    % Sampling clients array
    x_clients = (x_clients_step:x_clients_step:x_clients_max)';
    % Array of throughputs wrt to varying number of clients
    y_Matlab = zeros(n_steps,1);

    % Vary the number of clients
    for i = 1:n_steps
        y_Matlab(i) = getThroughputTritask(x_clients(i), 2);
        fprintf("Step %i done\n", i)
    end
    disp("Matlab by number of clients done.");

    % Througputs obtained by means of DiffLQN
    y_DiffLQN = zeros(n_steps,1);
    for i = 1:n_steps
        index = i * x_clients_step;
        filename = strcat('../DiffLQN/csvs/',...
            'tritask-qn-c', int2str(index), '-t10.csv');
        csvMatrix = readmatrix(filename);
        y_DiffLQN(i) = csvMatrix(4);
    end
    
    % Plot a comparison between DiffLQN and Matlab
    createPlot(x_clients, y_DiffLQN, y_Matlab, 'nClients',...
        'DiffLQNvsMatlab_ThroughputByClients')
end