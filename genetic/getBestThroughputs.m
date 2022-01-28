global bestIndividuals

sourcemodel = './res/atom-full_template3.lqnx';
temppath = './out/thrtmp.lqnx';
nuser = 3000;
st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, 0.0174,...
0.0056];
rv = [nuser, nuser, nuser, nuser];

niter = size(bestIndividuals, 2);
bestThroughputs = zeros(niter, 1);

for i = 1:niter
    %% Generate lqnx file
    cpushare = bestIndividuals(i);
    updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'rv', rv);
    [np2, st2] = calculateByCPUShare(st, cpushare);
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);
    %% Calculate throughput of reference task
    [status, ~] = system("cd out; lqns -x thrtmp.lqnx");
    if status == 0 % no error
        xdoc = xmlread(temppath);
        entry = xdoc.getElementsByTagName('result-entry');
        thr = str2double(entry.item(0).getAttribute('throughput'));
    end
    %% Update the throughputs
    bestThroughputs(i) = thr;
end
save('allbest.mat', 'bestThroughputs', '-append');