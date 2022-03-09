X0=zeros(1,7);
MU=zeros(1,7);

X0(1,end)=randi([1,1000]);
MU(1,3)=1/0.48; %Xe1_e;
MU(1,6)=1/1.15; %Xe2_e;
MU(1,7)=1/0.35;%XBrowse_browse;

NT=[inf,inf,inf];
%NC=[inf,1,10000];
TF=10;
dt=10^-4;
rep=100;

E1=[];
E2=[];

nsamples=1;

Xm=zeros(nsamples,6);
Tm=zeros(nsamples,3);
Xl=zeros(nsamples,6);
RTm=zeros(nsamples,3);
RTl=zeros(nsamples,3);
NC=zeros(nsamples,3);

for i=1:nsamples
    %NC(i,:)=[inf,rand(1,2)*100];
    NC(i,:)=[inf,1,1];
    X0(1,end)=randi([100,1000]);
    
    [t,y]=lqnOdeSeq(X0,MU,NT,NC(i,:),dt);
    
    T0=(min(y(end,end),NC(i,1))*MU(end));
    T1=(min(y(end,3),NC(i,2))*MU(3));
    T2=(min(y(end,6),NC(i,3))*MU(6));
    Tm(i,:)=[T0,T1,T2];
    
    RT0=sum(y(end,[1,4,end]))/Tm(i,1);
    RT1=sum(y(end,[2,3]))/Tm(i,2);
    RT2=sum(y(end,[5,6]))/Tm(i,3);
    
    Xm(i,:)=[0,sum(y(end,[end])),y(end,2),sum(y(end,3)),y(end,5),y(end,6)];
    RTm(i,:)=[RT0,RT1,RT2];
    
    
    Pl=[          0.333305  0.332547  0.334149
 0.33329   0.333782  0.332928
 0.333347  0.333845  0.332807];
    
    Pl2=[     -9.99988e-9   0.90291      0.103065
 -9.98066e-9  -9.99988e-9   0.997049
  0.00229309  -9.88838e-9  -9.99988e-9];
    
    MUl=[     0.3466352234351433
 0.5225806889328684
 1.150010001537126];
    
    X02=zeros(1,6);
    X02(2)=X0(end);
    [t,y2]=flatOde(X02,Pl,MUl,NT,NC(i,:));
    
    
    
    RT0l=sum(y2(end,[1,2]))/(min(y2(end,2),NC(i,1))*MUl(1));
    RT1l=sum(y2(end,[3,4]))/(min(y2(end,4),NC(i,2))*MUl(2));
    RT2l=sum(y2(end,[5,6]))/(min(y2(end,6),NC(i,3))*MUl(3));
    
    Xl(i,:)=y2(end,:);
    RTl(i,:)=solveRT(Pl2,[RT0l,RT1l,RT2l])';
    %
    %     X_t=X;
    %     X_l=y2(end,:);
    %     RT_t=[RT0,RT1,RT2];
    %     RT_l=solveRT(Pl2,[RT0l;RT1l;RT2l]')';
    %
    % %     E1=[E1,abs(X_t(2:end)-X_l(2:end))*100./X_t(2:end)];
    % %     E2=[E2,abs(RT_t-RT_l)*100./RT_t];
    %     E1=[E1,abs(X_t(2:end)-X_l(2:end))];
    %     E2=[E2,abs(RT_t-RT_l)];
    disp(max(abs(RTm-RTl)*100./RTm));
    disp(max(abs(Xm-Xl)*100./Xm));
end

save("data.mat","Xm","RTm","Tm","NC");

% figure
% boxplot(E1)
% box on
% grid on
% title("Relative Error of Queue Lengths")
% ylabel("Relative Error(%)")
% figure
% boxplot(E2)
% box on
% grid on
% ylabel("Relative Error(%)")
% title("Relative Error of Rsponse Time")