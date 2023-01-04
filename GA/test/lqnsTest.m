addpath('../utility/');

template = '../res/acmeair-template.lqn';
tempfile = '../out/acmeair-temp2.lqn';

nusers = 1000;

% think time = 0.27538

stAcmeNew = [0.15673, 0.085154, 0.15428, 0.20552, 0.044829, 0.14698, ...
        0.0991, 0.095022, 0.052992];

np = [nusers, nusers, nusers, nusers, nusers, nusers, nusers, nusers, nusers];


updateModel(template, tempfile, 'st', stAcmeNew);
updateModel(tempfile, tempfile, 'W', [nusers]);
updateModel(tempfile, tempfile, 'np', np);

%[status, ~] = system("lqns -x " + tempfile, '-echo');


if (1 == 0)


st0 = [0.2, 0.15, 0.08, 0.15, 0.2, 0.04, 0.1, 0.087, 0.09, 0.05];
np = [2, 2, 1, 1, 2, 3, 1, 1, 1, 1];

% Update model with number of users and cores
updateModel(template, tempfile, 'st', st0);
updateModel(tempfile, tempfile, 'W', [nusers]);
updateModel(tempfile, tempfile, 'np', np);

[status, ~] = system("lqns -x " + tempfile, '-echo');

% Calculate total time Acme Air

stAcme = [0.2738, 0.151, 0.0812, 0.1505, 0.2013, 0.0403, 0.1008, ...
        0.0876, 0.0908, 0.0504];

% TODO metti questi nuovi valori

stAcmeNew = [0.27538, 0.15673, 0.085154, 0.15428, 0.20552, 0.044829, 0.14698, ...
        0.0991, 0.095022, 0.052992];

%"client"    "0.27538"

%"MSauth"    "0.15673"

    %"MSvalidateid"    "0.085154"

    %"MSviewprofile"    "0.15428"

    %"MSupdateprofile"    "0.20552"

   % "MSupdateMiles"    "0.044829"

   % "MSbookflights"    "0.14698"

    %"MScancelbooking"    "0.0991"

    %"MSqueryflights"    "0.095022"

    %"MSgetrewardmiles"    "0.052992"


%reps = [1, 1, 1, 2, 1, 4, 1, 2, 1, 4];

%totTime = sum(stAcme .* reps); % = 1.7379

%thr = nusers/totTime; % = 575.4071

cpu_share = [0.002, 0.001, 0.0074, 0.1164, 0.1366, 0.0709, 0.0635, ...
    0.001, 0.1006];
np = [1, 1, 1, 1, 1, 1, 1, 1, 1];
fact = np ./ cpu_share;
st1 = stAcme * fact;

% con 100 client
% 8.74618784884589,4.752017964866227,8.202189421916708,7.504977086493566,11.060518758601432,8.871612757577955,5.302686771579797,17.21949430386527,11.46916180620429
end