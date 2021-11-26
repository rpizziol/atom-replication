clear

plotByThreads(30);
plotByClients(1000);

function plotByThreads(x_threads_max)
    % Prepare required arrays
    x_threads_step = x_threads_max/10;
    % Sampling threads array
    x_threads = (x_threads_step:x_threads_step:x_threads_max)';
    % Array of throughputs wrt to varying number of threads
    y_threads1 = zeros(10,1);
    
    % Vary the number of threads
    for i = 1:length(x_threads)
        y_threads1(i) = getThroughputTritask(1000, x_threads(i));
        fprintf("Step %i done\n", i)
    end
    disp("Matlab by number of threads done.");
    
    % Througputs obtained by means of DiffLQN
    y_threads1 = zeros(10,1);
    for i = 1:10
        index = i * 3;
        filename = strcat('../DiffLQN/csvs/tritask-qn-c1000-t', int2str(index), '.csv');
        csvMatrix = readmatrix(filename);
        y_threads1(i) = csvMatrix(4);
    end

    % Plot a comparison between DiffLQN and Matlab
    h = figure;
    plot(x_threads,y_threads1,x_threads,y_threads1); legend('DiffLQN', 'Matlab', 'Location', 'best'); grid on; xlabel('nThreads'); ...
        ylabel('throughput'); title('Comparison'); ylim([0, 1000]);
    print(h, './res/DiffLQNvsMatlab_ThroughputByThreads', '-dpng','-r400'); 
end

function plotByClients(x_clients_max)
    % Prepare required arrays
    x_clients_step = x_clients_max/10;
    % Sampling clients array
    x_clients = (x_clients_step:x_clients_step:x_clients_max)';
    % Array of throughputs wrt to varying number of clients
    y_clients1 = zeros(10,1);

    % Vary the number of clients
    for i = 1:length(x_clients)
        y_clients1(i) = getThroughputTritask(x_clients(i), 2);
        fprintf("Step %i done\n", i)
    end
    disp("Matlab by number of clients done.");

    % Througputs obtained by means of DiffLQN
    y_clients2 = zeros(10,1);
    for i = 1:10
        index = i * 100;
        filename = strcat('../DiffLQN/csvs/tritask-qn-c', int2str(index), '-t10.csv');
        csvMatrix = readmatrix(filename);
        y_clients2(i) = csvMatrix(4);
    end
    
    % Plot a comparison between DiffLQN and Matlab
    h = figure;
    plot(x_clients,y_clients2,x_clients,y_clients1); legend('DiffLQN', 'Matlab', 'Location', 'best'); grid on; xlabel('nClients'); ...
        ylabel('throughput'); title('Comparison');
    print(h, './res/DiffLQNvsMatlab_ThroughputByClients', '-dpng','-r400'); 
end