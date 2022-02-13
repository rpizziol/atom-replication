function state = printState(options, state, flag)

    global start
    global bestValues
    global bestIndividuals
    global bestTimeStamps
    global nusersInTime
    global timeSlots
    global times

    global currNuser
    global currTimeSlot
    global currTime  

    N = @(t,mod,period,shift)sin(t/(period/(2*pi)))*mod+shift;
    %plot(N([0:600:6000],1500,6000,1510));

    window = 600; % change nusers every 10 minutes
    currTime = toc(start);
    timeSlot = floor(currTime / window); % Time sampled every 10 minutes
    nuser = floor(N(timeSlot*window, 1500, 6000, 1510));
    currNuser = nuser;
    currTimeSlot = timeSlot*window;




    % Find the index of the 'Score' equal to 'Best'
    if(size(state.Best) >= 1)
        index = find(state.Score == state.Best(end));
        % Use that index to select the member of the population who had that
        tmpBestIndividual = state.Population(index, :);
        bestIndividual = tmpBestIndividual(1, :);
        
        bestIndividuals = [bestIndividuals; bestIndividual];
        bestValues = [bestValues; state.Best(end)];
        bestTimeStamps = [bestTimeStamps; toc(start)];
        nusersInTime = [nusersInTime; currNuser];
        timeSlots = [timeSlots; currTimeSlot];
        times = [times; currTime];

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
        disp('times');
        disp(times);
    end
end

