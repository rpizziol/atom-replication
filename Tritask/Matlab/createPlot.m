function createPlot(x, y_DiffLQN, y_Matlab, x_label, filename)
    h = figure;
    plot(x, y_DiffLQN, x, y_Matlab, '--');
    legend('DiffLQN', 'Matlab', 'Location', 'best');
    grid on;
    xlabel(x_label);
    ylabel('throughput');
    title('Comparison');
    print(h, strcat('./res/', filename), '-dpng','-r400'); 
end

