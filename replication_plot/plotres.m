clear

datadir="/Users/emilio-imt/git/nodejsMicro/data/revision2/ctrl/data";

colorOrange = [0.85,0.33,0.10];
colorBlue = [0.00,0.45,0.74];

% exps=["sin","step","twitter","wc98"];

nrepGA=31;
nrepMU=15;

%{
exps=["sin", "step"];
maxTime = 2000;
%}

exps=["sin","step"];
maxTime = 2000;



for ex=1:length(exps)
    lim=[0,2000];

    ctrlGA=zeros(maxTime,11,nrepGA);
    ctrlMU=zeros(maxTime,11,nrepMU);
    gaT=zeros(size(ctrlGA,1),size(ctrlGA,3));
    muT=zeros(size(ctrlMU,1),size(ctrlMU,3));
    gadata=[];
    mudata=[];
    valdata=[];

    valT=[];
    gaRT=[];
    muRT=[];
    valRT=[];

    fontSize=52;
    expWork=exps(1,ex);
    expnameMu=sprintf("julia_%s",expWork);
    expnameAtom=sprintf("atom_%s",expWork);

    gaObj=zeros(size(ctrlGA,1),size(ctrlGA,3));
    muObj=zeros(size(ctrlMU,1),size(ctrlMU,3));

    %load ga data
    for i=1:size(ctrlGA,3)
        ctrlGA(:,:,i)=readmatrix(sprintf("%s/%s_%d/ctrldata.csv",datadir,expnameAtom,i-1));
        gadata=[gadata;readData(sprintf("%s/%s_%d/*.csv",datadir,expnameAtom,i-1))];

        gaRT=[gaRT;gadata(end).rt];
        %gaT=[gaT;gadata(end).tr'];
        gaT(:,i)=gadata(end).tr(1:size(ctrlGA,1));

        nanCountGA=sum(isnan(ctrlGA(:,3:end,i)));
        ctrlGA(:,3:end,i)=fillmissing(ctrlGA(:,3:end,i),'constant',ctrlGA(nanCountGA+1:nanCountGA+1,3:end,i));
    end

    %compute CI for gacontrol
    ctrlGACI=zeros(size(ctrlGA,1),2);
    for i=1:size(ctrlGA,1)
        datai=squeeze(sum(ctrlGA(i,3:end,:),2));
        ctrlGACI(i,:) = getCI(datai);
    end

    %compute CI for gaT
    gaTCI=zeros(size(gaT,1),2);
    for i=1:size(ctrlGA,1)
        gaTCI(i,:) = getCI(gaT(i,:));
    end


    %load muOpt data
    for i=1:size(ctrlMU,3)
        ctrlMU(:,:,i)=readmatrix(sprintf("%s/%s_%d/ctrldata.csv",datadir,expnameMu,i-1));
        mudata=[mudata;readData(sprintf("%s/%s_%d/*.csv",datadir,expnameMu,i-1))];

        muRT=[muRT;mudata(end).rt];
        %muT=[muT;mudata(end).tr'];
        muT(:,i)=mudata(end).tr(1:size(ctrlMU,1));

        nanCountMu=sum(isnan(ctrlMU(:,3:end,i)));
        ctrlMU(:,3:end,i)=fillmissing(ctrlMU(:,3:end,i),'constant',0);
    end

    %compute CI for mucontrol
    ctrlMUCI=zeros(size(ctrlMU,1),2);
    for i=1:size(ctrlMU,1)
        datai=squeeze(sum(ctrlMU(i,3:end,:),2));
        ctrlMUCI(i,:) = getCI(datai);
    end

    mGA=mean(ctrlGA(:,3:end,:),3);
    mMU=mean(ctrlMU(:,3:end,:),3);

    
    %% Users figure
    figure('units','normalized','outerposition',[0 0 1 1])
    stairs(ctrlMU(:,2,1),"LineWidth",2.5);
    box on
    grid on
    ax = gca;
    ax.FontSize = fontSize;
    xlabel("Time(s)")
    ylabel("#Users")
    legend("Users","Location","southeast")
    axis tight
    xlim(lim)
    ylim([0, 80]) %max(ctrlMU(:,2,1))*1.25])
    exportgraphics(gca,sprintf("figure/acmeair_%s_users.pdf",expWork));
    close()

    %% Cores figure
    figure('units','normalized','outerposition',[0 0 1 1])
    hold on
    box on
    grid on
    hold on  
    
    
    stairs(sum(mMU,2),"LineWidth",2.5,"Color",colorBlue);
    stairs(sum(mGA,2),"LineWidth",2.5,"Color",colorOrange);
    
    shade(1:1:maxTime,ctrlGACI(1:end,2),1:1:maxTime,ctrlGACI(1:end,1),'FillType',[1 2], 'FillColor', colorOrange, 'LineStyle', 'none');
    %stairs(ctrlGACI(1:end,:),"-","Color",[0.85,0.33,0.10])
    shade(1:1:maxTime,ctrlMUCI(1:end,2),1:1:maxTime,ctrlMUCI(1:end,1),'FillType',[1 2], 'FillColor', colorBlue, 'LineStyle', 'none');
    %stairs(ctrlMUCI(1:end,:),"-","Color",[0.00,0.45,0.74]) 

    ax = gca;
    ax.FontSize = fontSize;
    xlabel("Time(s)")
    ylabel("#Cores")
    xlim(lim)
    ylim([0,80]) %max(sum(mMU,2))*1.25
    legend("\muOpt","ATOM","Location","southeast")
    exportgraphics(gca,sprintf("figure/acmeair_%s_cores.pdf",expWork));
    close()

    %% Throughput figure
    figure('units','normalized','outerposition',[0 0 1 1])
    stairs(smoothdata(mean(muT,2),'movmean',3),"LineWidth",2.5, "Color",colorBlue);
    hold on
    stairs(smoothdata(mean(gaT,2),'movmean',3),"LineWidth",2.5,"Color",colorOrange);
    shade(1:1:maxTime,smoothdata(gaTCI(:,2), 'movmean', 3),1:1:maxTime,smoothdata(gaTCI(:,1), 'movmean', 3),'FillType',[1 2], 'FillColor', colorOrange, 'LineStyle', 'none');
