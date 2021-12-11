clear

X0=zeros(1,13);
X0(13)=200;

MU=zeros(1,13);
MU(5)=100;
MU(8)=100;
MU(11)=100;
MU(12)=100;
MU(13)=1;
NC=[1,1,1];
NT=[inf,inf,inf];
%1=Client;
%2=Router;
%3=Front_end;

rep=10;
TF=100;
dt=10^-3;

X = simple_lqn(X0,MU,NT,NC,TF,rep,dt);
Xm=mean(X,3);

XCs=cumsum(Xm(end,2:end));
T=linspace(1,ceil(TF/dt),ceil(TF/dt));


plot(XCs./T);
