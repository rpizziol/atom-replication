function main(code)% Functions relative to the web application used
    addpath('./apps/');
    % Utility functions
    addpath('./utility/');
    % xml and lqn templates defining the models
    addpath('./res/');
    
    if (code == 1)
        [model, params] = initializeSockShop('b');
    elseif (code == 2)
        [model, params] = initializeAcmeAir();
    end

    runExperiment(model, params);
end