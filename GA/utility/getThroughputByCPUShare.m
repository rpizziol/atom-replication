function thr = getThroughputByCPUShare(cpushare, model)
%GETTHROUGHPUTBYCPUSHARE Summary of this function goes here
%   Detailed explanation goes here
    [np_final, st_final] = calculateByCPUShare(cpushare, model);
    filename = strcat("final-", model.name);
    filepath = strcat("./out/", filename, ".", model.extension);
    W = getCurrentUsers();
    updateModel(model.template_path, filepath, 'W', W);
    if (strcmp(model.name, 'sockshop'))
        workmix = getProbMix(model.wm);
        updateModel(tempPath, filepath, 'wm', workmix);
        rv = [W, W, W, W];
        updateModel(tempPath, filepath, 'rv', rv); % TODO add to acmeair too
    end  
    updateModel(filepath, filepath, 'st', st_final);
    updateModel(filepath, filepath, 'np', np_final);

    [status, ~] = system("lqns -x " + filepath);

    Xt = getXt(model, filename);
    thr = Xt(1,1);
    deleteXmlFiles(model, filename);
end

