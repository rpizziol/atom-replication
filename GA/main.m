% Functions relative to the web application used
addpath('./apps/');
% Utility functions
addpath('./utility/');
% xml and lqn templates defining the models
addpath('./res/');

%[model, params] = initializeSockShop('b');
[model, params] = initializeAcmeAir();

runExperiment(model, params);
