addpath('./utility/');

template = './res/acmeair-template.lqn';
tempfile = './out/acmeair-temp.lqn';

st0 = [0.2, 0.15, 0.08, 0.15, 0.2, 0.04, 0.1, 0.087, 0.09, 0.05];
np = [2, 2, 1, 1, 2, 3, 1, 1, 1, 1];

% Update model with number of users and cores
updateModel(template, tempfile, 'st', st0);
updateModel(tempfile, tempfile, 'W', [1000]);
updateModel(tempfile, tempfile, 'np', np);

[status, ~] = system("lqns -x " + tempfile, '-echo');

% Calculate total time Acme Air

stAcme = [0.2738, 0.151, 0.0812, 0.1505, 0.2013, 0.0403, 0.1008, ...
        0.0876, 0.0908, 0.0504];
reps = [1, 1, 1, 2, 1, 4, 1, 2, 1, 4];

totTime = sum(stAcme .* reps); % = 1.7379