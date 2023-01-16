%evaluate result
clear
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
mudata=zeros(1,size(gaun.data,1));



[model, params] = initializeAcmeAir();
for i=size(gaun.data,1)
    gaunT(1,i)=getThroughputByCPUShare(gaun.data(i,3:end), model);
    gacsT(1,i)=getThroughputByCPUShare(gacs.data(i,3:end), model);
    mudata(1,i)=getThroughputByCPUShare(mudata.data(i,3:end), model);
end