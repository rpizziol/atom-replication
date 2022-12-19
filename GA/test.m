addpath('./utility/');
addpath('./res/');

[model, params] = initializeSockShop();
wm = 'b';


runExperiment(wm, model, params);
%a = fitness([1.5, 2.8, 2.6, 1.9], wm, model, params);

%disp(a);