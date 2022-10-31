clear

execTimes = [];      % Array of total execution times
optConfigs = [];    % Array of optimal configurations

filenames = dir('../out/mat/1000-s/*.mat');

for i = 1:size(filenames, 1)
    load(strcat('../out/mat/1000-s/', filenames(i).name));
    execTimes = [execTimes; bestTimeStamps(end)];
    optConfigs = [optConfigs; bestIndividuals(end, :)];
end

cpuShare = sum(optConfigs,2);

disp('execTimes');
disp(execTimes);
disp('optConfigs');
disp(optConfigs);
disp('cpuShare');
disp(cpuShare);


x = execTimes;
SEM = std(x)/sqrt(length(x));               % Standard Error
ts = tinv([0.05  0.95],length(x)-1);      % T-Score
CI = mean(x) + ts*SEM;                      % Confidence Intervals
