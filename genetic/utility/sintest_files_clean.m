load('sintest-o.mat');

cutoff = 152;

bestIndividuals = bestIndividuals(cutoff:end,:);
bestTimeStamps = bestTimeStamps(cutoff:end,:);
bestValues = bestValues(cutoff:end,:);
nusersInTime = nusersInTime(cutoff:end,:);
timeSlots = timeSlots(cutoff:end,:);

save('sintest-o.mat', 'bestIndividuals', 'bestTimeStamps', 'bestValues', ...
    'nusersInTime', 'timeSlots');

clear