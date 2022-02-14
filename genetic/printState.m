function state = printState(options, state, flag)
    % Function called once for every generation to save the calculated data
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global timeSlots

    global start
    global currNuser
    
    window = 60; % change nusers every 10 minutes

    N = @(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
    %plot(N([0:600:6000],1500,6000,1510));

    
    now = toc(start);
    timeSlot = floor(now / window); % Time sampled every 10 minutes
    currTimeSlot = timeSlot*window;
    currNuser = floor(N(currTimeSlot, 150, 600, 1510));    

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
        timeSlots = [timeSlots; currTimeSlot];

        disp('bestIndividuals');
        disp(bestIndividuals);
        disp('bestValues');
        disp(bestValues);
        disp('bestTimeStamps');
        disp(bestTimeStamps);
        disp('nusersInTime');
        disp(nusersInTime);
        disp('timeSlots');
        disp(timeSlots);
        
    end
end

