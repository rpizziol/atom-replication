%load('../out/mat/sintest-b.mat');


saveAllPlots('b');
saveAllPlots('s');
saveAllPlots('o');


function saveAllPlots(id)
    load(strcat('../out/mat/sintest-', id, '.mat'));
    savePlot(strcat(id, '-bestIndividuals'), bestIndividuals);
    savePlot(strcat(id, '-bestTimeStamps'), bestTimeStamps);
    savePlot(strcat(id, '-bestValues'), bestValues);
    savePlot(strcat(id, '-nusersInTime'), nusersInTime);
    savePlot(strcat(id, '-timeSlots'), timeSlots);
end


function savePlot(plotName, variable)
    plot(variable);
    title(plotName);
    ax = gca;
    exportgraphics(ax, strcat('../out/plots/', plotName, '.jpg'));
end