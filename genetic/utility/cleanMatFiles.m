%load('sintest-o.mat');
clear

tname = '20220309-1838-ordering-2000';



load(strcat('../out/mat/', tname, '.mat'))
cutoff = 86;

bestIndividuals = bestIndividuals(cutoff:end,:);
bestTimeStamps = bestTimeStamps(cutoff:end,:);
bestValues = bestValues(cutoff:end,:);
nusersInTime = nusersInTime(cutoff:end,:);
%timeSlots = timeSlots(cutoff:end,:);

newfilename = strcat('../out/mat/', tname, '-clean.mat');

save(newfilename, 'bestIndividuals', 'bestTimeStamps', 'bestValues', ...
    'nusersInTime');

clear