%evaluate result
% clear
global currNuser;
gaun=load("gadata.mat");
gacs=load("gadata_cstr.mat");
mudata=load("mudata.mat");

addpath('./apps');
% Utility functions
addpath('./utility');
addpath('./utility/dbs');
% xml and lqn templates defining the models
addpath('./res');

gaunT=zeros(1,size(gaun.data,1));
gacsT=zeros(1,size(gaun.data,1));
mudataT=zeros(1,size(gaun.data,1));

newIDX=[3     4    10    11     6     5     7     9     8];

[model, params] = initializeAcmeAir();
for i=1:size(gaun.data,1)    
    currNuser=gaun.data(i,2);
    
    disp(i);
%     gaunT(1,i)=getThroughputByCPUShare(fillmissing(gaun.data(i,newIDX),"constant",1), model);
%     gacsT(1,i)=getThroughputByCPUShare(fillmissing(gacs.dataga_cstr(i,newIDX),"constant",1), model);
    mudataT(1,i)=getThroughputByCPUShare(fillmissing(mudata.data_mu(i,newIDX)*2,"constant",1), model);
    disp(mudataT(1,i))
end