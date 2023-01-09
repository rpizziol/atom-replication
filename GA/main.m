function main(code)% Functions relative to the web application used
    
    rng('shuffle');

    addpath('./apps');
    % Utility functions
    addpath('./utility');
    addpath('./utility/dbs');
    % xml and lqn templates defining the models
    addpath('./res');
    % Redis
    %addpath('/root/git/MatlabRedis');       
    
    if (code == 1) % Sock Shop
        [model, params] = initializeSockShop('b');
        runExperiment(model, params);
    elseif(code == 2) % Acme Air
        [model, params] = initializeAcmeAir();
        runExperiment(model, params);
    end
end