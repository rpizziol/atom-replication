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

        disp(bestIndividuals);
        disp(bestValues);
        disp(bestTimeStamps);
        disp(nusersInTime);
        disp(timeSlots);
        disp(times);
    end
end