% smoothdata(
    %stairs(gaTCI(:,1),"-","Color",[0.85,0.33,0.10],"LineWidth",0.001);
    %stairs(gaTCI(:,2),"-","Color",[0.85,0.33,0.10],"LineWidth",0.001);

    grid on;
    box on;
    legend("\muOpt","ATOM","Location","southeast")
    ax = gca;
    ax.FontSize = fontSize;
    ylabel("Troughput(req/s)")
    xlabel("Time(s)")
    xlim(lim)
    ylim([0,max(mean(gaT,2))*1.25])
    exportgraphics(gca,sprintf("figure/acmeair_%s_throughput_t.pdf",expWork));
    close()


    %% Last boxplot
    totMUT=cumsum(mean(muT,2));
    totGAT=cumsum(mean(gaT,2));

    for i=1:min(size(ctrlGA,3),size(ctrlMU,3))
        deltaS(i)=(-trapz(sum(ctrlGA(:,3:end,i),2))+trapz(sum(ctrlMU(:,3:end,i),2)))*100/trapz(sum(ctrlMU(:,3:end,i),2));
        deltaT(i)=mean(muT(:,i)-gaT(:,i))*100/mean(muT(:,i));
    end

    % figure('units','normalized','outerposition',[0 0 0.5 0.5])
    figure
    set(gcf,'units','normalized',"position",[0 0 1 1]);
    hold on
    %somedata=[(totMUT(end)-totGAT(end))*100/totMUT(end),(-trapz(sum(mGA,2))+trapz(sum(mMU,2)))*100/trapz(sum(mMU,2))];
    somedata=[mean(deltaT),mean(deltaS)];
    somenames=["","$\Delta\mathcal{T}$","","$\Delta\mathcal{S}$"];
    % somenames={" "," "};
    set(gca,'defaultAxesTickLabelInterpreter','latex');
    set(gca,'defaulttextinterpreter','latex');
    set(gca,'defaultLegendInterpreter','latex');

    h=bar([1,2],somedata);
    h.FaceColor="flat";
    h.CData(1,:)=[241 197 58]/255;
    grid on;
    box on;
    set(gca,'xticklabel',somenames)
    ylabel("%")
    ylim([-45,15])
    ax = gca;
    ax.FontSize = fontSize;
    xlim([0.5,2.5])
    xh = get(gca,'xlabel');
    xh.Color=[1,1,1];
    xlabel("time");
    yticks([-45,-35,-25,-15,-5,5,15])

    % ylim(sort(somedata*1.30))

    CIdt=getCI(deltaT)-mean(deltaT);
    CIds=getCI(deltaS)-mean(deltaS);
    errorbar([1,2],[mean(deltaT),mean(deltaS)],[CIdt(1),CIds(1)],[CIdt(2),CIds(2)],'x',"LineWidth",2,"Color","red");
    exportgraphics(gca,sprintf("figure/acmeair_%s_stat.pdf",expWork));
    close()
    
    
end

