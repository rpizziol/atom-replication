function state = printState(options, state, flag,model)
    % Function called once for every generation to save the calculated data
    % from global variables to .mat files.
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global start

    global currNuser

    % Name of the file where the results of the test will be saved
    global testname

    global countIndividual
    
    %fid = fopen('./res/atom-full_template6.lqnx'); 
    %cellnow = textscan(fid,'%s',2,'headerlines', 3);
    %fclose(fid);

    

%     Terminate execution after 10 minutes
%     if(now > 600)
%         state.StopFlag = 'y';
%     end

    

    countIndividual = 0;


    % Find the index of the 'Score' equal to 'Best'
    if(size(state.Best) == 0) % First iteration
        start = tic();
    else
    %if(size(state.Best) >= 1)
        now = toc(start);
        index = find(state.Score == state.Best(end));
        % Use that index to select the member of the population who had that
        tmpBestIndividual = state.Population(index, :);
        bestIndividual = tmpBestIndividual(1, :);
        
        bestIndividuals = [bestIndividuals; bestIndividual];
        bestValues = [bestValues; state.Best(end)];
        bestTimeStamps = [bestTimeStamps; now];
        nusersInTime = [nusersInTime; currNuser];

        save(strcat('./out/mat/', testname, '.mat'), 'bestIndividuals', ...
        'bestValues', 'bestTimeStamps', 'nusersInTime');

        %qui l'attuazione del nuovo cpushare del numero di server
        %disp(model.ms);
        for i=1:length(model.ms)
            updateShare(model.ms(i),bestIndividual(i),model.redisConn)
        end

        disp('bestIndividuals');
        disp(bestIndividuals(end,:));
        disp('bestValues');
        disp(bestValues(end,:));
        disp('bestTimeStamps');
        disp(bestTimeStamps(end,:));
        disp('nusersInTime');
        disp(nusersInTime(end,:));
        
    end
end

