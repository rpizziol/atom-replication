clear

mixs = ['b', 'o', 's'];
users = [1000, 2000, 3000];
format = 'png';
thinkTime = 7;

%% Preparatory work
workmixs = cell(1,9);
CPUs = zeros(2,9);
thrs = zeros(3,9);
times = zeros(1,9);

for i = 1:length(mixs)
    for j = 1:length(users)
        expId = j + 3*(i-1);
        workmixs{1, expId} = sprintf('%i-%s', users(j), mixs(i));

        % Load data
        optRes = load(sprintf('./data/muopt_%d_%s.mat', users(j), mixs(i)));
        gaRes = load(sprintf('./data/muopt_%d-%s-GA.mat', users(j), mixs(i)));

        % Steady state cumulative CPU-share
        CPUs(1, expId) = sum(optRes.NC(end, :)); % muOpt
        CPUs(2, expId) = sum(gaRes.NC(end, :));  % GA

        % Steady state throughput
        thrs(1, expId) = optRes.Tsim(end); % muOpt
        thrs(2, expId) = gaRes.Tsim(end);  % GA
        thrs(3, expId) = mean(optRes.w)/thinkTime; % TODO mean?

        % muOpt execution time
        times(1, expId) = mean(optRes.stimes);
    end
end


%% Total cpu share comparison graph
%generateComparisonBarPlot(CPUs, 'CPU share', sprintf('CPU-muOptvsGA.%s', format), workmixs)

%% Steady state time muOpt graph
%generateComparisonBarPlot(times, 'Execution time (s)', sprintf('time-muOpt.%s', format), workmixs)

%% Steady state throughput comparison graph
generateComparisonBarPlot(thrs, 'Throughput (req/s)', sprintf('thr-muOptvsGA.%s', format), workmixs)

%% Function for output barplots
function generateComparisonBarPlot(ydata, yname, filename, workmixs)
    % x and y data
    x = categorical(workmixs);
    x = reordercats(x, workmixs);
    y = ydata;

    if size(ydata, 1) == 1 % time
        bar(x, y, 0.5);
        legend('\muOpt');
    elseif size(ydata, 2) == 1 % CPU
        bar(x, y, 1);
        legend('\muOpt', 'GA');
    else % thr
        bar(x, y, 1);
        legend('\muOpt', 'GA', 'Req');
    end

    % Labels and legend
    ylabel(yname);
    xlabel('Work mix')
    %line(xlim, [50, 50], 'Color', 'm', 'LineWidth', 2);
    
    % Export graph
    %exportgraphics(gcf,sprintf('img/%s', filename))
    %close()
end