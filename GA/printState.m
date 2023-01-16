% An output function called once at the end of each generation by the
% genetic algorithm. It saves the current state of the optimization (i.e.,
% the global variables) in a .mat file.
% INPUTS
%   options     : ...
%   state       : ...
%   flag        : ...
%   model       : A structure containing information about the model.
% OUTPUTS
%   state       : ...
%   options     : ...
%   optchanged  : ...
function [state, options, optchanged] = printState(options, state, flag, model)
    global bestIndividuals
    global bestThroughputs
    global bestValues
    global bestTimeStamps
    
    global nusersInTime
    global testname
    global start
    
    global currNuser

    global countIndividual
   
    optchanged = true;
    state.EvalElites=true;
    
    disp(flag)
    
    switch flag
        case 'init' % First iteration
            fprintf('\ninit\n')
            start = tic();
            countIndividual = 0; % Reset for the next generation
        case 'iter' % Middle iteration
            fprintf('\niter\n')
            now = toc(start);
            % Find the index of the 'Score' equal to 'Best'
            index = find(state.Score == state.Best(end), 1, 'last');
        
            % Use index to select the relative member of the population
            tmpBestIndividual = state.Population(index, :);
            bestIndividual = tmpBestIndividual(1, :);
            
            % Update state global variables
            bestIndividuals = [bestIndividuals; bestIndividual];
            %bestThroughputs = [bestThroughputs; getThroughputByCPUShare(bestIndividual, model)];
            bestValues = [bestValues; state.Best(end)];
            bestTimeStamps = [bestTimeStamps; now];
            nusersInTime = [nusersInTime; currNuser];
            
    
            % Update temporary .mat file
            save(strcat('./out/mat/', testname, '.mat'), 'bestIndividuals', ...
            'bestValues', 'bestTimeStamps', 'nusersInTime');
    
            % Update the new CPU-share in the application
            for i = 1:length(model.ms)
                updateShare(model.ms(i), bestIndividual(i), model.redisConn)
            end
    
            % Display current global variables (for debug)
            disp('bestIndividuals');
            disp(bestIndividuals(end,:));
%             disp('bestThroughputs');
%             disp(bestThroughputs(end,:));
            disp('bestValues');
            disp(bestValues(end,:));
            disp('bestTimeStamps');
            disp(bestTimeStamps(end,:));
            disp('nusersInTime');
            disp(nusersInTime(end,:));
            countIndividual = 0; % Reset for the next generation
            
            %save population
            pop=state.Population;
            save("init_pop.mat","pop");
            
        case 'done'
            disp('done')      
    end

    

    currNuser = getCurrentUsers(model.redisConn); % Update currNuser
end

