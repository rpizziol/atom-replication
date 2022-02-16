function state = printState(options, state, flag)
    % Function called once for every generation to save the calculated data
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global start

    global wmname
    global currNuser
    
%     window = 600; % change nusers every 10 minutes

    %N = @(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
    %plot(N([0:600:6000],1500,6000,1510));


    
    fid = fopen('./res/atom-full_template6.lqnx'); 
    cellnow = textscan(fid,'%s',2,'headerlines', 3);
    fclose(fid);

    if(toc(start) > 600)
        state.StopFlag = 'y';
    end

    
    now = str2double(cellnow{1}{2});
%     timeSlot = floor(now / window); % Time sampled every 10 minutes
%     currTimeSlot = timeSlot*window;
    %currNuser = ;

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
%         timeSlots = [timeSlots; currTimeSlot];

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

