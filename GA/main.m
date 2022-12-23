addpath('./utility/');
addpath('./res/');
addpath('./apps/');

[model, params] = initializeSockShop('b');
%[model, params] = initializeAcmeAir();

runExperiment(model, params);
