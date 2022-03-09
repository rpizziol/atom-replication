clear

wi=load("/Users/emilio/git/lqn-automate-sim/models/m1/tier3_data.mat");

E1=[];
E2=[];

PL=[ 0.216058  0.216053  0.216059  0.351829
 0.216058  0.216054  0.216059  0.351829
 0.216057  0.21605   0.216058  0.351835
 0.1759    0.175894  0.175901  0.472304];

PL2=[   0.0         0.999947  1.0  2.33193e-8
 5.49168e-5  0.0       0.0  1.0
 0.0         0.0       0.0  0.998751
 0.0         0.0       0.0  0.0];

MUL=[ 4.118591341906985
 41.286614754911
 85.32865583272292
 71.0816417760065];

%for i=1:size(wi.Cli,1)
for i=15:size(wi.Cli,1)
    NC=wi.NC(i,:);
   
    X0=zeros(1,size(wi.NC,2));
    X0(1)=wi.Cli(i);
    Kpi=lineQN(X0,PL,MUL,NC);
    
    
    RT_t=wi.RTm(i,:);
    RT_l=solveRT(PL2,Kpi(2,:))';
    
    %     E1=[E1,abs(X_t-X_l)*100./X_t];
    E2=[E2,abs(RT_t-RT_l)];
    disp(abs(RT_t-RT_l))
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