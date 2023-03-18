clear
%load service time of model
%MU=load("/Users/emilio-imt/git/nodejsMicro/src/params.mat");
%load wahtif scenario data
WI=load("/Users/emilio-imt/git/nodejsMicro/data/acmeAir.py_full_out.mat");
%load wahtif scenario data
Initial=load("/Users/emilio-imt/git/nodejsMicro/data/acmeAir/acme_full/acmeAir.py_full_10b.mat");


MU([5,6,9,12,15,20,23,24,29,30])=WI.MU([3,2,4,5,9,6,10,7,8,1]);
X0=zeros(1,size(MU,2));


RT_sys=zeros(1,size(WI.Cli,1));
RT_model=zeros(1,size(WI.Cli,1));

for i=1:size(WI.Cli,1)
    X0(1,end)=double(WI.Cli(i));
    [t,y,ssTR,ssRT] = lqnODE(X0,MU,[inf,ceil(ones(1,9)*inf)],WI.NCopt(i,:));

    RT_model(i,1)=ssRT(1);
    RT_sys(i,1)=WI.RTlqn(1,i);
end

