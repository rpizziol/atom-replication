load("/Users/emilio/Downloads/tier3_whatif_same_concur.mat");

P=[   0.999955    4.47735e-5  2.39913e-8  8.22506e-8
        4.47601e-5  0.999955    2.399e-8    8.21438e-8
        1.91501e-8  2.04214e-8  1.0         4.00874e-8
        1.01019e-7  7.23553e-8  3.17123e-8  1.0];

MU=[    6.23942542349437
 32.32314448759933
  1.1668805219307417
  5.102027413904388];
NT=[inf,inf];

RTl=zeros(size(Cli,1),size(P,2));
Tl=zeros(size(Cli,1),size(P,2));

for i=1:size(Cli,1)
    
    [t,y,Ts]=flatOde([Cli(i),0,0,0],P,MU,NT,NC(i,:));
    
    Tl(i,:)=[sum(Ts(1:4)),sum(Ts(5:8)),sum(Ts(9:12)),sum(Ts(13:16))];
    RTs=[y(end,1)/sum(Ts(1:4));
        y(end,2)/sum(Ts(5:8));
        y(end,3)/sum(Ts(9:12));
        y(end,4)/sum(Ts(13:16))];
    
    P2=[   0.0       0.534237  0.355299     0.553354
 0.194026  0.0       0.754856     0.513759
 0.0       0.0       2.12361e-30  0.0
 0.132835  0.0       0.0          2.13375e-30];
    
    
    RTl(i,:)=solveRT(P2,RTs);
end

figure
boxplot(abs(RTl-RTm))
ylabel("AbsoluteError (s)")
title("Response time absolute prediction error (what-if)")

figure
boxplot(abs(Tl-Tm))
title("Throughput absolute prediction error (what-if)")
ylabel("AbsoluteError (Req/s)")