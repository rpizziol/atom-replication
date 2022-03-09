
MU=zeros(1,10);
MU([7,8,9,10])=[4.7820    3.2627    6.9041    6.2152];
X0=zeros(1,10);
NT=[inf,inf,inf,inf];

%7.1429    4.5455    2.0000    2.7778 ODE rate
%6.6729    4.4043    1.9732    2.7563 Real rate

np=1;

RTm=zeros(np,4);
Tm=zeros(np,4);
NC=zeros(np,2);
Cli=zeros(np,1);

for i=1:np

Cli(i)=15;
NC(i,:)=[inf,24];
[t,y,Ts]=lqnOde([0,0,0,0,0,0,0,0,0,Cli(i)],MU,NT,NC(i,:));

Tm(i,:)=Ts';
RTm(i,:)=[sum(y(end,[1,10]))/Ts(1),...
    sum(y(end,[2,3,9]))/Ts(2),...
    sum(y(end,[4,5,8]))/Ts(3),...
    sum(y(end,[6,7]))/Ts(4)];
end