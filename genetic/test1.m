% Browsing mix identifier
c = clock;
year = sprintf('%04d', c(1));
month = sprintf('%02d', c(2));
day = sprintf('%02d', c(3));
hour = sprintf('%02d', c(4));
minute = sprintf('%02d', c(5));
date = strcat(year, month, day, '-', hour, minute, '-');
mix.name = 'browsing';

global testname
testname = strcat(date, mix.name);

% Browsing mix values
mix.values = [0.63, 0.32, 0.05];

runExperiment(mix.values, 1000);