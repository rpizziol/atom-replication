X0=zeros(1,7);
MU=zeros(1,7);

X0(1,end)=randi([1,1000]);
MU(1,5)=1; %XHome_e;
MU(1,6)=100; %XAddress_e;
MU(1,7)=1;%XBrowse_browse;

NT=[inf,inf,inf];
NC=[inf,1,1];
TF=10;
dt=10^-4;
rep=100;


%X=lqn(X0,MU,NT,NC,TF,rep,dt);
[t,y]=lqnOde(X0,MU,NT,NC,dt);

Rate =@(X) [MU(7)*X(7);
    X(2)/(X(2))*10^5*min(X(2),NT(2)-(X(3)+X(6)));
    X(4)/(X(4))*10^5*min(X(4),NT(3)-(X(5)));
    X(3)/(X(3))*X(5)/(X(5))*min(X(5),NC(3))*MU(5);
    X(1)/(X(1))*X(6)/(X(6))*min(X(6),NC(2))*MU(6);
    ];

Rate(y(end,:));
%Rate(isnan(Rate))=0;

Pl=[    0.0  0.5   0.5
 0.5  0.25  0.25
 0.5  0.25  0.25];
MUl=[   1.0000081795925617
 100.087692946607
   0.9999999999999181]; 

X02=zeros(1,6);
X02(2)=X0(end);
[t,y2]=flatOde(X02,Pl,MUl,NT,NC);

X=[0,sum(y(end,[end])),y(end,2),sum(y(end,6)),y(end,4),y(end,5)];
%X=[0,X0(1,end),y(end,2),sum(y(end,[3,6])),y(end,[4]),sum(y(end,[5]))];

RT0=X0(1,end)/(min(y(end,end),NC(1))*MU(end));
RT1=sum(y(end,[2,3,6]))/(min(y(end,6),NC(2))*MU(6));
RT2=sum(y(end,[4,5]))/(min(y(end,5),NC(3))*MU(5));

RT0l=sum(y2(end,[1,2]))/(min(y2(end,2),NC(1))*MUl(1));
RT1l=sum(y2(end,[3,4]))/(min(y2(end,4),NC(2))*MUl(2));
RT2l=sum(y2(end,[5,6]))/(min(y2(end,6),NC(3))*MUl(3));

disp(X)
disp(y2(end,:))
disp([RT0,RT1,RT2])
disp([RT0l,RT1l,RT2l])