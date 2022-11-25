clear

mixs = ["o", "s", "b"];
W = [1000, 2000, 3000];
format = "pdf";

for l = 1:length(mixs)
    mix = mixs(l);
    for g = 1:length(W)
        fprintf('%i - %s\n', W(g), mix)
        optRes=load(sprintf('./data/muopt_%d_%s.mat',W(g),mix));
        gaRes=load(sprintf('./data/muopt_%d-%s-GA.mat',W(g),mix));

        fontsize=50;
        if(W(g)==1000)
            dsampling=10;
        else
            dsampling=1;
        end

        steps=double(optRes.steps)+1;

        cumAvgGA=[];
        cumAvgOpt=[];
        %e=[];

        for i = 1:size(optRes.steps, 2)
            if(i > 1)
                cumAvgOpt = [cumAvgOpt,cumsum(optRes.Tsim(sum(optRes.steps(1:i-1))+1:sum(optRes.steps(1:i))))./linspace(1,optRes.steps(i),optRes.steps(i))];
                cumAvgGA = [cumAvgGA,cumsum(gaRes.Tsim(sum(gaRes.steps(1:i-1))+1:sum(gaRes.steps(1:i))))./linspace(1,gaRes.steps(i),gaRes.steps(i))];
            else
                cumAvgOpt = [cumAvgOpt,cumsum(optRes.Tsim(1:steps(i)))./linspace(1,steps(i),steps(i))];
                cumAvgGA = [cumAvgGA,cumsum(gaRes.Tsim(1:steps(i)))./linspace(1,steps(i),steps(i))];
            end
            %e=[e,abs(cumAvg(end)-(optRes.w(i)/7))*100/(optRes.w(i)/7)];
            %e=[e,abs(cumAvg(end)-(w(i)/7))];
        end

        %cumAvg=cumsum(Tsim)./linspace(1,size(Tsim,2),size(Tsim,2));


        X = linspace(0,optRes.Tsim(end),size(optRes.Tsim(1:dsampling:end),2));

        %%%%%Throughput Dynamics
        
        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf, 'color', [1 1 1])
        hold on
        grid on;
        box on;
        %stairs(X,Tsim(1:dsampling:end),'linewidth',1.0,"Color", [0.8, 0.8, 0.8])
        %stairs(X,optRes.Tsim(1:dsampling:end),'linewidth',1.0)
        %patchline(X,Tsim(1:5:end),'linewidth',1.0,'edgealpha',0.2)
        plot(X,cumAvgGA(1:dsampling:size(optRes.Tsim,2)),'linestyle','--','linewidth',2);
        plot(X,optRes.w(1:dsampling:end)/7,'linestyle','-','linewidth',1.5,'Color',[255,0,255]/255);
        plot(X,cumAvgOpt(1:dsampling:end),'linestyle','--','linewidth',2,'Color',[255,0,0]/255);
        ylim([min(optRes.Tsim)*0.95,max(optRes.Tsim)*1.05])
        xlabel("Time(s)")
        ylabel("Throughput(req/s)")
        legend(["T_{GA}","Req","T_{\muOpt}"],'location','NorthEast')
        set(gca,'FontSize',fontsize)
        %export_fig(sprintf("img/sinResOpt%d_%s.pdf",optRes.w(1),mix))
        %exportgraphics(gcf,sprintf("img/sinResOpt%d_%s.%s",optRes.w(1),mix,format))
        %close()
        

        %{
        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf, 'color', [1 1 1])
        set(gca,'FontSize',fontsize)
        hold on
        grid on;
        box on;
        %stairs(X,Tsim(1:dsampling:end),'linewidth',1.0,"Color", [0.8, 0.8, 0.8])
        stairs(X,gaRes.Tsim(1:dsampling:size(optRes.Tsim,2)),'linewidth',1.0)
        %patchline(X,Tsim(1:5:end),'linewidth',1.0,'edgealpha',0.2)
        plot(X,gaRes.w(1:dsampling:size(optRes.Tsim,2))/7,'linestyle','-','linewidth',1.5,'Color',[255,0,255]/255);
        plot(X,cumAvgGA(1:dsampling:size(optRes.Tsim,2)),'linestyle','--','linewidth',2,'Color',[255,0,0]/255);
        ylim([min(optRes.Tsim)*0.95,max(optRes.Tsim)*1.05])
        xlabel("Time(s)")
        ylabel("Throughput(req/s)")
        legend(["T_{1s}","Req","T_{avg}"],'location','NorthEast')
        %export_fig(sprintf("img/sinResGA%d_%s.pdf",optRes.w(1),mix))
        exportgraphics(gcf,sprintf("img/sinResGA%d_%s.%s",optRes.w(1),mix, format))
        close()
        %}


        % figure('units','normalized','outerposition',[0 0 1 1]);
        % set(gcf, 'color', [1 1 1])
        % set(gca,'FontSize',24)
        % hold on
        % grid on;
        % box on;
        % stairs(X,optRes.w(1:dsampling:end),'linewidth',1.5)
        % xlabel("Time(s)")
        % ylabel("#Users")
        % export_fig("sinW.pdf")
        % close()

        % figure('units','normalized','outerposition',[0 0 1 1]);
        % set(gcf, 'color', [1 1 1])
        % set(gca,'FontSize',24)
        % hold on
        % grid on;
        % box on;
        % stairs(X,gaRes.w(1:dsampling:end),'linewidth',1.5)
        % xlabel("Time(s)")
        % ylabel("#Users")
        % export_fig("sinW.pdf")
        % close()

