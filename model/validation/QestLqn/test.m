X0=zeros(1,11);
MU=zeros(1,11);

NT=[inf,inf,inf];
NC=[inf,inf,inf];
muB=1;
muE1=1;
muE2=1/3;
X0(1,end)=10;

MU([11,10,7])=[muB,muE1,muE2];
[t,y,ssR] = lqnODE(X0,MU,NT,NC);

plot(t,y);

RT=X0(1,end)/(ssR(end));