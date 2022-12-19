[model, params] = initializeSockShop();
wm = 'b';

a = fitness([1, 2, 2, 1], wm, model, params);

disp(a);