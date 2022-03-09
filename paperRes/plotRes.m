load("allbest-3000b.mat")

figure('units','normalized','outerposition',[0 0 1 1])
stairs(bestTimeStamps,bestIndividuals(:,2),"linewidth",1.5)
set(gca,'FontSize',18)
box on
grid on
xlabel("Time (s)")
ylabel("#Cores")