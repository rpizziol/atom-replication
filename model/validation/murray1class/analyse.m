clear

MU=zeros(1,11);
NUsers=100;
X0=zeros(1,11);
X0(1,end)=NUsers;

XdbAccess_e=10;
XappRequest_e=15;
Xaccept_e=2;
XuserWork_e=1000;

NTUsers=NUsers;
NTApp=15;
NTHTTPServer=27;
NTDB=2;

NCUsers=NUsers;
NCApp=1;
NCHTTPServer=2;
NCDB=2;

MU([7,8,10,11])=1000./[XdbAccess_e,XappRequest_e,Xaccept_e,XuserWork_e];
NT=[NTUsers,NTApp,NTHTTPServer,NTDB];
NC=[NCUsers,NCApp,NCHTTPServer,NCDB];

[t,y,ssR]=lqnODE(X0,MU,NT,NC);

Tuser=ssR(1);
Taccept=ssR(10);
Tapprequest=sum(ssR([7,8]));
Tdbaccess=sum(ssR([5,8,9]));

TOde=[Tuser,Taccept,Tapprequest,Tdbaccess]';
RTOde=[sum(y(end,[1,end]))/Tuser,...
    sum(y(end,[3,9,10]))/Taccept,...
    sum(y(end,[5,8]))/Tapprequest,....
    sum(y(end,[7]))/Tdbaccess]';

Y=zeros(size(y,1),13);

Y(:,[1])=t;

%userWork
Y(:,[2,3])=y(:,[end,1]);

%accept
Y(:,[5])=y(:,[10]);
Y(:,[6])=sum(y(:,[3,9]),2);
Y(:,[7])=y(:,[2]);

%apprequest
Y(:,[8])=y(:,[8]);
Y(:,[9])=y(:,[5]);
Y(:,[10])=y(:,[4]);

%dbaccess
Y(:,[11])=y(:,[7]);
Y(:,[13])=y(:,[6]);

T = array2table(Y);

%> /dev/null
% system("java -jar /usr/local/bin/DiffLQN.jar model.lqn");
% diffLqnRes = readtable("model.csv",'Delimiter',",");

% Terr=abs(TOde-diffLqnRes.Var4(1:4))*100./diffLqnRes.Var4(1:4);
% RTerr=abs(RTOde-diffLqnRes.Var4(5:end))*100./diffLqnRes.Var4(5:end);


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
% plot(t*1000,sum(y(:,[2,10]),2),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"HTTPServer.png")
% close()
% 
% 
% figure
% grid on
% box on
% title("App task")
% plot(t*1000,sum(y(:,[5,8]),2),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"App.png")
% close()
% 
% figure
% grid on
% box on
% title("DB task")
% plot(t*1000,sum(y(:,[6,7]),2),"LineWidth",2)
% xlabel("Time")
% ylabel("State")
% exportgraphics(gca,"DB.png")
% close()

