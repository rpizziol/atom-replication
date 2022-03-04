testname = '20220302-1759-browsing'; %

saveAllPlots(testname);

% Run savePlot for each variable in the experiment
function saveAllPlots(testname)
    load(strcat('../out/mat/', testname, '.mat'));
    savePlot(testname, 'bestIndividuals', bestIndividuals);
    savePlot(testname, 'bestTimeStamps', bestTimeStamps);
    savePlot(testname, 'bestValues', bestValues);
    savePlot(testname, 'nusersInTime', nusersInTime);
end

% Save a plot of a specific variable in the experiment folder
function savePlot(foldername, plotName, variable)
    mkdir(strcat('../out/plots/', foldername));
    plot(variable);
    title(plotName);
    ax = gca;
    exportgraphics(ax, strcat('../out/plots/', foldername, '/', plotName, '.jpg'));
end