clear

ctrl=load("/Users/emilio-imt/git/atom-replication/LQN-CRN/controller/acmeAir/re.mat");
load("/Users/emilio-imt/git/nodejsMicro/src/params.mat")
% wi=load("/Users/emilio-imt/git/nodejsMicro/data/ICDCS/validation/m1/acmeair_val_data.mat");

X0=zeros(1,30);
% MU=zeros(1,30);
% % NT=ones(1,10)*inf;
% NC=ones(1,10)*inf;
% NC(1)=inf;
TF=1000;
rep=1;
dt=0.1;
% N=200;

%1=Client;
%2=Auth;
%3=ValidateId;
%4=BookFlight;
%5=UpdateMiles;
%6=CancelBooking;
%7=GetRewardsMiles;
%8=QueryFlight;
%9=ViewProfile;
%10=UpdateProfile;

Tode=zeros(size(ctrl.NC_opt,1)+1,size(ctrl.Clients,1));
RTode=zeros(size(ctrl.NC_opt,1)+1,size(ctrl.Clients,1));

TodeM=zeros(size(ctrl.NC_opt,1)+1,size(ctrl.Clients,1));

MU=MU*1.0;

for i=1:size(ctrl.Clients,1)
    X0=zeros(1,30);
    X0(end)=round(ctrl.Clients(i));
    disp(X0(end))
    [t,y,ssTR,ssRT] = lqnODE(X0,MU,[inf;ceil(ctrl.NT_opt(:,i))],[inf;ctrl.NC_opt(:,i)]);
    [t2,y2,ssTR2,ssRT2] = lqnODE(X0,MU,ones(1,10)*inf,ones(1,10)*inf);
    
    
    Tode(:,i)=ssTR;
    RTode(:,i)=ssRT;
    TodeM(:,i)=ssTR2;
    %X=lqn(X0,MU,ones(1,10)*inf,[inf;NC_opt(:,i)],TF,rep,dt);
end

figure
hold on
% plot(wi.Cli,Tode)
% plot(wi.Cli(1:size(wi.Tm,1)),wi.Tm)
stem(Tode(1,:))
stem(TodeM(1,:))
legend("ctrl_{ode}","real_{ode}")

figure
stairs(ceil(ctrl.NT_opt'))

figure
stairs(ceil(ctrl.NC_opt'))

% figure
% hold on
% plot(wi.Cli,RTode(1:4,:))
% plot(wi.Cli(1:size(wi.Tm,1)),wi.RTm(:,1:4)/1000)


% figure
% hold on
% stem(TodeM)
% stem(Tode)
% ylabel("req/s")
% xlabel("Client")


