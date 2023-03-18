clear

X0=zeros(1,5);
MU=zeros(1,5);

NT=[inf,randi([10,100])];
NC=[inf,rand()*100];

X0(end)=randi([10,50]);
MU([3,4,5])=[1,20,1];

[t,y,ssR] = lqnODE(X0,MU,NT,NC,10,0.1);

[t2,y2,ssR2] = lqnODE_new([X0(end),0,0],MU,NT,NC,10,0.1);
y3=[y(:,end),sum(y(:,[2,3]),2),y(:,4)];

figure
hold on
plot(t2,y2,"LineWidth",1)
plot(t,y3,"--","LineWidth",1.5)

% max(y2-y3)
% X=lqn(X0,MU,NT,NC,2000,1,0.1);

% Mean=cumsum(X(end,:))./linspace(1,size(X,2),size(X,2));
% [y2(end,1),Mean(end)]