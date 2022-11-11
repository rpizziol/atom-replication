clear;

npoint=100;
M=5;
RTlg=zeros([M,npoint]);
RTg=zeros([M,npoint]);

for i=1:npoint
    NC=[inf,randi([1,10],1,4)];
    NT=ones(1,5)*inf;
    MU=zeros(1,16);
    
    MU(5)=rand*100; %e3
    MU(8)=rand*100; %e4
    MU(9)=rand*100; %e1
    MU(15)=rand*100;%e2
    MU(16)=rand*100;%browse
    
    %states name
    %X(1)=Xbrowse_2e1;
    %X(2)=Xe1_a;
    %X(3)=Xe1_e1Toe3;
    %X(4)=Xe3_a;
    %X(5)=Xe3_e;
    %X(6)=Xe1_e1Toe4;
    %X(7)=Xe4_a;
    %X(8)=Xe4_e;
    %X(9)=Xe1_e;
    %X(10)=Xbrowse_2e2;
    %X(11)=Xe2_a;
    %X(12)=Xe2_e2Toe1;
    %X(13)=Xe2_e2Toe3;
    %X(14)=Xe2_e2Toe4;
    %X(15)=Xe2_e;
    %X(16)=Xbrowse_browse;
    
    X0=[zeros(1,15),10];
    
    [t,y,ssR] = lqnODE(X0,MU,NT,NC);
    
    Tbrowse=ssR(1);
    T1=sum(ssR([7,9]));
    T2=ssR(12);
    T3=sum(ssR([4,10]));
    T4=sum(ssR([6,11]));
    
    T=[Tbrowse,T1,T2,T3,T4];
    
    RTbrowse=sum(y(end,[1,10,16]))/Tbrowse;
    RT1=sum(y(end,[3,6,9]))/T1;
    RT2=sum(y(end,[12,13,14,15]))/T2;
    RT3=sum(y(end,[5]))/T3;
    RT4=sum(y(end,[8]))/T4;
    
    RT=[RTbrowse,RT1,RT2,RT3,RT4];
    
    RTl=[y(end,16)/Tbrowse,y(end,9)/T1,y(end,15)/T2,y(end,5)/T3,y(end,8)/T4];
    
    P=[0,1,1,0,0;
        0,0,0,1,1;
        0,1,0,1,1;
        0,0,0,0,0;
        0,0,0,0,0];
    
    RTm=P*RT'+RTl';
    
    disp([RT',RTm])
    
    RTlg(:,i)=RTl';
    RTg(:,i)=RT';
    
end

save("data.mat","RTlg","RTg");

clear
