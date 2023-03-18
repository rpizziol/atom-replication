clear

MU=zeros(1,10);
NUsers=100;
X0=zeros(1,10);
X0(1,end)=NUsers;

XdbAccess_e=10;
XappRequest_e=15;
Xaccept_e=2;
XuserWork_e=1000;

NTUsers=NUsers;
NTApp=1;
NTHTTPServer=20;
NTDB=200;

NCUsers=NUsers;
NCApp=10;
NCHTTPServer=20;
NCDB=20;

MU([7,8,9,10])=1000./[XdbAccess_e,XappRequest_e,Xaccept_e,XuserWork_e];
NT=[NTUsers,NTApp,NTHTTPServer,NTDB];
NC=[NCUsers,NCApp,NCHTTPServer,NCDB];

[t,y,ssR]=lqnODE(X0,MU,NT,NC);

TUser=ssR(1);
TAccept=ssR(end);
TApp=sum(ssR([6,7]));
TDB=ssR(5);

TOde=[TUser,TAccept,TApp,TDB]';
RTOde=[NUsers/TUser,sum(y(end,[3,9]))/TAccept,sum(y(end,[5,8]))/TApp,sum(y(end,[7]))/TDB]';

system("java -jar /usr/local/bin/DiffLQN.jar model.lqn > /dev/null");
diffLqnRes = readtable("model.csv",'Delimiter',",");

Terr=abs(diffLqnRes.Var4(1:4)-TOde)*100./TOde;
RTerr=abs(diffLqnRes.Var4(5:end)-RTOde)*100./RTOde;


% figure
% grid on
% box on
% title("Users task")
% plot(t*1000,y(:,[end]),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"Users.png")
% close()
% 
% figure
% grid on
% box on
% title("HTTPServer task")
% plot(t*1000,y(:,[1]),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"HTTPServer.png")
% close()
% 
% figure
% grid on
% box on
% title("App task")
% plot(t*1000,y(:,[3]),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"App.png")
% close()
% 
% figure
% grid on
% box on
% title("DB task")
% plot(t*1000,sum(y(:,[5,9]),2),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"DB.png")
% close()

