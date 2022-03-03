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


%runExperiment(mix.values, 1000);

%N=@(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
%start = tic();

%for i = 1:5
    nuser = 1000; %sprintf('%5.f',N(toc(start),1500,6000,1510));
    runExperiment(mix.values, nuser);
%end















