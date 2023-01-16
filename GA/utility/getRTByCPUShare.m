function RT = getRTByCPUShare(cpushare, model)
uuid = char(matlab.lang.internal.uuid());
[np_final, st_final] = calculateByCPUShare(cpushare, model);
filename = sprintf("%s#%s#rt", getDateString(), uuid);
filepath = strcat("./out/", filename, ".", model.extension);

global currNuser
W = currNuser;

updateModel(model.template_path, filepath, 'W', W);
if (strcmp(model.name, 'sockshop'))
    workmix = getProbMix(model.wm);
    updateModel(filepath, filepath, 'wm', workmix);
    rv = [W, W, W, W];
    updateModel(filepath, filepath, 'rv', rv); % TODO add to acmeair too
end
updateModel(filepath, filepath, 'st', st_final);
updateModel(filepath, filepath, 'np', np_final);

%[status, ~] = system("lqns --schweitzer  --method-of-layers -x ./out/" + modelName + "." + model.extension);
[status, ~] = system("lqns --schweitzer  --method-of-layers -x " + filepath);

RT = getRt(model, filename);
deleteXmlFiles(model, filename);
end

