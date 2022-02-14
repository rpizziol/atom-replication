%load('../out/mat/sintest-b.mat');


saveAllPlots('b', '1');
%saveAllPlots('s');
%saveAllPlots('o');


function saveAllPlots(id, n)
    load(strcat('../out/mat/sintest-', id, '.mat'));
    savePlot(strcat(id, '-bestIndividuals', n), bestIndividuals);
    savePlot(strcat(id, '-bestTimeStamps', n), bestTimeStamps);
    savePlot(strcat(id, '-bestValues', n), bestValues);
    savePlot(strcat(id, '-nusersInTime', n), nusersInTime);
    savePlot(strcat(id, '-timeSlots', n), timeSlots);
end


function savePlot(plotName, variable)
    plot(variable);
    title(plotName);
    ax = gca;
    exportgraphics(ax, strcat('../out/plots/', plotName, '.jpg'));
end