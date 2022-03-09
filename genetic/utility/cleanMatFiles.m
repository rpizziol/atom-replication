%load('sintest-o.mat');
clear

tname = '20220307-2300-shopping-3000';



load(strcat('../out/mat/', tname, '.mat'))
cutoff = 154;

bestIndividuals = bestIndividuals(cutoff:end,:);
bestTimeStamps = bestTimeStamps(cutoff:end,:);
bestValues = bestValues(cutoff:end,:);
nusersInTime = nusersInTime(cutoff:end,:);
%timeSlots = timeSlots(cutoff:end,:);

newfilename = strcat('../out/mat/', tname, '-clean.mat');

save(newfilename, 'bestIndividuals', 'bestTimeStamps', 'bestValues', ...
    'nusersInTime');

clear