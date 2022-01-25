sourcepath = './res/atom-full_template2.lqnx';
outpath = './out/atom-test.lqnx';

nclient = 3000;

np = [10, 10, 7, 225, 151, 100];
rv = [nclient, nclient, nclient, nclient];
st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
    0.0056];

updateModel(sourcepath, outpath, 'nuser', nclient);
updateModel(outpath, outpath, 'np', np);
updateModel(outpath, outpath, 'rv', rv);
updateModel(outpath, outpath, 'st', st);

%[status, ~] = system("cd out; lqns -x atom-test.lqnx");