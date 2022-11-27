load("/Users/emilio-imt/git/atom-replication/LQN-CRN/controller/acmeAir/re.mat")

X0=zeros(1,30);
MU=zeros(1,30);
% % NT=ones(1,10)*inf;
% NC=ones(1,10)*inf;
% NC(1)=inf;
TF=1000;
rep=1;
dt=0.1;
% N=200;


%X(5)=XValidate_e;
%X(6)=XLogin_e;
%X(9)=XViewProfile_e;
%X(12)=XUpdateProfile_e;
%X(15)=XQuery_e;
%X(20)=XUpdateMiles_e;
%X(23)=XGetReward_e;
%X(24)=XBook_e;
%X(29)=XCancel_e;
%X(30)=XBrowse_e;

MU(1,5)=11.5048;
MU(1,6)=6.39801;
MU(1,9)=6.35473;
MU(1,12)=4.76082;
MU(1,15)=10.367;
MU(1,20)=20.8321;
MU(1,23)=18.4323;
MU(1,24)=8.25514;
MU(1,29)=9.98412;
MU(1,30)=4.51666;

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

Tode=zeros(1,size(Clients,1));
TodeM=zeros(1,size(Clients,1));

for i=1:size(Clients,1)
    X0=zeros(1,30);
    X0(end)=Clients(i);
    disp(X0(end))
    [t,y,ssR] = lqnODE(X0,MU,[inf;NT_opt(:,i)],[inf;NC_opt(:,i)]);
    [t2,y2,ssR2] = lqnODE(X0,MU,ones(1,10)*inf,ones(1,10)*inf);
    Tode(1,i)=ssR(1);
    TodeM(1,i)=ssR2(1);
    %X=lqn(X0,MU,ones(1,10)*inf,[inf;NC_opt(:,i)],TF,rep,dt);
end


figure
hold on
stem(TodeM)
stem(Tode)
ylabel("req/s")
xlabel("Client")


