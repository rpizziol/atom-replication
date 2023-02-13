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

global init_pop;

if (code == 1) % Sock Shop
    [model, params] = initializeSockShop('b');
    runExperiment(model, params);
elseif(code == 2) % Acme Air
    
    init_pop=-1;
    delete init_pop.mat
    [model, params] = initializeAcmeAir();
    runExperiment(model, params);
elseif(code==3)
    delete init_pop.mat
    while(true)
        if isfile("init_pop.mat")
            init_pop=load("init_pop.mat");
        else
            if isfile("tweet_pop.mat")
                disp("loading tweetpop")
                init_pop=load("tweet_pop.mat");
            else
                init_pop=-1;
            end
        end
        [model, params] = initializeAcmeAir();
        runExperiment2(model, params);
    end
end
end