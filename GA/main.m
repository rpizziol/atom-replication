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
    global init_pop;
    init_pop=-1;
    delete init_pop.mat
    [model, params] = initializeAcmeAir();
    runExperiment(model, params);
elseif(code==3)
    %to complete
    global init_pop;
    delete init_pop.mat
    while(true)
        if isfile("tweet_pop.mat")
            init_pop=load("tweet_pop.mat");
        else
            init_pop=-1;
        end
        [model, params] = initializeAcmeAir();
        runExperiment2(model, params);
    end
end
end