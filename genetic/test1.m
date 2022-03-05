
%% Run all browsing mix experiments (with nuser = 1000, 2000, 3000)
for i = 1:3
    % Browsing mix
    mix.name = 'browsing';
    mix.values = [0.63, 0.32, 0.05]; % Browsing mix values
    nuser = i*1000;
    timestamp = getTimeStamp();
    global testname
    testname = strcat(timestamp, mix.name, '-', int2str(nuser));
    runExperiment(mix.values, nuser);
end

% Get date and time in the string format: 'yyyymmdd-hhmm-'
function timestamp = getTimeStamp()
    c = clock;
    year = sprintf('%04d', c(1));
    month = sprintf('%02d', c(2));
    day = sprintf('%02d', c(3));
    hour = sprintf('%02d', c(4));
    minute = sprintf('%02d', c(5));
    timestamp = strcat(year, month, day, '-', hour, minute, '-');
end


% % N=@(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
% % start = tic();
% % 
% % for i = 1:5
% %     nuser = str2num(sprintf('%5.f',N(toc(start),1500,6000,1510)));
% %     runExperiment(mix.values, nuser);
% % end 







