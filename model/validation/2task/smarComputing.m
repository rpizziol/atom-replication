clear

realSys=load("/Users/emilio/git/MS-App/execution/queue_0_3.mat");

X0=[0,0,0,0,0,0,60];
MU=[0,0,0,0,1/0.5,1/0.350,1];
NT=realSys.NT;
NC=realSys.NC;
dt=realSys.dt;
tf=size(realSys.Queue,1)*dt;
rep=sum(sum(realSys.Queue(:,1,:),1)~=0);

X = lqn(X0,MU,NT,NC,tf,rep,dt);
Xm=mean(X,3)';

QueueMPP=[Xm(1:end-1,end),Xm(1:end-1,2),Xm(1:end-1,6),Xm(1:end-1,4),Xm(1:end-1,5)];

timeB=linspace(1,size(Xm,1)*dt,size(Xm,1)-1);

Qsim=cumsum(QueueMPP)./linspace(1,size(QueueMPP,1),size(QueueMPP,1))';

Xmreal=mean(realSys.Queue(:,:,1:rep),3);
Qreal=cumsum(Xmreal)./linspace(1,size(Xmreal,1),size(Xmreal,1))';

cc=hsv(5);

figure('units','normalized','outerposition',[0 0 1 1])
title("Cumulative Queue-length Average")
set(gca,'FontSize',24)
hold on
for i=1:5
    plot(timeB,Qsim(:,i),'color',cc(i,:),'linewidth',1.5,'linestyle','-.');
end
for i=1:5
    plot(timeB,Qreal(:,i),'color',cc(i,:),'linewidth',1.5);
end
legend(["x0_e","x1_a","x1_e","x2_a","x2_e"])

grid on
box on

xlabel('Time(s)')
ylabel("#Jobs")
set(findall(gcf,'type','text'),'FontSize',24)

cumX=cumsum(Xm)./linspace(1,size(Xm,1),size(Xm,1))';

RT=sum(cumX(end,[1,end]))/cumX(end,end);

figure('units','normalized','outerposition',[0 0 1 1])
title("Cumulative Queue-length Average")
set(gca,'FontSize',24)
hold on
for i=1:5
    plot(timeB,QueueMPP(:,i),'color',cc(i,:),'linewidth',1.5,'linestyle','-.');
end
for i=1:5
    plot(timeB,Xmreal(:,i),'color',cc(i,:),'linewidth',1.5);
end
legend(["x0_e","x1_a","x1_e","x2_a","x2_e"])

grid on
box on



% exportgraphics(gcf,"/Users/emilio/git/talks/smarComputing_unif-(1)/img/vao2.pdf")
% close()