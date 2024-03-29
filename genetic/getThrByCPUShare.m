function thr = getThrByCPUShare(cpushare, nuser, wm)
    %% Parse input
    if strcmp(wm, 'b')
        wmProbs = [0.63, 0.32, 0.05];
    elseif strcmp(wm, 'o')
        wmProbs = [0.33, 0.17, 0.50];
    elseif strcmp(wm, 's')
        wmProbs = [0.54, 0.26, 0.20];
    end
    st = [0.0012, 0.0021, 0.0037, 0.0051, 0.0022, 0.0019, 0.0048, ...
        0.0174, 0.0056];
    rv = [nuser, nuser, nuser, nuser];

    %% Update LQN model
    sourcemodel = './res/atom-full_template6.lqnx';
    temppath = './out/temp.lqnx';
    [np2, st2] = calculateByCPUShare(st, cpushare);
    updateModel(sourcemodel, temppath, 'nuser', nuser);
    updateModel(temppath, temppath, 'wm', wmProbs);
    updateModel(temppath, temppath, 'rv', rv);
    updateModel(temppath, temppath, 'st', st2);
    updateModel(temppath, temppath, 'np', np2);

    %% Solve model
    [~, ~] = system("cd out; lqns -x temp.lqnx");

    %% Obtain throughput
    xmlpath = './out/temp.lqxo';
    thr = str2double(getAttributeByEntry(xmlpath, 'EntryBrowse', ...
        'throughput'));
    disp(thr);
end