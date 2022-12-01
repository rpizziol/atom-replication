clear

e2=load("/Users/emilio-imt/git/nodejsMicro/data/ICDCS/validation/m1/validation.mat");
e1=load("/Users/emilio-imt/git/nodejsMicro/data/ICDCS/validation/m1/validation_1.mat");

e1CIdx=sum(sum(e1.RTm,2)~=0);
e2CIdx=sum(sum(e2.RTm,2)~=0);

Cli=e1.Cli;
RTm=cat(1,e1.RTm([1:e1CIdx],:),e2.RTm([1:e2CIdx],:));
Tm=cat(1,e1.Tm([1:e1CIdx],:),e2.Tm([1:e2CIdx],:));
NC=cat(1,e1.NC([1:e1CIdx],:),e2.NC([1:e2CIdx],:));
ms=e1.ms;


clear e1 e2

save("/Users/emilio-imt/git/nodejsMicro/data/ICDCS/validation/m1/acmeair_val_data.mat")