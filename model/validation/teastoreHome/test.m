X0=zeros(1,13);
MU=zeros(1,13);

X0(end)=100;
MU([5,8,11,12,13])=[1/0.00577,1/0.003808,1/0.005153,1/0.01667,1];
NT=[inf,inf,inf,inf,inf];
NC=[inf,1,1,1,1];

X=lqn(X0,MU,NT,NC,5,50,0.1);

plot(mean(X,3)')