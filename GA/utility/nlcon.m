function [c, ceq] = nlcon(x,model)
RT = getRTByCPUShare(x, model);
c = RT-model.RTmax;
% No nonlinear equality constraints:
ceq = [];
end