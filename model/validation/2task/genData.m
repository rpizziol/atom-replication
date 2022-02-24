X0=zeros(1,7);
MU=zeros(1,7);

wi=load("/Users/emilio/Dropbox/difflqn-automate/generated/tier3_3/whatif/tier3w_3.mat");

X0(1,end)=randi([1,1000]);
MU(1,5)=1/1.15; %XHome_e;
MU(1,6)=1/0.48; %XAddress_e;
MU(1,7)=1/0.35;%XBrowse_browse;

NT=[inf,inf,inf];
%NC=[inf,1,10000];
TF=10;
dt=10^-4;
rep=100;

E1=[];
E2=[];

for i=1:size(wi.Cli,1)
    %NC=[inf,randi([1,100],1,2)];
    NC=wi.NC(i,:); 
    
    
    
    Pl=[        0.0         0.994696    0.00530409
 1.28884e-5  1.16175e-5  0.999975
 0.0         0.00531841  0.994682];
    
    Pl2=[   0.0         0.994696     0.00530409
 1.15744e-5  0.0          0.999976
 0.0         0.000284767  0.0];
    
    MUl=[  2.8249019749049906
 2.0741733372795994
 0.8695576565755234];
    
    X02=zeros(1,3);
    X02(1)=wi.Cli(i);
    Kpi=lineQN(X02,Pl,MUl,NC);
    
    
    RT_t=wi.RTm(i,:);
    RT_l=solveRT(Pl2,Kpi(2,:))';
    
%     E1=[E1,abs(X_t-X_l)*100./X_t];
    E2=[E2,abs(RT_t-RT_l)*100./RT_t];
    disp(abs(RT_t-RT_l)*100./RT_t)
end

% figure
% boxplot(E1)
% box on
% grid on
% title("Relative Error of Queue Lengths")
% ylabel("Relative Error(%)")
figure
boxplot(E2)
box on
grid on
ylabel("Relative Error(%)")
title("Relative Error of Rsponse Time")