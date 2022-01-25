sourcepath = './res/atom-full_template.lqnx';
outpath = './out/atom-test.lqnx';

np = [10, 10, 7, 225, 151, 100];
rv = [1000, 1000, 1000, 1000, 1000, 1000];
st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
    0.0056, 0.0013, 0.0022];

updateModel(sourcepath, outpath, 'nuser', (3000));
updateModel(outpath, outpath, 'np', np);
updateModel(outpath, outpath, 'rv', rv);
updateModel(outpath, outpath, 'st', st);

[status, ~] = system("cd out; lqns -x atom-test.lqnx");