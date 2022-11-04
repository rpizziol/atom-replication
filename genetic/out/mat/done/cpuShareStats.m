clear

mixs = ['b', 'o', 's'];
users = [1000, 2000, 3000];
nexperiments = length(mixs) * length(users); % Types of experiments

maxCpu = zeros(1, nexperiments);
avgCpu = zeros(1, nexperiments);
minCpu = zeros(1, nexperiments) + 30;
workmixs = cell(1,nexperiments);
avgTime = zeros(1, nexperiments);
thrs = zeros(1, nexperiments);

for i = 1:length(mixs)
    for j = 1:length(users)
        expId = j + 3*(i-1);
        workmixs{1, expId} = sprintf('%i-%s', users(j), mixs(i));
        foldername = sprintf('%i-%s', users(j), mixs(i));
        disp(foldername);
        filenames = dir(strcat('./', foldername, '/*.mat'));
        sumavg = 0;
        sumtimes = 0;
        sumthr = 0;
        for k = 1:size(filenames, 1)
            load(strcat('./', foldername, '/', filenames(k).name));
            cumsum = sum(bestIndividuals(end,:));
            % Update maximum value
            if cumsum > maxCpu(expId) 
                maxCpu(expId) = cumsum;
            end
            % Update minimum value
            if cumsum < minCpu(expId) 
                minCpu(expId) = cumsum;
            end
            % Update average
            sumavg = sumavg + cumsum;
            sumtimes = sumtimes + bestTimeStamps(end, :);
            sumthr = sumthr + getThrByCPUShare(bestIndividuals(end,:), ...
                users(j), mixs(i));

        end
        avgCpu(expId) = sumavg / size(filenames, 1);
        avgTime(expId) = sumtimes / size(filenames, 1);
        thrs(expId) = sumthr / size(filenames, 1);
    end
end

%% Generate barplot

x = categorical(workmixs);
x = reordercats(x, workmixs);    
bar(x, avgCpu);    
hold on
er = errorbar(x, avgCpu, minCpu, maxCpu);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';   
hold off

function thr = getThrByCPUShare(cpushare, nuser, wm)
    %% Parse input
    if strcmp(wm, 'b')
        wmProbs = [0.63, 0.32, 0.05];
    elseif strcmp(wm, 'o')
        wmProbs = [0.33, 0.17, 0.50];
    elseif strcmp(wm, 's')
        wmProbs = [0.54, 0.26, 0.20];
    end
    st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, ...
        0.0174, 0.0056];
    rv = [nuser, nuser, nuser, nuser];

    %% Update LQN model
    sourcemodel = './res/atom-full_template6.lqnx';
    temppath = './out/temp.lqnx';
    [np2, st2] = calculateByCPUShare(st, cpushare);
    updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'wm', wmProbs);
    updateModel(temppath, temppath, 'rv', rv);
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);

    %% Solve model
    [~, ~] = system("cd out; lqns -x temp.lqnx");

    %% Obtain throughput
    xmlpath = './out/temp.lqxo';
    thr = str2double(getAttributeByEntry(xmlpath, 'EntryBrowse', ...
        'throughput'));
end
