clear all;

mixs = ['b', 'o', 's'];
users = [1000, 2000, 3000];

for i = 1:length(mixs)
    for j = 1:length(users)
            foldername = sprintf('%i-%s', users(j), mixs(i));
            filenames = dir(strcat('./', foldername, '/*.mat'));
            for k = 1:size(filenames, 1)
                trim_results(strcat('./', foldername, '/', filenames(k).name));
            end
    end
end

function trim_results(filename)
    load(filename);  
    cutoff = obtainCutOff(bestTimeStamps);
    if cutoff ~= 0
        bestIndividuals = bestIndividuals(cutoff:end,:);
        bestTimeStamps = bestTimeStamps(cutoff:end,:);
        bestValues = bestValues(cutoff:end,:);
        nusersInTime = nusersInTime(cutoff:end,:);
        save(filename, 'bestIndividuals', 'bestTimeStamps', 'bestValues', ...
        'nusersInTime', 'testname'); 
    end
end

function co = obtainCutOff(timeStamps)
    dts = diff(timeStamps);
    negPos = find(dts < 0);
    if isempty(negPos)
        co = 0;
    else
        co = negPos(end) + 1;
    end
end