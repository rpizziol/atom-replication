% Browsing mix

c = clock;
year = sprintf('%04d', c(1));
month = sprintf('%02d', c(2));
day = sprintf('%02d', c(3));
hour = sprintf('%02d', c(4));
minute = sprintf('%02d', c(5));
date = strcat(year, month, day, '-', hour, minute, '-');

mix.name = 'browsing';
mix.values = [0.63, 0.32, 0.05];

testname = strcat(date, mix.name);

runExperiment(testname, mix.values, 1000);