%{
        %plotNC
        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf, 'color', [1 1 1])
        set(gca,'FontSize',fontsize)
        hold on
        grid on;
        box on;

        Y = optRes.NC(1:dsampling:size(optRes.Tsim,2),1) + optRes.NC(1:dsampling:size(optRes.Tsim,2),2) + optRes.NC(1:dsampling:size(optRes.Tsim,2),3) + optRes.NC(1:dsampling:size(optRes.Tsim,2),4);
        
        stairs(X,Y,'linewidth',2)
        xlabel("Time(s)")
        ylabel("#Cores")
        legend("Router", "Front-end","Catalog Svc.","Carts Svc.", "Router")
        %export_fig(sprintf("img/sinUOpt%d_%s.pdf",optRes.w(1),mix))
        exportgraphics(gcf,sprintf("img/sinUOpt%d_%s.%s",optRes.w(1),mix,format))
        close()
%}
        
%{
        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf, 'color', [1 1 1])
        set(gca,'FontSize',fontsize)
        hold on
        grid on;
        box on;

        Yopt = 0;
        for i = 1:3 %length(optRes.NC(1:dsampling:size(optRes.Tsim,2),:))
            Yopt = Yopt + optRes.NC(1:dsampling:size(optRes.Tsim,2),i);
        end

        Yga = 0;
        for i = 1:3 %length(gaRes.NC(1:dsampling:size(optRes.Tsim,2),:))
            Yga = Yga + gaRes.NC(1:dsampling:size(optRes.Tsim,2),i);
        end
        %Yopt = optRes.NC(1:dsampling:size(optRes.Tsim,2),1) + optRes.NC(1:dsampling:size(optRes.Tsim,2),2) + optRes.NC(1:dsampling:size(optRes.Tsim,2),3) + optRes.NC(1:dsampling:size(optRes.Tsim,2),4);
        %Yga = gaRes.NC(1:dsampling:size(optRes.Tsim,2),1) + gaRes.NC(1:dsampling:size(optRes.Tsim,2),2) + gaRes.NC(1:dsampling:size(optRes.Tsim,2),3) + gaRes.NC(1:dsampling:size(optRes.Tsim,2),4);
        stairs(X,Yopt,'linewidth',2)
        stairs(X,Yga,'linewidth',2)
        xlabel("Time(s)")
        ylabel("#Cores")
        legend("\muOpt", "GA"); %,"Catalog Svc.","Carts Svc.")
        %export_fig(sprintf("img/sinUGA%d_%s.pdf",optRes.w(1),mix))
        exportgraphics(gcf,sprintf("img/sinUGA%d_%s.%s",optRes.w(1),mix,format))
        close()

%}

%{
        objGa=0.5*(gaRes.Tsim(1:size(optRes.Tsim,2)) ./(double(gaRes.w(1:size(optRes.Tsim,2)))/7))'-sum(gaRes.NC(1:size(optRes.Tsim,2),:),2)/(400);
        objOpt=0.5*(optRes.Tsim ./(double(optRes.w)/7))'-sum(optRes.NC,2)/(400);

        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf, 'color', [1 1 1])
        set(gca,'FontSize',fontsize)
        hold on;
        grid on;
        box on;
        stairs(X,cumsum(objGa(1:dsampling:end))'./linspace(1,size(objGa(1:dsampling:end),1),size(objGa(1:dsampling:end),1)),'linewidth',2);
        stairs(X,cumsum(objOpt(1:dsampling:end))'./linspace(1,size(objOpt(1:dsampling:end),1),size(objOpt(1:dsampling:end),1)),'linewidth',2);
        xlabel("Time(s)")
        ylabel("Objective Value")
        legend("GA","\muOpt")
        %export_fig(sprintf("img/sinObj%d_%s.pdf",optRes.w(1),mix))
        exportgraphics(gcf,sprintf("img/sinObj%d_%s.%s",optRes.w(1),mix,format))
        close()
%}


        %
        % figure('units','normalized','outerposition',[0 0 1 1]);
        % set(gcf, 'color', [1 1 1])
        % set(gca,'FontSize',24)
        % hold on
        % grid on;
        % box on;
        % stairs(X,optRes.NT(1:dsampling:end,:),'linewidth',1.5)
        % xlabel("Time(s)")
        % ylabel("#Threads")
        % legend("Frontend","Catalog Svc","Carts Svc")
        % % export_fig("sinUT.pdf")
        % % close()
        %
        % SEM = std(optRes.Tsim)/sqrt(length(optRes.Tsim));               % Standard Error
        % ts = tinv([0.025  0.975],length(optRes.Tsim)-1);      % T-Score
        % CI = mean(optRes.Tsim) + ts*SEM;


    end
end
