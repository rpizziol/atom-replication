
MU=zeros(1,10);
MU([7,8,9,10])=[1/0.360,1/0.5,1/0.220,1/0.140];
X0=zeros(1,10);
NT=[inf,inf,inf,inf];

np=50;

RTm=zeros(np,4);
Tm=zeros(np,4);
NC=zeros(np,2);
Cli=zeros(np,1);

for i=1:np

Cli(i)=randi([10,200]);
NC(i,:)=[inf,randi([1,50])];
[t,y,Ts]=lqnOde([0,0,0,0,0,0,0,0,0,Cli(i)],MU,NT,NC(i,:));

Tm(i,:)=Ts';
RTm(i,:)=[sum(y(end,[1,10]))/Ts(1),...
    sum(y(end,[2,3,9]))/Ts(2),...
    sum(y(end,[4,5,8]))/Ts(3),...
    sum(y(end,[6,7]))/Ts(4)];
end