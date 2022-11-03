function runAllATOMExperiments(N, wm)
    if strcmp(wm, 'b')
        wmName = 'browsing';
        wmProbs = [0.63, 0.32, 0.05];
    elseif strcmp(wm, 'o')
        wmName = 'ordering';
        wmProbs = [0.33, 0.17, 0.50];
    elseif strcmp(wm, 's')
        wmName = 'shopping';
        wmProbs = [0.54, 0.26, 0.20];
    end
    
    runExperimentByMix(wmName, wmProbs, str2double(N));
    
    %clear
    %runExperimentByMix('browsing', [0.63, 0.32, 0.05], 1000);
    % clear
    % runExperimentByMix('browsing', [0.63, 0.32, 0.05], 2000);
    % clear
    % runExperimentByMix('browsing', [0.63, 0.32, 0.05], 3000);
    % clear
    % runExperimentByMix('shopping', [0.54, 0.26, 0.20], 1000);
    % clear
    % runExperimentByMix('shopping', [0.54, 0.26, 0.20], 2000);
    % clear
    % runExperimentByMix('shopping', [0.54, 0.26, 0.20], 3000);
    % clear
    % runExperimentByMix('ordering', [0.33, 0.17, 0.50], 1000);
    % clear
    % runExperimentByMix('ordering', [0.33, 0.17, 0.50], 2000);
    % clear
    % runExperimentByMix('ordering', [0.33, 0.17, 0.50], 3000);
    
    %% Run all nuser experiments of a given mix (with nuser = 1000, 2000, 3000)
    function runExperimentByMix(mixname, mixvalues, nuser)
        timestamp = getTimeStamp();
        global testname
        testname = strcat(timestamp, '-', mixname, '-', int2str(nuser));
        runExperiment(mixvalues, nuser);
    end
    
    %% Get date and time in the string format: 'yyyymmdd-hhmm'
    function timestamp = getTimeStamp()
        c = clock;
        year = sprintf('%04d', c(1));
        month = sprintf('%02d', c(2));
        day = sprintf('%02d', c(3));
        hour = sprintf('%02d', c(4));
        minute = sprintf('%02d', c(5));
        timestamp = strcat(year, month, day, '-', hour, minute);
    end
    
    
    % % N=@(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
    % % start = tic();
    % % 
    % % for i = 1:5
    % %     nuser = str2num(sprintf('%5.f',N(toc(start),1500,6000,1510)));
    % %     runExperiment(mix.values, nuser);
    % % end 

end






