X0=zeros(1,7);
MU=zeros(1,7);

X0(1,end)=randi([1,1000]);
MU(1,3)=1; %Xe1_e;
MU(1,6)=100; %Xe2_e;
MU(1,7)=1;%XBrowse_browse;

NT=[inf,inf,inf];
%NC=[inf,1,10000];
TF=10;
dt=10^-4;
rep=100;

E1=[];
E2=[];

nsamples=10;

Xm=zeros(nsamples,6);
Xl=zeros(nsamples,6);
RTm=zeros(nsamples,3);
RTl=zeros(nsamples,3);
NC=zeros(nsamples,3);

for i=1:nsamples
    %NC=[inf,randi([1,1000],1,2)];
    NC(i,:)=[inf,inf,1];
    X0(1,end)=randi([100,1000]);
    
    [t,y]=lqnOdeSeq(X0,MU,NT,NC(i,:),dt);
    
    RT0=sum(y(end,[1,4,end]))/(min(y(end,end),NC(i,1))*MU(end));
    RT1=sum(y(end,[2,3]))/(min(y(end,3),NC(i,2))*MU(3));
    RT2=sum(y(end,[5,6]))/(min(y(end,6),NC(i,3))*MU(6));
    
    Xm(i,:)=[0,sum(y(end,[end])),y(end,2),sum(y(end,3)),y(end,5),y(end,6)];
    RTm(i,:)=[RT0,RT1,RT2];
    
    
    Pl=[         9.01714e-11  0.5   0.5
 0.5          0.25  0.25
 0.5          0.25  0.25];
    
    Pl2=[     0.0         1.0  0.999971
 1.10959e-8  0.0  0.00290315
 7.94829e-9  0.0  0.0];
    
    MUl=[     1.0000020850111888
   1.0000000003346254
 100.00016527981983];
    
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