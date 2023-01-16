function [c, ceq] = nlcon(x,model)
% model.ms=["MSauth","MSvalidateid","MSviewprofile","MSupdateprofile"...
%     ,"MSupdateMiles","MSbookflights","MScancelbooking"...
%     ,"MSqueryflights","MSgetrewardmiles"];

RTmax=[1.8372;0.2400;0.0848;0.1536;0.2045;0.0446;0.3392;0.1951;0.0945;0.0527];
RT = getRTByCPUShare(x, model);

c = RT-RTmax;
% No nonlinear equality constraints:
ceq = [];
end