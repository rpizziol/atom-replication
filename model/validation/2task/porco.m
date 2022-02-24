load("/Users/emilio/git/atom-replication/model/validation/_3tierGPS/tier3GPS_ODE.mat");

P=[0,1,0,0
   0,0,1,0
   0,0,0,1
   1,0,0,0];

MU=[7.142,4.545,2.0,2.777];
NT=[inf,inf];

RTl=zeros(size(Cli,1),size(P,2));

for i=1:size(Cli,1)
    
    [t,y,Ts]=flatOde([Cli(i),0,0,0],P,MU,NT,NC(i,:));
    
    RTs=[y(end,1)/sum(Ts(1:4));
        y(end,2)/sum(Ts(5:8));
        y(end,3)/sum(Ts(9:12));
        y(end,4)/sum(Ts(13:16))];
    
    P2=[0,1,0,0
   0,0,1,0
   0,0,0,1
   0,0,0,0];
    
    
    RTl(i,:)=solveRT(P2,RTs);
end