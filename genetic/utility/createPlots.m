testname = '20220303-1223-browsing';


saveAllPlots(testname);

function saveAllPlots(testname)
    load(strcat('../out/mat/', testname, '.mat'));
    savePlot(testname, 'bestIndividuals', bestIndividuals);
    savePlot(testname, 'bestTimeStamps', bestTimeStamps);
    savePlot(testname, 'bestValues', bestValues);
    savePlot(testname, 'nusersInTime', nusersInTime);
end

function savePlot(foldername, plotName, variable)
    mkdir(strcat('../out/plots/', foldername));
    plot(variable);
    title(plotName);
    ax = gca;
    exportgraphics(ax, strcat('../out/plots/', foldername, '/', plotName, '.jpg'));
end