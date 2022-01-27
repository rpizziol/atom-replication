function state = printState(options, state, flag) %[state,options,optchanged] 
    global allBest
    allBest = [allBest, state.Best];
    disp(state.Best);
end

