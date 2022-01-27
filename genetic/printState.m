function [state,options,optchanged] = printState(options, state, flag)
    global allBest
    allBest = [allBest; state.Best];
    %disp(state.Best);
end

