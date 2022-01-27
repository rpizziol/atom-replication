function state = printState(options, state, flag) %[state,options,optchanged] 
    global allBest
    
%     disp('Best');
%     disp(state.Best);
%     disp('Population');
%     disp(state.Population);
%     disp('Score');
%     disp(state.Score);

    % Find the index of the 'Score' equal to 'Best'
    [~, p] = ismember(state.Score, state.Best, 'rows');
    index = find(p, 1);
    % Use that index to select the member of the population who had that
    bestIndividual = state.Population(index, :);
    disp(bestIndividual);
    allBest = [allBest; bestIndividual];
end

