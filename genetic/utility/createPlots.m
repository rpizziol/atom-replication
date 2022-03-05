clear

testname = '20220304-1614-browsing';

saveAllPlots(testname);

% Run savePlot for each variable in the experiment
function saveAllPlots(testname)
    load(strcat('../out/mat/', testname, '.mat'));
    savePlot(testname, 'bestIndividuals', bestTimeStamps, bestIndividuals);
    %savePlot(testname, 'bestTimeStamps', bestTimeStamps);
    savePlot(testname, 'bestValues', bestTimeStamps, bestValues);
    savePlot(testname, 'nusersInTime', bestTimeStamps, nusersInTime);
end

% Save a plot of a specific variable in the experiment folder
function savePlot(foldername, plotName, x, y)
    mkdir(strcat('../out/plots/', foldername));
    plot(x, y);
    title(plotName);
    ax = gca;
    ax.XAxis.Exponent = 0; % Remove scientific notation
    exportgraphics(ax, strcat('../out/plots/', foldername, '/', plotName, '.png'));
end