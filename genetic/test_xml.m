sourcepath = './res/atom-full_template3.lqnx';
outpath = './out/atom-test4.lqnx';

nclient = 3000;


st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
    0.0056];

cpushare = [0.7333,    1.5276,    0.4644,    0.3570];%[0.568607,  1.2367,   0.335931,  0.253524];
[np_new, st_new] = calculateByCPUShare(st, cpushare);

%rv = [10, 10, 7, 225, 151, 100];
np = [1, 2, 3, 1, 1, 1];
rv = [nclient, nclient, nclient, nclient];
% st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
%     0.0056];

updateModel(sourcepath, outpath, 'nuser', nclient);
updateModel(outpath, outpath, 'np', np_new);
updateModel(outpath, outpath, 'rv', rv);
updateModel(outpath, outpath, 'st', st_new);

%[status, ~] = system("cd out; lqns -x atom-test.lqnx");