function [c, ceq] = nlcon(x,model)
RT = getRTByCPUShare(x, model);
c = RT(1,1)-model.RTmax(1,1);
% No nonlinear equality constraints:
ceq = [];
end