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
    init=[3.6572    1.8773    3.5825    2.7341    5.0964    3.1551    2.0323    6.4983    4.3805];
    while(true)
        if isfile("init_pop.mat")
            init_pop=load("init_pop.mat");
        else
            disp("generiting intial pop")
            init_pop=struct("pop",max(ones(50,9).*init+randn(50,9),0.1));
        end
        [model, params] = initializeAcmeAir();
        runExperiment2(model, params);
    end
end
end