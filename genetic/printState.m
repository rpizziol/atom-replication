function state = printState(options, state, flag)
    global allBest
    allBest = [allBest; state.Best];
    %disp(state.Best);
end

