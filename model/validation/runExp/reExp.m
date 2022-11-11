clear

load("reMINL.mat")

T=zeros(1,size(Clients,1));

for i=1:size(Clients,1)
    w=Clients(i);
    MU=[0,0,1,1,1];
    X=lqn([0,0,0,0,w],MU,[inf,round(NT_opt(i))],[inf,NC_opt(i)],4000,1,1);
    avgX=cumsum(X,2)./linspace(1,size(X,2),size(X,2));
    T(i)=avgX(end,end);
end