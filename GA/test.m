addpath('./utility/');
addpath('./res/');

[model, params] = initializeSockShop();
wm = 'b';

a = fitness([1.5, 2.8, 2.6, 1.9], wm, model, params);

disp(a);