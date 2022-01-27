function state = printState(options, state, flag) %[state,options,optchanged] 
    global allBest
    allBest = [allBest; state.Best];
    %disp(state.Best);
    disp(state.Population(state.Selection));
end

