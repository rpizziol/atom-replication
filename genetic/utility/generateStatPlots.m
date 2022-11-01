clear

mixs = ['b', 'o', 's'];
users = [1000, 2000, 3000];
nexperiments = length(mixs) * length(users); % Types of experiments

%% Obtain statistics for all experiments
statsExp = cell(1, nexperiments);
for i = 1:length(mixs)
    for j = 1:length(users)
        expId = j + 3*(i-1);
        statsExp{1, expId} = ...
            statsExperiment(sprintf('%i-%s', users(j), mixs(i)));
    end
end

%% Prepare data for the barplots
resExecTime = prepareTimeDataForBarPlot(statsExp);

%% Generate barplots
generateErrBarPlot(resExecTime);

%% Functions
function generateErrBarPlot(res)
    x = categorical(res.workmixs);
    x = reordercats(x, res.workmixs);    
    bar(x, res.data);    
    hold on
    er = errorbar(x, res.data, res.errlow, res.errhigh);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';   
    hold off
end



function res = prepareTimeDataForBarPlot(statsExp)
    % TODO code duplication
    mixs = ['b', 'o', 's'];
    users = [1000, 2000, 3000];

    res.data = [];
    res.errlow = [];
    res.errhigh = [];
    res.workmixs = cell(1,size(statsExp,2));
    for i = 1:length(mixs)
        for j = 1:length(users)
            expId = j + 3*(i-1);
            res.data = [res.data, statsExp{1, expId}.avgExecTime];
            res.errlow = [res.errlow, statsExp{1, expId}.ciExecTime(1)];
            res.errhigh = [res.errhigh, statsExp{1, expId}.ciExecTime(2)];
            res.workmixs{1, expId} = sprintf('%i-%s', users(j), mixs(i));
        end
    end
    res.data = seconds(res.data);
    res.errlow = seconds(res.errlow);
    res.errhigh = seconds(res.errhigh);

    res.data.Format = 'hh:mm';
    res.errlow.Format = 'hh:mm';
    res.errhigh.Format = 'hh:mm';
end

function res = statsExperiment(folderName)
    res.name = folderName;
    execTimes = [];     % Array of total execution times
    optConfigs = [];    % Array of optimal configurations
    
    filenames = dir(strcat('../out/mat/', folderName, '/*.mat'));
    
    for i = 1:size(filenames, 1)
        load(strcat('../out/mat/', folderName, '/', filenames(i).name));
        execTimes = [execTimes; bestTimeStamps(end)];
        optConfigs = [optConfigs; bestIndividuals(end, :)];
    end
    
    cpuShare = sum(optConfigs,2);

    % Means
    res.avgCpuShare = mean(cpuShare);    
    res.avgExecTime = mean(execTimes);

    % Confidence intervals
    res.ciCpuShare = confInt(cpuShare, 0.95);
    res.ciExecTime = confInt(execTimes, 0.95);
end


% Calculate p confidence interval
function CI = confInt(x, p)
    SEM = std(x)/sqrt(length(x));    % Standard Error
    ts = tinv([1-p  p],length(x)-1); % T-Score
    CI = mean(x) + ts*SEM;           % Confidence Intervals
end


