clear

mixs=["b","s","o"];
W=[3000,2000,1000];

optTime=[];
gaTime=[];

fontsize=50;

for l=1:length(mixs)
    mix=mixs(l);
    for g=1:length(W)
        optRes=load(sprintf('data/muopt_%d_%s.mat',W(g),mix));
        gaRes=load(sprintf('data/allbest-%d%s',W(g),mix));
        
        optTime=[optTime,optRes.stimes];
        gaTime=[gaTime,diff(gaRes.bestTimeStamps)'];
    end
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    histogram(gaTime,'Normalization','probability')
    set(gcf, 'color', [1 1 1])
    set(gca,'FontSize',fontsize)
    hold on
    grid on;
    box on;
    ylabel("Prob")
    xlabel("Time (s)")
    exportgraphics(gcf,sprintf("img/resGATime_%s.pdf",mix))
    close()
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    histogram(optTime,'Normalization','probability')
    set(gcf, 'color', [1 1 1])
    set(gca,'FontSize',fontsize)
    hold on
    grid on;
    box on;
    ylabel("Prob")
    xlabel("Time (s)")
    exportgraphics(gcf,sprintf("img/resOptTime_%s.pdf",mix))
    close()
    
    optTime=[];
    gaTime=[];
end