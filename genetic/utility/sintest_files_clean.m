load('sintest-o.mat');

cutoff = 116;

bestIndividuals = bestIndividuals(cutoff:end,:);
bestTimeStamps = bestTimeStamps(cutoff:end,:);
bestValues = bestValues(cutoff:end,:);
nusersInTime = nusersInTime(cutoff:end,:);
times = times(cutoff:end,:);
timeSlots = timeSlots(cutoff:end,:);

save('sintest-o.mat', 'bestIndividuals', 'bestTimeStamps', 'bestValues', ...
    'nusersInTime', 'times', 'timeSlots');

clear