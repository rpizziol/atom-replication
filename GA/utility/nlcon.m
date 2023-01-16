function [c, ceq] = nlcon(x,model)
% model.ms=["MSauth","MSvalidateid","MSviewprofile","MSupdateprofile"...
%     ,"MSupdateMiles","MSbookflights","MScancelbooking"...
%     ,"MSqueryflights","MSgetrewardmiles"];

RT = getRTByCPUShare(cpushare, model);

c = [];
% No nonlinear equality constraints:
ceq = [];
end