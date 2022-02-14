%load('../out/mat/sintest-b.mat');


saveAllPlots('o', '2');
%saveAllPlots('s');
%saveAllPlots('o');


function saveAllPlots(id, n)
    load(strcat('../out/mat/sintest-', id, '.mat'));
    savePlot(strcat(n, '/', id, '-bestIndividuals', n), bestIndividuals);
    savePlot(strcat(n, '/', id, '-bestTimeStamps', n), bestTimeStamps);
    savePlot(strcat(n, '/', id, '-bestValues', n), bestValues);
    savePlot(strcat(n, '/', id, '-nusersInTime', n), nusersInTime);
    %savePlot(strcat(n, '/', id, '-timeSlots', n), timeSlots);
end


function savePlot(plotName, variable)
    plot(variable);
    title(plotName);
    ax = gca;
    exportgraphics(ax, strcat('../out/plots/', plotName, '.jpg'));
end