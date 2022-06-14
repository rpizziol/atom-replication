NC=[inf,1,1];
NT=[inf,inf,inf];
MU=[0,0,0,0,1,1,1];
X0=[0,0,0,0,0,0,1];

[t,y,ssR] = lqn(X0,MU,NT,NC);

%Throughput
T=ssR([1,5,4]);

%tempi di rispta con attese
RT1=sum(y(end,[5,6,7]))/T(1);
RT2=sum(y(end,[3,6]))/T(2);
RT3=sum(y(end,[5]))/T(3);

RT=[RT1,RT2,RT3];

%utilizzo
U1=min(NC(1),y(end,end))/NC(1);
U2=min(NC(2),y(end,6))/NC(2);
U3=min(NC(3),y(end,5))/NC(3);

U=[U1,U2,U3];

%lunghezza di coda sulla cpu (può essere sballata causa richieste annidate)
C1=U.*NC;
C1(1)=y(end,end);
C2=RT.*T';

%Tempi di risposta locale
Tf=C1./T';

%estimate synchronization between node
A=diag(-ones(1,size(RT,2)))+ones(size(RT,2),size(RT,2));
B=blkdiag(A,A);

%qui devo comporre i risultati di due esperimenti
RTb=[RT,RT];
Tfb=[Tf,Tf];
C=RTb-Tfb;
C=[C,0,0,0];

A=B.*RTb;
A=[A;1,0,0,-1,0,0];
A=[A;0,1,0,0,-1,0];
A=[A;0,0,1,0,0,-1];

X = linsolve(A,C');
