function state = printState(options, state, flag) %[state,options,optchanged] 
    global allBest
    
%     disp('Best');
%     disp(state.Best);
%     disp('Population');
%     disp(state.Population);
%     disp('Score');
%     disp(state.Score);

    % Find the index of the 'Score' equal to 'Best'
    index = find(state.Score == state.Best);
    % Use that index to select the member of the population who had that
    bestIndividual = state.Population(index, :);
    disp(bestIndividual);
    allBest = [allBest; bestIndividual];
end

