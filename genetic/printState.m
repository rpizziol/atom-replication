function state = printState(options, state, flag)
    % Function called once for every generation to save the calculated data
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global start

    global wmname
    global currNuser
    
    %fid = fopen('./res/atom-full_template6.lqnx'); 
    %cellnow = textscan(fid,'%s',2,'headerlines', 3);
    %fclose(fid);

    now = toc(start);

    if(now > 600)
        state.StopFlag = 'y';
    end

    %now = str2double(cellnow{1}{2});

    % Find the index of the 'Score' equal to 'Best'
    if(size(state.Best) >= 1)
        index = find(state.Score == state.Best(end));
        % Use that index to select the member of the population who had that
        tmpBestIndividual = state.Population(index, :);
        bestIndividual = tmpBestIndividual(1, :);
        
        bestIndividuals = [bestIndividuals; bestIndividual];
        bestValues = [bestValues; state.Best(end)];
        bestTimeStamps = [bestTimeStamps; now];
        nusersInTime = [nusersInTime; currNuser];

        save(strcat('./out/mat/sintest-', wmname, '.mat'), 'bestIndividuals', ...
            'bestValues', 'bestTimeStamps', 'nusersInTime');

        disp('bestIndividuals');
        disp(bestIndividuals);
        disp('bestValues');
        disp(bestValues);
        disp('bestTimeStamps');
        disp(bestTimeStamps);
        disp('nusersInTime');
        disp(nusersInTime);
    end
end

