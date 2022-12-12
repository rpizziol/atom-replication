addpath('./utility/');

template = './res/acmeair-template.lqn';
tempfile = './out/acmeair-temp.lqn';

st0 = [0.2, 0.15, 0.08, 0.15, 0.2, 0.04, 0.1, 0.087, 0.09, 0.05];
nc = [2, 2, 1, 1, 2, 3, 1, 1, 1, 1];

% Update model with number of users and cores
updateModel(template, tempfile, 'st', st0);
updateModel(tempfile, tempfile, 'W', [1000]);
updateModel(tempfile, tempfile, 'nc', nc);

[status, ~] = system("lqns -x " + tempfile, '-echo');