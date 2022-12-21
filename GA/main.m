addpath('./utility/');
addpath('./res/');
addpath('./apps/');

[model, params] = initializeSockShop();
wm = 'b';

runExperiment(wm, model, params);
