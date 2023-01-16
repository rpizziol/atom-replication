%evaluate result
clear

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

[model, params] = initializeAcmeAir();
for i=size(gaun.data,1)    
    currNuser=gaun.data(i,2);

    gaunT(1,i)=getThroughputByCPUShare(gaun.data(i,3:end), model);
    gacsT(1,i)=getThroughputByCPUShare(gacs.dataga_cstr(i,3:end), model);
    mudataT(1,i)=getThroughputByCPUShare(mudata.data_mu(i,3:end), model);
end