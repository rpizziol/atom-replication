function state = printState(options, state, flag) %[state,options,optchanged] 
    %global allBest
    %allBest = [allBest; state.Best];
    disp('Best');
    disp(state.Best);
    disp('Population');
    disp(state.Population);
    disp('Selection');
    disp(state.Selection);
    disp('Expectation');
    disp(state.Expectation);
    disp('Score');
    disp(state.Score);
end

