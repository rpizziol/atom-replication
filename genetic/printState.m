function state = printState(options, state, flag) %[state,options,optchanged] 
    global allBest
    global start
    
%     disp('Best');
%     disp(state.Best);
%     disp('Population');
%     disp(state.Population);
%     disp('Score');
%     disp(state.Score);

    % Find the index of the 'Score' equal to 'Best'
    if(size(state.Best) >= 1)
        index = find(state.Score == state.Best(end));
    %     [~, p] = ismember(state.Score, state.Best, 'rows');
    %     index = find(p, 1);
        % Use that index to select the member of the population who had that
        bestIndividual = state.Population(index, :);
        disp(bestIndividual);
        allBest = [allBest; bestIndividual, state.Best(end), toc(start)];
    end
end

