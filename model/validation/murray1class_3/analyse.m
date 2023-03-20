clear

MU=zeros(1,13);
NUsers=100;
X0=zeros(1,13);
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
NCHTTPServer=1;
NCDB=1;


MU([7,8,12,13])=1000./[XdbAccess_e,XappRequest_e,Xaccept_e,XuserWork_e];
NT=[NTUsers,NTApp,NTHTTPServer,NTDB];
NC=[NCUsers,NCApp,NCHTTPServer,NCDB];

[t,y,ssR]=lqnODE(X0,MU,NT,NC);

Tuser=ssR(1);
Taccept=ssR(end);
Tapprequest=sum(ssR([6,7]));
Tdbaccess=sum(ssR([5,9,10]));
% 
TOde=[Tuser,Taccept,Tapprequest,Tdbaccess]';
% %RT=[sum(y(end,[1,end]))/Tuser,y(end,[1])/Taccept];
% 
% system("java -jar /usr/local/bin/DiffLQN.jar model.lqn > /dev/null");
% diffLqnRes = readtable("model.csv",'Delimiter',",");

userWorkM=readmatrix("/Users/emilio-imt/Desktop/murray/csv/4tierOneClassEmilioOneClass17-Mar-2023_userWork.csv");

figure 
hold on
plot(userWorkM(:,1),userWorkM(:,[2]));
plot(userWorkM(:,1),y(:,end));
plot(userWorkM(:,1),userWorkM(:,[end]));
legend("Murray","Emilio","LQNS")

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
% figure
% grid on
% box on
% title("App task")
% plot(t*1000,sum(y(:,[4,10]),2),"LineWidth",2)
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

